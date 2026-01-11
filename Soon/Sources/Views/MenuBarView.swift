import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var selectedTab: Tab = .focus

    enum Tab {
        case focus
        case history
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Soon")
                    .font(.headline)

                Spacer()

                Picker("", selection: $selectedTab) {
                    Image(systemName: "flame").tag(Tab.focus)
                    Image(systemName: "clock.arrow.circlepath").tag(Tab.history)
                }
                .pickerStyle(.segmented)
                .frame(width: 80)
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Content
            Group {
                switch selectedTab {
                case .focus:
                    focusContent
                case .history:
                    HistoryView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Footer
            HStack {
                Button {
                    NSApp.terminate(nil)
                } label: {
                    Image(systemName: "power")
                }
                .buttonStyle(.borderless)
                .help("Quit Soon")

                Spacer()

                if let appDelegate = NSApp.delegate as? AppDelegate {
                    Button("Settings...") {
                        appDelegate.closePopover()
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(nsColor: .windowBackgroundColor))
        }
        .frame(width: 320, height: 400)
    }

    @ViewBuilder
    private var focusContent: some View {
        switch sessionManager.state {
        case .idle:
            ScheduleFocusView()

        case .scheduled, .countdown:
            ScheduledView()

        case .active:
            ActiveSessionView()

        case .reflection:
            ReflectionView()
        }
    }
}
