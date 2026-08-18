// Standalone runnable check for the wire codec — no Xcode needed:
//   swiftc app/OpenWrist/Protocol/Packets.swift app/Tests/ProtocolSelfTest.swift -o /tmp/owtest && /tmp/owtest
// Prints "protocol self-test OK" on success; a failed assert aborts.
@main
struct ProtocolSelfTest {
    static func main() {
        openWristProtocolSelfTest()
        print("protocol self-test OK")
    }
}
