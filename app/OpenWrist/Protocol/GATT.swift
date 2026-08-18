import CoreBluetooth

// CBUUIDs for the OpenWrist custom profile. See docs/PROTOCOL.md.
enum OpenWristGATT {
    static let service = CBUUID(string: "E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0001")
    static let steps   = CBUUID(string: "E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0002") // notify
    static let status  = CBUUID(string: "E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0003") // notify
    static let config  = CBUUID(string: "E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0004") // write
    static let weather = CBUUID(string: "E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0005") // write
}
