import SwiftUI

/// Display realtime transcription text in a scrollable view
struct RealtimeTranscriptionDisplay: View {
    @ObservedObject var whisperState: WhisperState
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if whisperState.realtimeTranscriptionText.isEmpty {
                            // Placeholder when no text
                            Text("話し始めると、ここに文字が表示されます...")
                                .font(.system(size: 12, weight: .regular, design: .default))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            // Display realtime transcription
                            Text(whisperState.realtimeTranscriptionText)
                                .font(.system(size: 12, weight: .medium, design: .default))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("transcriptionText")
                        }
                    }
                }
                .frame(maxHeight: 100)
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: whisperState.realtimeTranscriptionText) { _ in
                    // Auto-scroll to bottom when text updates
                    withAnimation(.easeOut(duration: 0.2)) {
                        proxy.scrollTo("transcriptionText", anchor: .bottom)
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.4))
        )
    }
}

/// Compact realtime transcription display for notch mode
struct CompactRealtimeTranscriptionDisplay: View {
    @ObservedObject var whisperState: WhisperState

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                if whisperState.realtimeTranscriptionText.isEmpty {
                    Text("話し始めると文字が表示されます...")
                        .font(.system(size: 11, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.horizontal, 8)
                } else {
                    Text(whisperState.realtimeTranscriptionText)
                        .font(.system(size: 11, weight: .medium, design: .default))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                }
            }
        }
        .frame(height: 24)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.black.opacity(0.3))
        )
    }
}

/// Stop button for realtime transcription
struct RealtimeStopButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: "stop.fill")
                    .font(.system(size: 11, weight: .semibold))
                Text("完了")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(Color.red)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
