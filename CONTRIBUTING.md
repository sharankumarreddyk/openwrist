# Contributing to OpenWrist

Thanks for your interest! OpenWrist has two codebases:

- **`firmware/`** — ESP32 firmware. The portable `core/` is plain C with host
  tests; board layers use ESP-IDF.
- **`app/`** — the iOS companion app (SwiftUI, generated from `project.yml` via
  XcodeGen).

## Before you start

- The BLE wire format is defined in [`docs/PROTOCOL.md`](docs/PROTOCOL.md). Any
  change to a packet layout must update **both** the C codec (`firmware/core/
  ble_ow.*`) and the Swift codec (`app/OpenWrist/Protocol/Packets.swift`) and
  their tests in the same PR.
- Read [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the module layout and
  the power model.

## Building & testing

Firmware core (no ESP-IDF required):
```bash
make -C firmware test
```

iOS app:
```bash
brew install xcodegen
cd app && xcodegen
xcodebuild -project OpenWrist.xcodeproj -scheme OpenWrist \
  -destination 'platform=iOS Simulator,name=iPhone 17' test CODE_SIGNING_ALLOWED=NO
```

CI runs both on every PR — see [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

## Pull requests

1. Fork and branch from `main`.
2. Keep changes focused; match the surrounding style.
3. Add or update tests for any non-trivial logic. Both test suites must pass.
4. Don't commit generated artifacts (`app/OpenWrist.xcodeproj`, build output) —
   they're gitignored.
5. Describe what changed and why. Reference an issue if there is one.

## Commit style

Short imperative subject (e.g. "Add AMS media widget"), details in the body if
needed.

## Scope

The reference hardware is an ESP32-S3 watch board (see
[`docs/HARDWARE.md`](docs/HARDWARE.md)). Support for other boards is welcome via
the firmware's board layer; keep the portable `core/` board-independent.
