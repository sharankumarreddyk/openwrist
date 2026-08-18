import SwiftUI

struct ContentView: View {
    @ObservedObject var state: WatchState
    let ble: BLEManager

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
                if let err = state.lastError {
                    Section { Text(err).foregroundStyle(.red) }
                }
                Section {
                    if state.connection == .idle {
                        Button("Connect") { ble.start() }
                    } else {
                        Button("Disconnect", role: .destructive) { ble.disconnect() }
                    }
                    Button("Send test config (24h, 60% bright)") {
                        ble.sendConfig(.init(use24h: true, brightness: 60, watchFaceId: 0))
                    }
                }
            }
            .navigationTitle("OpenWrist")
        }
    }

    private func row(_ k: String, _ v: String) -> some View {
        HStack { Text(k); Spacer(); Text(v).foregroundStyle(.secondary) }
    }
}
