import Foundation

// Wire format for the OpenWrist BLE profile. See docs/PROTOCOL.md.
// Foundation-only on purpose so it stays unit-testable without CoreBluetooth.
// All multi-byte fields are little-endian.

struct StepUpdate: Equatable {
    var steps: UInt32
    var activeMinutes: UInt16

    static func decode(_ data: Data) -> StepUpdate? {
        let b = [UInt8](data)
        guard b.count >= 6 else { return nil }
        let steps = UInt32(b[0]) | UInt32(b[1]) << 8 | UInt32(b[2]) << 16 | UInt32(b[3]) << 24
        let mins = UInt16(b[4]) | UInt16(b[5]) << 8
        return StepUpdate(steps: steps, activeMinutes: mins)
    }
}

struct StatusUpdate: Equatable {
    var batteryPct: UInt8
    var charging: Bool
    var fwVersion: UInt16   // (major<<8)|minor

    var versionString: String { "\(fwVersion >> 8).\(fwVersion & 0xFF)" }

    static func decode(_ data: Data) -> StatusUpdate? {
        let b = [UInt8](data)
        guard b.count >= 4 else { return nil }
        let fw = UInt16(b[2]) | UInt16(b[3]) << 8
        return StatusUpdate(batteryPct: b[0], charging: b[1] != 0, fwVersion: fw)
    }
}

struct ConfigPacket: Equatable {
    var use24h: Bool
    var brightness: UInt8   // 0–100
    var watchFaceId: UInt8

    func encode() -> Data {
        Data([use24h ? 1 : 0, min(brightness, 100), watchFaceId])
    }
}

struct WeatherPacket: Equatable {
    var tempCx10: Int16     // °C × 10
    var conditionCode: UInt8
    var humidityPct: UInt8

    func encode() -> Data {
        let t = UInt16(bitPattern: tempCx10)
        return Data([UInt8(t & 0xFF), UInt8(t >> 8), conditionCode, min(humidityPct, 100)])
    }
}

// One runnable check (see app/Tests/ProtocolSelfTest.swift).
func openWristProtocolSelfTest() {
    let s = StepUpdate.decode(Data([0x40, 0x0D, 0x03, 0x00, 0x1E, 0x00]))!
    assert(s.steps == 0x00030D40 && s.activeMinutes == 30, "step decode")

    let st = StatusUpdate.decode(Data([72, 1, 0x01, 0x00]))!
    assert(st.batteryPct == 72 && st.charging && st.versionString == "0.1", "status decode")

    assert(ConfigPacket(use24h: true, brightness: 200, watchFaceId: 2).encode()
           == Data([1, 100, 2]), "config encode clamps brightness")

    // -5.0°C => -50 => two's complement 0xFFCE little-endian => CE FF
    assert(WeatherPacket(tempCx10: -50, conditionCode: 2, humidityPct: 80).encode()
           == Data([0xCE, 0xFF, 2, 80]), "weather encode signed temp")
}
