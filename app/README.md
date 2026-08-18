# OpenWrist companion iOS app

SwiftUI + CoreBluetooth + HealthKit. Sideloaded to your own iPhone with a free
Apple ID. Implements the app side of the [BLE protocol](../docs/PROTOCOL.md).

**Status:** builds and passes tests. Three tabs — **Watch** (status + steps +
weather), **Auth** (a working TOTP authenticator), **Settings** (config push).
BLE needs a real watch to talk to; everything else runs in the simulator now.

Features implemented:
- BLE manager (scan/connect/subscribe/write the `ble_ow` profile) + HealthKit step writer
- Settings → pushes `Config` to the watch; persisted in UserDefaults
- Weather via **Open-Meteo** (no API key) → pushes `Weather` to the watch
- **TOTP authenticator** — add via `otpauth://` link or base32 key, live codes
  with countdown; secrets stored in the **Keychain**. Works for Microsoft/
  Google/GitHub/AWS accounts (code mode)
- 8 XCTests (codec, RFC 6238 TOTP, base32, otpauth parse, WMO mapping)

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

Run the full test suite:
```bash
xcodebuild -project OpenWrist.xcodeproj -scheme OpenWrist \
  -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO
```

Run just the codec self-test (no Xcode needed):
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
