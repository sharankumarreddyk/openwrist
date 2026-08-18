import SwiftUI

struct RootView: View {
    @ObservedObject var services: Services

    var body: some View {
        TabView {
            WatchView(state: services.state, ble: services.ble, weather: services.weather)
                .tabItem { Label("Watch", systemImage: "applewatch") }
            AuthView(store: services.auth)
                .tabItem { Label("Auth", systemImage: "lock.shield") }
            SettingsView(settings: services.settings, ble: services.ble)
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

struct WatchView: View {
    @ObservedObject var state: WatchState
    let ble: BLEManager
    @ObservedObject var weather: WeatherService

    var body: some View {
        NavigationStack {
            List {
                Section("Watch") {
                    row("Status", state.connection.rawValue)
                    row("Battery", "\(state.batteryPct)%\(state.charging ? " ⚡" : "")")
                    row("Firmware", state.fwVersion)
                }
                Section("Today") {
                    row("Steps", "\(state.steps)")
                    row("Active minutes", "\(state.activeMinutes)")
                }
                weatherSection
                if let err = state.lastError {
                    Section { Text(err).foregroundStyle(.red) }
                }
                Section {
                    if state.connection == .idle {
                        Button("Connect") { ble.start() }
                    } else {
                        Button("Disconnect", role: .destructive) { ble.disconnect() }
                    }
                }
            }
            .navigationTitle("OpenWrist")
        }
    }

    @ViewBuilder private var weatherSection: some View {
        Section("Weather") {
            if let w = weather.current {
                row("Now", "\(Int(w.tempC.rounded()))°C · \(w.summary) · \(w.humidityPct)%")
                Button("Push to watch") {
                    if let p = weather.packet { ble.sendWeather(p) }
                }
            } else {
                Button("Fetch weather") { Task { await weather.refresh() } }
            }
            if let e = weather.error { Text(e).foregroundStyle(.red).font(.footnote) }
        }
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack { Text(k); Spacer(); Text(v).foregroundStyle(.secondary) }
    }
}
