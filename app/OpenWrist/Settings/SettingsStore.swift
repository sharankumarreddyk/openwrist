import Foundation

// Watch config the user controls, persisted locally and pushed over ble_ow.
@MainActor
final class SettingsStore: ObservableObject {
    @Published var use24h: Bool { didSet { save() } }
    @Published var brightness: Double { didSet { save() } }   // 0–100
    @Published var watchFaceId: Int { didSet { save() } }      // 0…faceCount-1

    static let faceCount = 3
    private let d = UserDefaults.standard

    init() {
        use24h = d.object(forKey: "use24h") as? Bool ?? true
        brightness = d.object(forKey: "brightness") as? Double ?? 60
        watchFaceId = d.integer(forKey: "watchFaceId")
    }

    var packet: ConfigPacket {
        ConfigPacket(use24h: use24h,
                     brightness: UInt8(min(max(brightness, 0), 100).rounded()),
                     watchFaceId: UInt8(watchFaceId))
    }

    private func save() {
        d.set(use24h, forKey: "use24h")
        d.set(brightness, forKey: "brightness")
        d.set(watchFaceId, forKey: "watchFaceId")
    }
}
