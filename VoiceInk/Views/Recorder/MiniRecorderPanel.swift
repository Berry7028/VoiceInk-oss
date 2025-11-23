import SwiftUI
import AppKit

class MiniRecorderPanel: NSPanel {
    private var isRealtimeOverlayVisible: Bool

    init(contentRect: NSRect, showingRealtimeOverlay: Bool) {
        self.isRealtimeOverlayVisible = showingRealtimeOverlay
        super.init(
            contentRect: contentRect,
            styleMask: [.nonactivatingPanel, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        configurePanel()
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }
    
    private func configurePanel() {
        isFloatingPanel = true
        level = .floating
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        isMovable = true
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        standardWindowButton(.closeButton)?.isHidden = true
    }
    
    static func calculateWindowMetrics(showingRealtimeOverlay: Bool) -> NSRect {
        guard let screen = NSScreen.main else {
            let fallbackWidth: CGFloat = showingRealtimeOverlay ? 332 : 184
            let fallbackHeight: CGFloat = showingRealtimeOverlay ? 204 : 36
            return NSRect(x: 0, y: 0, width: fallbackWidth, height: fallbackHeight)
        }

        let width: CGFloat = showingRealtimeOverlay ? 332 : 184
        let height: CGFloat = showingRealtimeOverlay ? 204 : 36
        let padding: CGFloat = 24

        let visibleFrame = screen.visibleFrame
        let centerX = visibleFrame.midX
        let xPosition = centerX - (width / 2)
        let yPosition = visibleFrame.minY + padding

        return NSRect(
            x: xPosition,
            y: yPosition,
            width: width,
            height: height
        )
    }
    
    func show() {
        let metrics = MiniRecorderPanel.calculateWindowMetrics(showingRealtimeOverlay: isRealtimeOverlayVisible)
        setFrame(metrics, display: true)
        orderFrontRegardless()
    }

    func updateRealtimeOverlayVisibility(_ isVisible: Bool, animated: Bool) {
        isRealtimeOverlayVisible = isVisible
        let metrics = MiniRecorderPanel.calculateWindowMetrics(showingRealtimeOverlay: isVisible)
        setFrame(metrics, display: true, animate: animated)
    }
    
    func hide(completion: @escaping () -> Void) {
        completion()
    }
}
