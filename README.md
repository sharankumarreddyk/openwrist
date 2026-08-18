# W1 — an open ESP32 smartwatch for iPhone

A DIY smartwatch built on a LILYGO T-Watch S3 (ESP32-S3) that pairs with an
iPhone over Bluetooth LE, backed by a **self-built iOS companion app** you
sideload to your own phone (free Apple ID). It reads notifications, calls,
time, and music from iOS using Apple's built-in BLE services, and syncs
health/config through the companion app.

> Status: **planning + scaffold**. Hardware not yet purchased. See
> [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's built and what's next.

## Why this works

**Basics with no app** — iOS ships three standard BLE services any bonded
device may consume:

| Service | What the watch gets |
|---------|---------------------|
| **ANCS** | Every notification + incoming-call caller ID and actions |
| **CTS** | Wall-clock time, auto-synced (no manual setting, handles DST) |
| **AMS** | Now-playing track/artist + play/pause/skip control |

**Everything else via your companion app** — since you'll sideload your own
iOS app (free Apple ID, 7-day re-sign), it bridges what ANCS can't:
- Push step/HR data **into Apple Health** (HealthKit is app-only)
- Send weather, config, and watch-face settings to the watch over BLE
- Trigger **OTA firmware updates** so you flash new builds wirelessly

## Features (planned)

- 🔔 iPhone notifications + caller ID (ANCS)
- 🕐 Auto time sync + multiple watch faces (CTS) — **tap/tilt-to-wake**, no always-on
- 🎵 Music control from the wrist (AMS)
- 👟 Step counting via the onboard IMU → synced to Apple Health via the app
- ❤️ Heart rate — *not on this board*; experimental if added later
- 🌤️ Weather + config pushed from the companion app (or WiFi directly)
- ⬆️ OTA updates over WiFi or BLE — upgrade the watch whenever you build something
- 🔋 Multi-day battery (no always-on) — see below

Health sensing is deliberately *secondary* — the focus is the phone-companion
experience: notifications, time, music, glanceable info.

## Battery

You dropped always-on, which removes the biggest drain. With tap/tilt-to-wake,
light-sleep between wakes, and low-duty BLE, **multi-day battery is realistic**
on the T-Watch S3. Honest note: it's still an ESP32 with WiFi — expect days,
not the weeks an nRF52 watch would give. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#power).

## Hardware

**LILYGO T-Watch S3** — ESP32-S3, USB-C charging, WiFi + BLE, capacitive
touch, IMU, speaker/mic, strap included. **Available in India via Robu.in**
(official LILYGO distributor). Optional Qi wireless-charging mod documented.
Full rationale, alternatives, and BOM in [`docs/HARDWARE.md`](docs/HARDWARE.md).

## Firmware + app stack

- **Watch:** ESP-IDF + ESP-Brookesia (Espressif's smartwatch HMI framework) + LVGL.
- **Phone:** a SwiftUI + CoreBluetooth + HealthKit companion app, sideloaded.

Rationale in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Docs

- [`docs/RESEARCH.md`](docs/RESEARCH.md) — deep research, prior art, BLE services, hardware trade-offs
- [`docs/HARDWARE.md`](docs/HARDWARE.md) — board choice, charging, OTA, India sourcing
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — system + firmware + app design, power strategy
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — milestones, current status

## License

MIT — see [`LICENSE`](LICENSE).
