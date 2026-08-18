import Foundation
import Combine

enum ConnectionState: String {
    case idle = "Not connected"
    case scanning = "Scanning…"
    case connecting = "Connecting…"
    case connected = "Connected"
}

// Single source of truth the UI observes. Updated on the main actor by the
// BLE manager as notifications arrive.
@MainActor
final class WatchState: ObservableObject {
    @Published var connection: ConnectionState = .idle
    @Published var steps: UInt32 = 0
    @Published var activeMinutes: UInt16 = 0
    @Published var batteryPct: UInt8 = 0
    @Published var charging = false
    @Published var fwVersion: String = "—"
    @Published var lastError: String?
}
