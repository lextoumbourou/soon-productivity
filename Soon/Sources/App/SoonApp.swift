import SwiftUI
import SwiftData

@main
struct SoonApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FocusSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        // Menu bar app - no main window
        Settings {
            SettingsView()
                .modelContainer(sharedModelContainer)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var sessionManager: SessionManager?
    var modelContainer: ModelContainer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)

        // Set up model container
        let schema = Schema([FocusSession.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        // Initialize session manager
        sessionManager = SessionManager(modelContainer: modelContainer!)

        // Set up menu bar
        setupMenuBar()

        // Request notification permissions
        NotificationService.shared.requestPermission()
    }

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "clock", accessibilityDescription: "Soon")
            button.action = #selector(togglePopover)
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 480)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(sessionManager!)
                .modelContainer(modelContainer!)
        )
    }

    @objc func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }

        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    func closePopover() {
        popover?.performClose(nil)
    }

    func updateMenuBarIcon(for state: SessionState) {
        guard let button = statusItem?.button else { return }

        let symbolName: String
        switch state {
        case .idle:
            symbolName = "clock"
        case .scheduled:
            symbolName = "clock.badge"
        case .countdown:
            symbolName = "clock.arrow.circlepath"
        case .active:
            symbolName = "flame.fill"
        case .reflection:
            symbolName = "checkmark.circle"
        }

        button.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: "Soon")
    }
}
