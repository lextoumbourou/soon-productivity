import SwiftUI
import AppKit

class OverlayWindowController {
    static let shared = OverlayWindowController()

    private var overlayWindow: NSWindow?
    private var dismissTimer: Timer?

    private init() {}

    func showStartOverlay(task: String) {
        DispatchQueue.main.async { [weak self] in
            self?.createAndShowOverlay(task: task)
        }
    }

    private func createAndShowOverlay(task: String) {
        // Close any existing overlay
        dismissOverlay()

        // Create window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 300),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.center()
        window.isMovableByWindowBackground = true

        // Create SwiftUI content
        let overlayView = StartOverlayView(task: task) { [weak self] in
            self?.dismissOverlay()
        }

        window.contentView = NSHostingView(rootView: overlayView)

        overlayWindow = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        // Auto-dismiss after 8 seconds
        dismissTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { [weak self] _ in
            self?.dismissOverlay()
        }
    }

    func dismissOverlay() {
        dismissTimer?.invalidate()
        dismissTimer = nil
        overlayWindow?.close()
        overlayWindow = nil
    }
}

struct StartOverlayView: View {
    let task: String
    let onDismiss: () -> Void

    @State private var opacity: Double = 0

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "flame.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Go time!")
                .font(.system(size: 42, weight: .bold))

            Text(task)
                .font(.title2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text("Click anywhere to dismiss")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(48)
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThickMaterial)
                .shadow(radius: 20)
        }
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1
            }
        }
        .onTapGesture {
            withAnimation(.easeIn(duration: 0.2)) {
                opacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                onDismiss()
            }
        }
    }
}
