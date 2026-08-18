# OpenWrist companion iOS app

SwiftUI + CoreBluetooth + HealthKit. Sideloaded to your own iPhone with a free
Apple ID. Implements the app side of the [BLE protocol](../docs/PROTOCOL.md).

**Status:** foundation built and compiling (protocol codec, BLE manager,
HealthKit writer, status UI). BLE needs a real watch to talk to — until then
the UI runs and the codec is unit-tested.

## What's here

```
app/
  project.yml                     # XcodeGen spec (the .xcodeproj is generated)
  OpenWrist/
    OpenWristApp.swift            # @main, wires the services together
    Protocol/Packets.swift        # wire codec (Foundation-only, testable)
    Protocol/GATT.swift           # CBUUIDs for the OpenWrist profile
    BLE/BLEManager.swift          # scan / connect / subscribe / write
    Health/HealthKitManager.swift # writes steps into Apple Health
    State/WatchState.swift        # observable UI state
    Views/ContentView.swift       # status + controls
    OpenWrist.entitlements        # HealthKit
  Tests/ProtocolSelfTest.swift    # runnable codec check
```

## Build

```bash
brew install xcodegen              # once
cd app && xcodegen                 # generates OpenWrist.xcodeproj
open OpenWrist.xcodeproj           # then Run in Xcode
```

Command-line build (simulator, no signing):
```bash
xcodebuild -project OpenWrist.xcodeproj -scheme OpenWrist \
  -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' \
  build CODE_SIGNING_ALLOWED=NO
```

Run the codec self-test (no Xcode needed):
```bash
swiftc OpenWrist/Protocol/Packets.swift Tests/ProtocolSelfTest.swift -o /tmp/owtest && /tmp/owtest
```

## Sideloading to your iPhone (no paid account)

1. In Xcode → target *Signing & Capabilities*, sign in with a free Apple ID
   (personal team), and add the **HealthKit** capability.
2. Plug in the iPhone, pick it as the run destination, press Run — Xcode signs
   with a 7-day certificate.
3. Trust the profile on the phone: *Settings → General → VPN & Device Management*.
4. Re-run before the 7 days lapse to renew.

CoreBluetooth doesn't work in the simulator — test BLE on the real device once
the watch firmware is flashed.

## Reference
`InfiniTimeOrg/InfiniLink` — same BLE + HealthKit shape for a different watch.
Structural model, not a dependency.
