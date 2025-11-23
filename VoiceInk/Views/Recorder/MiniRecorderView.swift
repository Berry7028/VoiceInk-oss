import SwiftUI

struct MiniRecorderView: View {
    @ObservedObject var whisperState: WhisperState
    @ObservedObject var recorder: Recorder
    @EnvironmentObject var windowManager: MiniWindowManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    
    @State private var activePopover: ActivePopoverState = .none

    private var containerWidth: CGFloat {
        whisperState.isRealtimeHUDVisible ? 332 : 184
    }
    
    private var backgroundView: some View {
        ZStack {
            Color.black.opacity(0.9)
            LinearGradient(
                colors: [
                    Color.black.opacity(0.95),
                    Color(red: 0.15, green: 0.15, blue: 0.15).opacity(0.9)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            VisualEffectView(material: .hudWindow, blendingMode: .withinWindow)
                .opacity(0.05)
        }
        .clipShape(Capsule())
    }
    
    private var statusView: some View {
        RecorderStatusDisplay(
            currentState: whisperState.recordingState,
            audioMeter: recorder.audioMeter
        )
    }
    
    private var contentLayout: some View {
        HStack(spacing: 0) {
            // Left button zone - always visible
            RecorderPromptButton(activePopover: $activePopover)
                .padding(.leading, 7)

            Spacer()

            // Fixed visualizer zone
            statusView
                .frame(maxWidth: .infinity)

            Spacer()

            // Right button zone - always visible
            RecorderPowerModeButton(activePopover: $activePopover)
                .padding(.trailing, 7)
        }
        .padding(.vertical, whisperState.isRealtimeHUDVisible ? 6 : 8)
    }
    
    private var recorderCapsule: some View {
        Capsule()
            .fill(.clear)
            .background(backgroundView)
            .overlay {
                Capsule()
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
            }
            .overlay {
                contentLayout
            }
            .frame(height: 34)
    }
    
    private var realtimeRecorderContainer: some View {
        VStack(spacing: 0) {
            RealtimeTranscriptionOverlayView(text: whisperState.realtimeHUDText)
                .padding(.top, 18)
                .padding(.horizontal, 20)
                .padding(.bottom, 14)
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.horizontal, 14)
            contentLayout
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black.opacity(0.94))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
    
    var body: some View {
        Group {
            if windowManager.isVisible {
                if whisperState.isRealtimeHUDVisible {
                    realtimeRecorderContainer
                        .frame(width: containerWidth)
                } else {
                    recorderCapsule
                        .frame(width: containerWidth)
                }
            }
        }
    }
}

private struct RealtimeTranscriptionOverlayView: View {
    let text: String
    @State private var isUserInteracting = false
    private let bottomID = "RealtimeBottom"

    private var displayText: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Listening..." : trimmed
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: true) {
                Text(displayText)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .lineSpacing(4)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.trailing, 6)
                Color.clear
                    .frame(height: 1)
                    .id(bottomID)
            }
            .frame(height: 120)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isUserInteracting {
                            isUserInteracting = true
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            isUserInteracting = false
                        }
                    }
            )
            .onChange(of: text) { _ in
                guard !isUserInteracting else { return }
                withAnimation(.easeOut(duration: 0.2)) {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            .onAppear {
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
}
