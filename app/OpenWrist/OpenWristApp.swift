import SwiftUI

@MainActor
final class Services: ObservableObject {
    let state: WatchState
    let ble: BLEManager
    let settings = SettingsStore()
    let weather = WeatherService()
    let auth = AuthStore()
    private let health: HealthKitManager

    init() {
        let s = WatchState()
        let h = HealthKitManager()
        state = s
        health = h
        ble = BLEManager(state: s, health: h)
    }

    func start() {
        health.requestAuthorization()
        ble.start()
    }
}

@main
struct OpenWristApp: App {
    @StateObject private var services = Services()

    var body: some Scene {
        WindowGroup {
            RootView(services: services)
                .onAppear { services.start() }
        }
    }
}
