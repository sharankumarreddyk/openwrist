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
- ⬜ Buy a ready-made watch board — **awaiting restock** of the LILYGO T-Watch
  S3 or Waveshare AMOLED 2.06 (both out of stock in India, Aug 2026)

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
- SwiftUI + CoreBluetooth app connects to the watch's custom `ble_ow` profile
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

## M9 — Free extras (no added hardware) ⬜
Pure-firmware features using hardware the T-Watch S3 already has (touch LCD,
IMU, mic, speaker, haptic, WiFi, BLE, RTC). Independent — build in any order.

**Phone tricks (BLE):**
- 📷 Camera shutter remote — watch advertises as a BLE HID keyboard and sends
  Volume-Up to fire the iPhone camera. (Coexists with the companion-app role.)
- 📵 Find my phone — watch → companion app → iPhone plays a loud sound.
- 🎞️ Presenter remote — BLE HID page-up/down for slides.

**Security:**
- 🔐 TOTP 2FA authenticator (RFC 6238) — 6-digit codes on the wrist, offline.
  Secrets in NVS, time from RTC/CTS. Works for any TOTP account, **including
  Microsoft/Azure/365 accounts enrolled as "other authenticator app".**
  Does NOT do push-approval / number-matching or passkeys (proprietary).

**Fitness from the IMU (no HR sensor):**
- Sleep tracking, fall detection, workout auto-detect, calorie estimate.
- Tap / wrist-gesture controls.

**WiFi widgets:**
- World clock, stock/crypto/news tickers.
- Smart-home remote (toggle lights / Home Assistant over HTTP/MQTT).
  (Weather lives in M7.)

**Utilities:**
- Timer, stopwatch, multi-alarm (haptic + speaker), calculator, bubble level
  (accelerometer), flashlight (white screen), currency/unit converter, a game.

*Test each:* code triggers the iPhone camera; a TOTP code matches Google/MS
Authenticator for the same secret; find-my-phone rings the phone.

## M10 — Polish ⬜
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
**Awaiting restock** of a ready-made watch board (LILYGO T-Watch S3 or Waveshare
AMOLED 2.06 — see [`HARDWARE.md`](HARDWARE.md)). Once one is in hand, start M1 —
the `firmware/` directory holds the scaffold and setup notes.
