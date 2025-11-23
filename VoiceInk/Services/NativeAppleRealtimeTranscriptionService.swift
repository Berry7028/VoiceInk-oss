import Foundation
import AVFoundation
import os

#if canImport(Speech)
import Speech

final class AppleSpeechRealtimeTranscriptionService: RealtimeTranscriptionServiceProtocol {
    private let logger = Logger(subsystem: "com.prakashjoshipax.voiceink", category: "AppleSpeechRealtime" )
    private var streamingTask: Task<Void, Never>?
    private var audioFileURL: URL?
    private var streamReadOffset: UInt64 = 0
    private let chunkSize: UInt64 = 6_400
    private var shouldStopStreaming = false
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var speechRecognizer: SFSpeechRecognizer?
    private let transcriptQueue = DispatchQueue(label: "com.prakashjoshipax.voiceink.apple.realtime.transcript", attributes: .concurrent)
    private var committedTextStorage: String = ""
    private var partialTextStorage: String = ""
    private let audioFormat: AVAudioFormat? = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16_000, channels: 1, interleaved: false)
    private var recognitionCompletionContinuation: CheckedContinuation<Void, Never>?
    private var recognitionDidComplete = false

    var onTextUpdate: ((String) -> Void)?
    var onConnectionStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    var isSessionActive: Bool {
        recognitionTask != nil
    }

    func startSession(audioFileURL: URL, modelName: String?) async throws {
        try await ensureSpeechAuthorization()

        let localeIdentifier = mapToAppleLocale(UserDefaults.standard.string(forKey: "SelectedLanguage") ?? "en")
        guard let format = audioFormat else {
            throw ServiceError.invalidAudioFormat
        }

        let recognizer = await MainActor.run { SFSpeechRecognizer(locale: Locale(identifier: localeIdentifier)) }
        guard let speechRecognizer = recognizer, speechRecognizer.isAvailable else {
            throw ServiceError.recognizerUnavailable
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request
        self.speechRecognizer = speechRecognizer

        committedTextStorage = ""
        partialTextStorage = ""
        self.audioFileURL = audioFileURL
        streamReadOffset = 0
        shouldStopStreaming = false

        recognitionTask = speechRecognizer.recognitionTask(with: request) { [weak self] result, error in
            guard let self else { return }
            if let error {
                self.logger.error("Apple realtime recognition error: \(error.localizedDescription)")
                DispatchQueue.main.async { [weak self] in
                    self?.onError?(error.localizedDescription)
                }
                self.signalRecognitionCompletion()
            }

            if let result {
                let text = result.bestTranscription.formattedString
                self.updateTranscript(committed: result.isFinal ? text : nil, partial: result.isFinal ? nil : text)
                if result.isFinal {
                    self.signalRecognitionCompletion()
                }
            }
        }

        DispatchQueue.main.async { [weak self] in
            self?.onConnectionStateChange?(true)
        }

        streamingTask = Task(priority: .userInitiated) { [weak self] in
            guard let self else { return }
            await self.performStreamingLoop(audioFormat: format)
        }
    }

    func finishSession() async -> String {
        shouldStopStreaming = true
        if let streamingTask {
            await streamingTask.value
        }
        streamingTask = nil

        recognitionRequest?.endAudio()
        await waitForRecognitionCompletion()
        recognitionTask = nil
        recognitionRequest = nil

        DispatchQueue.main.async { [weak self] in
            self?.onConnectionStateChange?(false)
        }

        let text = finalTranscript()
        cleanup()
        return text
    }

    func cancelSession() async {
        shouldStopStreaming = true
        streamingTask?.cancel()
        streamingTask = nil
        recognitionTask?.cancel()
        signalRecognitionCompletion()
        recognitionTask = nil
        recognitionRequest = nil
        cleanup()
    }

    func finalTranscript() -> String {
        return transcriptQueue.sync {
            let committed = committedTextStorage.trimmingCharacters(in: .whitespacesAndNewlines)
            let partial = partialTextStorage.trimmingCharacters(in: .whitespacesAndNewlines)
            if committed.isEmpty {
                return partial
            }
            if partial.isEmpty {
                return committed
            }
            return "\(committed) \(partial)"
        }
    }

    // MARK: - Helpers

    private func performStreamingLoop(audioFormat: AVAudioFormat) async {
        guard let audioFileURL else { return }
        var handle: FileHandle?
        defer { try? handle?.close() }

        do {
            while !FileManager.default.fileExists(atPath: audioFileURL.path) && !Task.isCancelled {
                try await Task.sleep(nanoseconds: 50_000_000)
            }

            guard !Task.isCancelled else { return }
            handle = try FileHandle(forReadingFrom: audioFileURL)
            var headerSkipped = false

            while !Task.isCancelled {
                if shouldStopStreaming {
                    let currentSize = try fileSize(of: audioFileURL)
                    if currentSize <= streamReadOffset {
                        break
                    }
                }

                let fileSize = try fileSize(of: audioFileURL)
                if !headerSkipped {
                    if fileSize <= 44 {
                        try await Task.sleep(nanoseconds: 50_000_000)
                        continue
                    }
                    streamReadOffset = 44
                    headerSkipped = true
                }

                if fileSize > streamReadOffset {
                    let available = fileSize - streamReadOffset
                    let bytesToRead = Int(min(available, chunkSize))
                    try handle?.seek(toOffset: streamReadOffset)
                    if let chunk = handle?.readData(ofLength: bytesToRead), !chunk.isEmpty {
                        streamReadOffset += UInt64(chunk.count)
                        appendChunk(chunk, format: audioFormat)
                    }
                } else {
                    try await Task.sleep(nanoseconds: 80_000_000)
                }
            }
        } catch {
            logger.error("Apple realtime streaming failed: \(error.localizedDescription)")
            DispatchQueue.main.async { [weak self] in
                self?.onError?(error.localizedDescription)
            }
        }
    }

    private func appendChunk(_ data: Data, format: AVAudioFormat) {
        guard let request = recognitionRequest else { return }
        let frameCapacity = UInt32(data.count / 2)
        guard frameCapacity > 0 else { return }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCapacity) else { return }
        buffer.frameLength = frameCapacity

        data.withUnsafeBytes { rawBuffer in
            if let src = rawBuffer.bindMemory(to: Int16.self).baseAddress,
               let dst = buffer.int16ChannelData?[0] {
                dst.assign(from: src, count: Int(frameCapacity))
            }
        }

        request.append(buffer)
    }

    private func updateTranscript(committed: String?, partial: String?) {
        transcriptQueue.async(flags: .barrier) { [weak self] in
            guard let self else { return }
            if let committed = committed {
                self.committedTextStorage = committed
                self.partialTextStorage = ""
            }
            if let partial = partial {
                self.partialTextStorage = partial
            }
            let combined: String
            let committed = self.committedTextStorage.trimmingCharacters(in: .whitespacesAndNewlines)
            let partial = self.partialTextStorage.trimmingCharacters(in: .whitespacesAndNewlines)
            if committed.isEmpty {
                combined = partial
            } else if partial.isEmpty {
                combined = committed
            } else {
                combined = "\(committed) \(partial)"
            }
            DispatchQueue.main.async { [weak self] in
                self?.onTextUpdate?(combined)
            }
        }
    }

    private func signalRecognitionCompletion() {
        recognitionDidComplete = true
        recognitionCompletionContinuation?.resume()
        recognitionCompletionContinuation = nil
    }

    private func waitForRecognitionCompletion() async {
        guard recognitionTask != nil else { return }
        if recognitionDidComplete {
            recognitionDidComplete = false
            return
        }

        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            recognitionCompletionContinuation = continuation
        }
        recognitionDidComplete = false
    }

    private func cleanup() {
        audioFileURL = nil
        streamReadOffset = 0
        shouldStopStreaming = false
        recognitionCompletionContinuation = nil
        recognitionDidComplete = false
        transcriptQueue.async(flags: .barrier) { [weak self] in
            self?.committedTextStorage = ""
            self?.partialTextStorage = ""
        }
        DispatchQueue.main.async { [weak self] in
            self?.onConnectionStateChange?(false)
            self?.onTextUpdate?("")
        }
    }

    private func mapToAppleLocale(_ simpleCode: String) -> String {
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
        return mapping[simpleCode] ?? "en-US"
    }

    private func fileSize(of url: URL) throws -> UInt64 {
        let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
        return attributes[.size] as? UInt64 ?? 0
    }

    private func ensureSpeechAuthorization() async throws {
        let status = SFSpeechRecognizer.authorizationStatus()
        if status == .authorized {
            return
        }
        if status == .notDetermined {
            let newStatus = try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.main.async {
                    SFSpeechRecognizer.requestAuthorization { authStatus in
                        continuation.resume(returning: authStatus)
                    }
                }
            }
            if newStatus == .authorized {
                return
            }
            throw ServiceError.permissionDenied
        }
        throw ServiceError.permissionDenied
    }

    enum ServiceError: Error, LocalizedError {
        case permissionDenied
        case recognizerUnavailable
        case invalidAudioFormat

        var errorDescription: String? {
            switch self {
            case .permissionDenied:
                return "Speech recognition permission denied."
            case .recognizerUnavailable:
                return "Apple Speech recognizer is unavailable for the selected locale."
            case .invalidAudioFormat:
                return "Unable to configure audio format for Apple Speech realtime transcription."
            }
        }
    }
}

#else

final class AppleSpeechRealtimeTranscriptionService: RealtimeTranscriptionServiceProtocol {
    var onTextUpdate: ((String) -> Void)?
    var onConnectionStateChange: ((Bool) -> Void)?
    var onError: ((String) -> Void)?

    var isSessionActive: Bool { false }

    func startSession(audioFileURL: URL, modelName: String?) async throws {
        throw ServiceError.unsupportedPlatform
    }

    func finishSession() async -> String { "" }

    func cancelSession() async { }

    func finalTranscript() -> String { "" }

    enum ServiceError: Error, LocalizedError {
        case unsupportedPlatform

        var errorDescription: String? {
            "Apple Speech realtime transcription is unavailable on this platform."
        }
    }
}

#endif
