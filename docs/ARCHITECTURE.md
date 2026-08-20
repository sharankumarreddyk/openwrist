# Architecture

## System view

```
   ┌───────────────────────────┐      BLE (bonded)      ┌───────────────┐
   │          iPhone           │◄──────────────────────►│   OpenWrist   │
   │                           │  ANCS  notifications   │  T-Watch S3   │
   │  iOS built-in services:   │  CTS   time sync       │  ESP32-S3     │
   │  ANCS · CTS · AMS         │  AMS   music control   │               │
   │                           │                        │               │
   │  ┌─────────────────────┐  │  custom BLE profile:   │               │
   │  │ OpenWrist app        │◄─┼───────────────────────┤               │
   │  │ (sideloaded)         │  │  steps/HR → HealthKit  │               │
   │  │ SwiftUI · CoreBT ·   │  │  weather/config → watch│               │
   │  │ HealthKit            │  │  OTA trigger + push    │               │
   │  └─────────────────────┘  │                        └───────┬───────┘
   └───────────────────────────┘                                │ WiFi (opt)
                                                    weather · NTP · WiFi-OTA
```

Two BLE relationships on one bonded link:
1. **Watch as client of iOS** — consumes ANCS/CTS/AMS. Works even if the
   companion app is closed.
2. **Watch ↔ companion app** — a custom GATT profile for things iOS
   won't do natively: health data into HealthKit, config/weather down to the
   watch, and OTA update triggering.

WiFi is secondary and bursty (weather, NTP, WiFi-OTA) — never on continuously.

## Firmware layers (watch)

```
┌─────────────────────────────────────────────┐
│  UI  — ESP-Brookesia + LVGL                  │  watch faces, notif cards,
│        (screens, faces, app tiles)           │  music widget, settings
├─────────────────────────────────────────────┤
│  Services (FreeRTOS tasks → event queue)     │
│   • ble_ancs   notifications + call actions  │
│   • ble_cts    time sync                     │
│   • ble_ams    music info + control          │
│   • ble_ow     custom profile ↔ companion app│
│   • ota        WiFi + BLE firmware update     │
│   • wifi_svc   weather / NTP                  │
│   • motion     step count, wrist-raise       │
│   • power_mgr  sleep states, wake sources    │
├─────────────────────────────────────────────┤
│  HAL — ESP-IDF BSP for T-Watch S3            │  ST7789 display, touch,
│        (display, touch, BMA423 IMU, PMIC)    │  BMA423, PMIC/charger, audio
└─────────────────────────────────────────────┘
```

## Companion iOS app

SwiftUI + CoreBluetooth + HealthKit, sideloaded to your own iPhone with a free
Apple ID (re-sign every ~7 days). Responsibilities:
- Discover + connect to the watch's custom `ble_ow` GATT profile.
- Receive steps/HR/activity → write to **HealthKit**.
- Send weather (from any weather API), config, and watch-face choices down.
- Host firmware `.bin`s and push **BLE-OTA** updates; or tell the watch to
  pull a **WiFi-OTA** update.

Reference: `InfiniTimeOrg/InfiniLink` (open-source iOS companion for a
different watch) is a good structural model for the BLE + HealthKit plumbing.

## BLE design

- Watch role: **peripheral**, advertising the ANCS solicitation UUID so iOS
  auto-reconnects after a drop; the companion app connects to the same device.
- Bonding: LE Secure Connections, stored in NVS. ANCS/AMS need encryption, so
  bonding completes before subscribing.
- One connection carries iOS services (ANCS/CTS/AMS) **and** the custom
  `ble_ow` profile.

## Power {#power}

**No always-on** (a deliberate choice for battery). The display is
off between interactions; the watch wakes on wrist-raise or touch.

| State | CPU | Display | BLE | Rough draw |
|-------|-----|---------|-----|-----------|
| Active UI | full | on | connected | 100–240 mA |
| Idle (screen off) | light sleep | off | connected, low duty | single-digit mA |
| Deep sleep | off (RTC only) | off | disconnected | 10–150 µA |

**Transitions:**
- Wrist-raise (IMU) or touch → Active UI.
- Inactivity timeout → screen off, light sleep, BLE stays connected (so
  notifications still arrive and buzz).
- Long inactivity / very low battery → deep sleep; wakes on IMU tap or button.

**Rules that keep it alive:**
- WiFi off except during an explicit weather/OTA/NTP burst.
- BLE connection interval widened when idle (fewer radio wakeups).
- No animations or polling while the screen is off.

Realistic target: **multiple days** on a charge with normal notification
traffic. It's still an ESP32 with WiFi — days, not the weeks an nRF52 gives.

## Data & storage

- **NVS** — BLE bond, settings, watch-face choice, WiFi creds, step history.
- No filesystem/db for v1. Add LittleFS only if faces ship as loadable assets
  later. (YAGNI until then.)

## Out of scope for v1

- Optical heart rate (not on this board; unreliable on wrist).
- On-watch third-party app store (ESP-Brookesia supports it; defer until the
  core companion experience is solid).

<!-- ponytail: HealthKit sync moved IN scope once a companion app was on the
     table — it's the only way steps/HR reach Apple Health. -->
