# OpenWrist companion iOS app

SwiftUI + CoreBluetooth + HealthKit. Sideloaded to your own iPhone with a free
Apple ID (re-sign ~weekly). Built at **M5** — see
[`../docs/ROADMAP.md`](../docs/ROADMAP.md).

> No source yet. This holds the plan; the Xcode project lands at M5.

## What it does

- Connects to the watch's custom `ble_ow` GATT profile.
- Receives steps/HR/activity → writes to **Apple HealthKit**.
- Sends weather, config, and watch-face settings down to the watch.
- Hosts firmware `.bin`s and pushes **BLE-OTA** updates (or triggers WiFi-OTA).

## Sideloading (no paid developer account)

1. Open the project in **Xcode** on a Mac, sign in with a free Apple ID under
   *Signing & Capabilities* (personal team).
2. Plug in the iPhone, select it, and Run — Xcode signs with a 7-day cert.
3. Trust the developer profile on the phone: *Settings → General → VPN &
   Device Management*.
4. Re-run before the 7 days lapse to renew. No Mac? `Sideloadly` / `SideStore`
   do the same from a prebuilt `.ipa`.

## Reference

`InfiniTimeOrg/InfiniLink` (open source) — same BLE + HealthKit + music-control
shape for a different watch. Structural model, not a dependency.
