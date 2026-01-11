import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("defaultDelay") private var defaultDelay = 10
    @AppStorage("defaultDuration") private var defaultDuration = 25
    @AppStorage("showWarningNotification") private var showWarningNotification = true

    var body: some View {
        TabView {
            GeneralSettingsView(
                launchAtLogin: $launchAtLogin,
                showWarningNotification: $showWarningNotification
            )
            .tabItem {
                Label("General", systemImage: "gear")
            }

            DefaultsSettingsView(
                defaultDelay: $defaultDelay,
                defaultDuration: $defaultDuration
            )
            .tabItem {
                Label("Defaults", systemImage: "clock")
            }
        }
        .frame(width: 400, height: 200)
    }
}

struct GeneralSettingsView: View {
    @Binding var launchAtLogin: Bool
    @Binding var showWarningNotification: Bool

    var body: some View {
        Form {
            Toggle("Launch at login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    setLaunchAtLogin(enabled: newValue)
                }

            Toggle("Show 2-minute warning notification", isOn: $showWarningNotification)
        }
        .padding()
    }

    private func setLaunchAtLogin(enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            print("Failed to \(enabled ? "enable" : "disable") launch at login: \(error)")
        }
    }
}

struct DefaultsSettingsView: View {
    @Binding var defaultDelay: Int
    @Binding var defaultDuration: Int

    private let delayOptions = [5, 10, 20, 30]
    private let durationOptions = [10, 15, 25, 50, 90]

    var body: some View {
        Form {
            Picker("Default delay", selection: $defaultDelay) {
                ForEach(delayOptions, id: \.self) { delay in
                    Text("\(delay) minutes").tag(delay)
                }
            }

            Picker("Default duration", selection: $defaultDuration) {
                ForEach(durationOptions, id: \.self) { duration in
                    Text("\(duration) minutes").tag(duration)
                }
            }
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
