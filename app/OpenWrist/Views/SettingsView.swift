import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings: SettingsStore
    let ble: BLEManager
    @State private var sent = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Clock") {
                    Toggle("24-hour time", isOn: $settings.use24h)
                }
                Section("Display") {
                    HStack {
                        Text("Brightness")
                        Slider(value: $settings.brightness, in: 0...100, step: 5)
                        Text("\(Int(settings.brightness))%").monospacedDigit()
                    }
                    Picker("Watch face", selection: $settings.watchFaceId) {
                        ForEach(0..<SettingsStore.faceCount, id: \.self) { Text("Face \($0 + 1)").tag($0) }
                    }
                }
                Section {
                    Button("Apply to watch") {
                        ble.sendConfig(settings.packet)
                        sent = true
                    }
                    if sent { Text("Sent ✓").foregroundStyle(.secondary).font(.footnote) }
                }
            }
            .navigationTitle("Settings")
        }
    }
}
