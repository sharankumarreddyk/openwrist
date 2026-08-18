# Roadmap

Milestones are ordered so each one is independently useful and testable on
real hardware. **Nothing past M0 can be verified until the board arrives** —
firmware for hardware you don't have is untestable, so we scaffold now and
implement each milestone against the physical watch.

## Status legend
✅ done · 🚧 in progress · ⬜ not started · 🧪 experimental

## M0 — Planning & scaffold ✅
- ✅ Research (iPhone BLE services, prior art, battery reality)
- ✅ Board + framework decisions documented
- ✅ Repo, docs, license
- ⬜ Order the Waveshare ESP32-S3-Touch-AMOLED-2.06

## M1 — First light ⬜
Goal: flash the board, prove the toolchain, draw something.
- ESP-IDF + ESP-Brookesia project builds and flashes
- Display + touch working via the board BSP
- A single static watch face renders
- Battery % read from PMIC
- *Test:* watch boots to a clock face, touch registers.

## M2 — The backbone: notifications ⬜
Goal: the whole reason this exists.
- BLE peripheral advertises + bonds with iPhone (persisted in NVS)
- ANCS: subscribe, pull title/body/app, render notification cards
- Incoming-call category shows caller + answer/decline (decline action wired)
- Vibration on notify
- *Test:* an iMessage and a call show on the wrist.

## M3 — Time & faces ⬜
- CTS time sync from iPhone (no manual set)
- 2–3 swipeable watch faces
- Always-on dim clock state (power_mgr wired to IMU wrist-raise)
- *Test:* time is correct after a reboot with no WiFi; wrist-raise wakes UI.

## M4 — Music ⬜
- AMS now-playing widget (track/artist/state)
- Play/pause/next/previous from the watch
- *Test:* control Apple Music / Spotify from the wrist.

## M5 — Motion & health (secondary) ⬜ 🧪
- IMU step counter + daily step tile
- Wrist-raise gesture tuning
- 🧪 Optional HR only if a sensor is added later — marked experimental
- *Test:* step count tracks a known walk within reason.

## M6 — WiFi extras ⬜
- WiFi provisioning (SoftAP or BLE-provisioned creds → NVS)
- Weather widget (OpenWeatherMap)
- NTP time fallback when iPhone absent
- OTA firmware updates
- *Test:* weather shows; OTA pushes a new build wirelessly.

## M7 — Polish ⬜
- Settings screen (brightness, faces, WiFi, timeouts)
- Power tuning pass against measured battery life
- Do-not-disturb / notification filtering
- Charging screen

## Backlog / maybe-never (YAGNI until asked)
- Companion iOS app for Apple Health sync
- On-watch third-party app model (ESP-Brookesia)
- LoRa/GNSS (would need T-Watch Ultra hardware)

---

### Next action
Order the board (`docs/HARDWARE.md`). Once it's in hand, start M1 — the
`firmware/` directory holds the scaffold and setup notes.
