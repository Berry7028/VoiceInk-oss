import Foundation
import Speech
import AVFoundation
import os

/// Service for realtime transcription using Apple's SFSpeechRecognizer
/// Available on macOS 10.15+
@MainActor
class RealtimeAppleTranscriptionService: NSObject, ObservableObject {
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "RealtimeAppleTranscriptionService")

    // Speech recognition components
    private var speechRecognizer: SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    // Audio engine components
    private let audioEngine = AVAudioEngine()
    private var audioFile: AVAudioFile?
    private var recordingURL: URL?

    // State
    @Published var isRecognizing = false
    @Published var partialTranscription = ""
    private var finalTranscription = ""

    // Callbacks
    private var onPartialResult: ((String) -> Void)?
    private var onFinalResult: ((String) -> Void)?
    private var onError: ((Error) -> Void)?

    enum ServiceError: Error, LocalizedError {
        case recognizerNotAvailable
        case audioEngineNotAvailable
        case notAuthorized
        case audioFileCreationFailed
        case alreadyRecognizing

        var errorDescription: String? {
            switch self {
            case .recognizerNotAvailable:
                return "Speech recognizer is not available for the selected language."
            case .audioEngineNotAvailable:
                return "Audio engine is not available."
            case .notAuthorized:
                return "Speech recognition is not authorized. Please grant permission in System Settings."
            case .audioFileCreationFailed:
                return "Failed to create audio recording file."
            case .alreadyRecognizing:
                return "Speech recognition is already in progress."
            }
        }
    }

    /// Maps simple language codes to Apple's locale format
    private func mapToLocale(_ simpleCode: String) -> Locale {
        let mapping = [
            "en": "en-US",
            "es": "es-ES",
            "fr": "fr-FR",
            "de": "de-DE",
            "ar": "ar-SA",
            "it": "it-IT",
            "ja": "ja-JP",
            "ko": "ko-KR",
            "pt": "pt-BR",
            "yue": "yue-CN",
            "zh": "zh-CN"
        ]
        let localeString = mapping[simpleCode] ?? "en-US"
        return Locale(identifier: localeString)
    }

    /// Request speech recognition authorization
    func requestAuthorization() async -> Bool {
        return await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }

    /// Start realtime transcription
    func startRealtimeTranscription(
        language: String,
        recordingURL: URL,
        onPartialResult: @escaping (String) -> Void,
        onFinalResult: @escaping (String) -> Void,
        onError: @escaping (Error) -> Void
    ) async throws {
        guard !isRecognizing else {
            throw ServiceError.alreadyRecognizing
        }

        // Check authorization
        let authStatus = SFSpeechRecognizer.authorizationStatus()
        guard authStatus == .authorized else {
            throw ServiceError.notAuthorized
        }

        // Store callbacks
        self.onPartialResult = onPartialResult
        self.onFinalResult = onFinalResult
        self.onError = onError
        self.recordingURL = recordingURL

        // Initialize speech recognizer with locale
        let locale = mapToLocale(language)
        speechRecognizer = SFSpeechRecognizer(locale: locale)

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            throw ServiceError.recognizerNotAvailable
        }

        logger.notice("Starting realtime transcription with locale: \(locale.identifier)")

        // Reset state
        partialTranscription = ""
        finalTranscription = ""
        isRecognizing = true

        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw ServiceError.recognizerNotAvailable
        }

        // Configure request for realtime results
        recognitionRequest.shouldReportPartialResults = true

        // Set up audio file for recording
        let recordSettings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000.0,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVLinearPCMIsBigEndianKey: false,
            AVLinearPCMIsNonInterleaved: false
        ]

        do {
            audioFile = try AVAudioFile(forWriting: recordingURL, settings: recordSettings)
        } catch {
            logger.error("Failed to create audio file: \(error.localizedDescription)")
            throw ServiceError.audioFileCreationFailed
        }

        // Configure audio engine
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Install tap on audio input
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            guard let self = self else { return }

            // Send buffer to speech recognizer
            self.recognitionRequest?.append(buffer)

            // Write buffer to audio file
            do {
                try self.audioFile?.write(from: buffer)
            } catch {
                self.logger.error("Failed to write audio buffer: \(error.localizedDescription)")
            }
        }

        // Prepare and start audio engine
        audioEngine.prepare()
        try audioEngine.start()

        logger.notice("Audio engine started successfully")

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            Task { @MainActor in
                if let error = error {
                    self.logger.error("Recognition error: \(error.localizedDescription)")
                    self.onError?(error)
                    await self.stopRealtimeTranscription()
                    return
                }

                if let result = result {
                    let transcription = result.bestTranscription.formattedString

                    if result.isFinal {
                        self.logger.notice("Final transcription received: \(transcription)")
                        self.finalTranscription = transcription
                        self.partialTranscription = transcription
                        self.onFinalResult?(transcription)
                    } else {
                        self.partialTranscription = transcription
                        self.onPartialResult?(transcription)
                    }
                }
            }
        }

        logger.notice("Recognition task started successfully")
    }

    /// Stop realtime transcription and return final result
    func stopRealtimeTranscription() async -> String {
        logger.notice("Stopping realtime transcription")

        isRecognizing = false

        // Stop audio engine
        if audioEngine.isRunning {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
            logger.notice("Audio engine stopped")
        }

        // End recognition request
        recognitionRequest?.endAudio()
        recognitionRequest = nil

        // Cancel recognition task
        recognitionTask?.cancel()
        recognitionTask = nil

        // Close audio file
        audioFile = nil

        logger.notice("Realtime transcription stopped. Final text: \(finalTranscription)")

        return finalTranscription.isEmpty ? partialTranscription : finalTranscription
    }

    /// Check if speech recognition is available for the given language
    func isAvailable(for language: String) -> Bool {
        let locale = mapToLocale(language)
        guard let recognizer = SFSpeechRecognizer(locale: locale) else {
            return false
        }
        return recognizer.isAvailable
    }

    deinit {
        Task { @MainActor in
            _ = await stopRealtimeTranscription()
        }
    }
}
