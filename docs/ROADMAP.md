# Roadmap

Milestones are ordered so each is independently useful and testable on real
hardware. **Nothing past M0 can be verified until the board arrives** —
firmware for hardware you don't have is untestable, so we scaffold now and
implement each milestone against the physical watch.

## Status legend
✅ done · 🚧 in progress · ⬜ not started · 🧪 experimental

## M0 — Planning & scaffold ✅
- ✅ Research (iPhone BLE services, prior art, hardware trade-offs, battery)
- ✅ Constraint-driven board + framework decisions documented
- ✅ Repo, docs, license
- ⬜ Order the LILYGO T-Watch S3 (Robu.in)

## M1 — First light ⬜
Goal: flash the board over USB-C, prove the toolchain, draw something.
- ESP-IDF + ESP-Brookesia project builds and flashes
- Display + touch working via the board BSP
- A single static watch face renders
- Battery % read from PMIC
- *Test:* watch boots to a clock face, touch registers.

## M2 — The backbone: notifications ⬜
Goal: the whole reason this exists.
- BLE peripheral advertises + bonds with iPhone (persisted in NVS)
- ANCS: subscribe, pull title/body/app, render notification cards
- Incoming-call category shows caller + answer/decline actions
- Vibration/haptic on notify
- *Test:* an iMessage and a call show on the wrist.

## M3 — Time & faces ⬜
- CTS time sync from iPhone (no manual set)
- 2–3 swipeable watch faces
- Tap/tilt-to-wake wired (power_mgr + IMU wrist-raise; screen off when idle)
- *Test:* time correct after reboot with no WiFi; wrist-raise wakes UI; screen
  sleeps and battery holds overnight.

## M4 — Music ⬜
- AMS now-playing widget (track/artist/state)
- Play/pause/next/previous from the watch
- *Test:* control Apple Music / Spotify from the wrist.

## M5 — Companion iOS app + OTA ⬜
Goal: your own sideloaded app, and wireless upgrades.
- SwiftUI + CoreBluetooth app connects to the watch's custom `ble_w1` profile
- **BLE-OTA:** push a new firmware `.bin` from the app to the watch
- **WiFi-OTA** fallback: watch pulls a `.bin` over WiFi
- *Test:* build a trivial firmware change and flash it wirelessly, no cable.

## M6 — Motion & health → Apple Health ⬜ 🧪
- IMU step counter + daily step tile
- Companion app writes steps/activity to **HealthKit**
- 🧪 HR only if a sensor is added later — experimental
- *Test:* a walk's step count appears in Apple Health.

## M7 — WiFi/app extras ⬜
- Weather widget (via companion app push, or direct WiFi API)
- NTP time fallback when iPhone absent
- WiFi provisioning (BLE-provisioned creds → NVS)
- *Test:* weather shows on the watch.

## M8 — Polish ⬜
- Settings screen (brightness, faces, timeouts, WiFi)
- Power tuning pass against measured battery life
- Do-not-disturb / notification filtering
- Charging screen
- *Optional:* Qi wireless-charging coil mod (hardware)

## Backlog / maybe-never (YAGNI until asked)
- On-watch third-party app model (ESP-Brookesia)
- Optical HR hardware add-on
- nRF52 hardware respin if battery-weeks ever outranks WiFi + India convenience

---

### Next action
Order the LILYGO T-Watch S3 (see [`HARDWARE.md`](HARDWARE.md)). Once in hand,
start M1 — the `firmware/` directory holds the scaffold and setup notes.
