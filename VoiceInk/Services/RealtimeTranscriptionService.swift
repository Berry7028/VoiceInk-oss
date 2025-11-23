import Foundation

protocol RealtimeTranscriptionServiceProtocol: AnyObject {
    var onTextUpdate: ((String) -> Void)? { get set }
    var onConnectionStateChange: ((Bool) -> Void)? { get set }
    var onError: ((String) -> Void)? { get set }
    var isSessionActive: Bool { get }

    func startSession(audioFileURL: URL, modelName: String?) async throws
    func finishSession() async -> String
    func cancelSession() async
    func finalTranscript() -> String
}
