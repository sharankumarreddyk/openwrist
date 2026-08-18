# W1 — an open ESP32 smartwatch for iPhone

A DIY smartwatch built on an ESP32-S3 AMOLED wearable board that talks to an
iPhone over Bluetooth LE — **no iOS app, no App Store, no developer account**.
It reads notifications, calls, time, and music straight from iOS using Apple's
own built-in BLE services.

> Status: **planning + scaffold**. Hardware not yet purchased. See
> [`docs/ROADMAP.md`](docs/ROADMAP.md) for what's built and what's next.

## Why this is feasible

The hard part of any iPhone accessory is that iOS is a walled garden. The
unlock is that Apple ships three standard BLE services that *any* bonded
device may consume — no app required:

| Service | What it gives the watch |
|---------|-------------------------|
| **ANCS** (Apple Notification Center Service) | Every notification: iMessage, WhatsApp, calls, calendar, app alerts — title, body, app name, and incoming-call actions |
| **CTS** (Current Time Service) | Wall-clock time, auto-synced from the phone. No manual setting, handles DST |
| **AMS** (Apple Media Service) | Now-playing track/artist + play/pause/skip control from the wrist |

The watch is a BLE **peripheral** that bonds once with the iPhone, then acts as
a **client** of these three services. That's the whole backbone.

## Features (planned)

- 🔔 iPhone notifications + caller ID on the wrist (ANCS)
- 🕐 Auto time sync + multiple watch faces, AMOLED always-on (CTS)
- 🎵 Music control — track info, play/pause/skip (AMS)
- 👟 Step counting via the onboard 6-axis IMU
- ❤️ Heart rate — *experimental* (optical wrist HR on ESP32 is noisy; see roadmap)
- 🌤️ WiFi extras: weather, NTP time fallback, OTA firmware updates
- 🔋 Aggressive power management (see the honest battery section below)

Health sensing is deliberately a *secondary* feature — the focus is the
phone-companion experience (notifications, time, music, glanceable info).

## The battery reality (read this)

No ESP32 watch lasts like an Apple Watch. Physics + an AMOLED + a small
battery set a hard ceiling. Honest targets on this board:

- **Tilt/tap-to-wake mode:** ~2–3 days
- **Always-on dim mode:** ~1 day (AMOLED draws ~nothing on black pixels, so
  the always-on face is mostly black with a dim time readout)
- **Always-on, full brightness:** hours — don't.

The firmware treats "always-on" as a *low-power dim clock* with light-sleep
CPU and low-duty BLE, then wakes the full UI on wrist-raise or tap. See
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md#power) for the strategy.

## Hardware

**Waveshare ESP32-S3-Touch-AMOLED-2.06** (~$45) — watch-shaped, strap
included. ESP32-S3R8 (8MB PSRAM), 410×502 AMOLED, capacitive touch, 6-axis
IMU, RTC, PMIC/charger, dual mics. Full rationale and alternatives in
[`docs/HARDWARE.md`](docs/HARDWARE.md).

## Firmware stack

ESP-IDF + ESP-Brookesia (Espressif's smartwatch HMI framework) + LVGL.
Chosen over Arduino for native ANCS support and real deep-sleep power control.
Rationale in [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Docs

- [`docs/RESEARCH.md`](docs/RESEARCH.md) — deep research, prior art, BLE service details
- [`docs/HARDWARE.md`](docs/HARDWARE.md) — board choice, specs, what to buy
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — system + firmware design, power strategy
- [`docs/ROADMAP.md`](docs/ROADMAP.md) — milestones, current status

## License

MIT — see [`LICENSE`](LICENSE).
