import SwiftUI

struct MiniRecorderView: View {
    @ObservedObject var whisperState: WhisperState
    @ObservedObject var recorder: Recorder
    @EnvironmentObject var windowManager: MiniWindowManager
    @EnvironmentObject private var enhancementService: AIEnhancementService
    
    @State private var activePopover: ActivePopoverState = .none

    private var containerWidth: CGFloat {
        whisperState.isRealtimeHUDVisible ? 360 : 184
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
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .padding(.bottom, 12)
            
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.0),
                            Color.white.opacity(0.12),
                            Color.white.opacity(0.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.horizontal, 20)
            
            contentLayout
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.black.opacity(0.96))
                
                // Subtle gradient overlay for depth
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.15, green: 0.18, blue: 0.22).opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
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

// MARK: - Realtime Transcription Status
enum RealtimeTranscriptionStatus {
    case listening
    case transcribing
    case error(String)
    
    var displayText: String {
        switch self {
        case .listening:
            return "Listening..."
        case .transcribing:
            return "Transcribing"
        case .error(let message):
            return message
        }
    }
    
    var color: Color {
        switch self {
        case .listening:
            return .white.opacity(0.6)
        case .transcribing:
            return Color(red: 0.4, green: 0.8, blue: 1.0)
        case .error:
            return Color(red: 1.0, green: 0.4, blue: 0.4)
        }
    }
}

// MARK: - Typing Cursor Animation
private struct TypingCursor: View {
    @State private var opacity: Double = 1.0
    
    var body: some View {
        Rectangle()
            .fill(Color(red: 0.4, green: 0.8, blue: 1.0))
            .frame(width: 2, height: 20)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                    opacity = 0.3
                }
            }
    }
}

// MARK: - Live Indicator
private struct LiveIndicator: View {
    @State private var isPulsing = false
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(Color(red: 0.4, green: 0.8, blue: 1.0))
                .frame(width: 8, height: 8)
                .scaleEffect(isPulsing ? 1.2 : 1.0)
                .opacity(isPulsing ? 0.7 : 1.0)
            
            Text("LIVE")
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.4, green: 0.8, blue: 1.0))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(Color(red: 0.4, green: 0.8, blue: 1.0).opacity(0.15))
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}

// MARK: - Wave Animation for Listening State
private struct ListeningWaveAnimation: View {
    @State private var animationPhase: Double = 0
    private let waveCount = 3
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<waveCount, id: \.self) { index in
                Circle()
                    .fill(Color.white.opacity(0.5))
                    .frame(width: 6, height: 6)
                    .scaleEffect(scaleForIndex(index))
                    .opacity(opacityForIndex(index))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
                animationPhase = 1
            }
        }
    }
    
    private func scaleForIndex(_ index: Int) -> CGFloat {
        let phase = (animationPhase + Double(index) * 0.3).truncatingRemainder(dividingBy: 1.0)
        return 1.0 + CGFloat(sin(phase * .pi * 2)) * 0.4
    }
    
    private func opacityForIndex(_ index: Int) -> Double {
        let phase = (animationPhase + Double(index) * 0.3).truncatingRemainder(dividingBy: 1.0)
        return 0.5 + sin(phase * .pi * 2) * 0.5
    }
}

// MARK: - Character Count Display
private struct CharacterCountView: View {
    let count: Int
    
    var body: some View {
        Text("\(count) chars")
            .font(.system(size: 10, weight: .medium, design: .monospaced))
            .foregroundColor(.white.opacity(0.4))
    }
}

// MARK: - Realtime Transcription Overlay View (Redesigned)
private struct RealtimeTranscriptionOverlayView: View {
    let text: String
    @State private var isUserInteracting = false
    @State private var previousTextLength: Int = 0
    @State private var isNewTextArriving = false
    private let bottomID = "RealtimeBottom"
    
    private var status: RealtimeTranscriptionStatus {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return .listening
        } else {
            return .transcribing
        }
    }
    
    private var displayText: String {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "" : trimmed
    }
    
    private var hasContent: Bool {
        !displayText.isEmpty
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with status indicator
            headerView
                .padding(.bottom, 10)
            
            // Main content area
            contentArea
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            LiveIndicator()
            
            Spacer()
            
            if hasContent {
                CharacterCountView(count: displayText.count)
            }
        }
    }
    
    // MARK: - Content Area
    private var contentArea: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    if hasContent {
                        // Transcribed text with typing cursor
                        HStack(alignment: .bottom, spacing: 2) {
                            Text(displayText)
                                .font(.system(size: 17, weight: .regular, design: .rounded))
                                .foregroundColor(.white)
                                .lineSpacing(6)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .animation(.easeOut(duration: 0.1), value: displayText)
                            
                            TypingCursor()
                                .padding(.bottom, 2)
                        }
                        .padding(.trailing, 4)
                    } else {
                        // Listening state placeholder
                        listeningPlaceholder
                    }
                    
                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }
            }
            .frame(height: 100)
            .mask(
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [.clear, .white],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 8)
                    
                    Rectangle()
                        .fill(Color.white)
                    
                    LinearGradient(
                        colors: [.white, .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 8)
                }
            )
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        if !isUserInteracting {
                            isUserInteracting = true
                        }
                    }
                    .onEnded { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isUserInteracting = false
                        }
                    }
            )
            .onChange(of: text) { newValue in
                // Detect new text arriving
                let newLength = newValue.count
                if newLength > previousTextLength {
                    withAnimation(.easeOut(duration: 0.15)) {
                        isNewTextArriving = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        isNewTextArriving = false
                    }
                }
                previousTextLength = newLength
                
                // Auto-scroll to bottom
                guard !isUserInteracting else { return }
                withAnimation(.easeOut(duration: 0.15)) {
                    proxy.scrollTo(bottomID, anchor: .bottom)
                }
            }
            .onAppear {
                previousTextLength = text.count
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        }
    }
    
    // MARK: - Listening Placeholder
    private var listeningPlaceholder: some View {
        VStack(spacing: 12) {
            Spacer()
            
            ListeningWaveAnimation()
            
            Text("Listening...")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
            
            Text("Start speaking to see transcription")
                .font(.system(size: 12, weight: .regular, design: .rounded))
                .foregroundColor(.white.opacity(0.3))
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 90)
    }
}
