# Architecture

## System view

```
        ┌──────────────────────────┐         BLE (bonded)        ┌───────────────┐
        │         iPhone           │◄───────────────────────────►│      W1       │
        │                          │  ANCS  notifications/calls   │  ESP32-S3     │
        │  iOS built-in services:  │  CTS   time sync             │  AMOLED watch │
        │  ANCS · CTS · AMS        │  AMS   music info/control    │               │
        └──────────────────────────┘                             └───────┬───────┘
                                                                          │ WiFi (opt)
                                                          weather · NTP · OTA updates
```

The watch is a BLE **peripheral** that bonds once with the iPhone, then
consumes iOS's ANCS/CTS/AMS as a **client**. WiFi is a secondary,
occasionally-on channel for weather, NTP fallback, and OTA — never on
continuously (it's the biggest battery drain).

## Firmware layers

```
┌─────────────────────────────────────────────┐
│  UI  — ESP-Brookesia + LVGL                  │  watch faces, notification cards,
│        (screens, watch faces, app tiles)     │  music widget, settings
├─────────────────────────────────────────────┤
│  Services                                    │
│   • ble_ancs   notifications + call actions  │
│   • ble_cts    time sync                     │
│   • ble_ams    media info + control          │
│   • wifi_svc   weather / NTP / OTA           │
│   • motion     step count, wrist-raise       │
│   • power_mgr  sleep states, wake sources    │
├─────────────────────────────────────────────┤
│  HAL — ESP-IDF BSP for the board             │  display QSPI, touch, IMU, RTC,
│        (display, touch, IMU, RTC, PMIC)      │  PMIC/battery, vibration
└─────────────────────────────────────────────┘
```

Each service is an independent FreeRTOS task posting events onto a queue the
UI consumes. Keeps BLE/sensor timing off the render loop.

## BLE design

- Role: **peripheral**, advertising the ANCS solicitation UUID so iOS
  auto-reconnects after a drop.
- Bonding: LE Secure Connections; store the bond in NVS so re-pairing survives
  reboots. ANCS/AMS characteristics require encryption, so bonding must
  complete before subscribing.
- One connection carries all three services. Subscribe to ANCS Notification
  Source + Data Source, CTS, and AMS entity-update characteristics.
- Reference: ESP-IDF `ble_ancs` example (Bluedroid/NimBLE).

## Power {#power}

The single most important design axis. "Always-on" is implemented as a
*low-power dim clock*, not a live full-brightness UI.

**States:**

| State | CPU | Display | BLE | Rough draw |
|-------|-----|---------|-----|-----------|
| Active UI | 240 MHz | full brightness | connected | 100–240 mA |
| Always-on (dim) | light sleep, tick on RTC | dim, mostly-black clock | connected, low duty | tens of mA |
| Idle/sleep | light sleep | off | connected, low duty | single-digit mA |
| Deep sleep | off (RTC only) | off | disconnected | 10–150 µA |

**Transitions:**
- Wrist-raise (IMU) or touch → Active UI.
- Timeout with wrist down → Always-on dim, then Idle.
- Long inactivity / very low battery → Deep sleep (RTC keeps time; wakes on
  IMU tap or button).

**Rules that keep it alive:**
- WiFi is off except during an explicit weather/OTA/NTP burst.
- BLE connection interval widened when idle (fewer radio wakeups).
- AMOLED always-on face is mostly black by design (AMOLED draws ~0 on black).
- Brightness auto-dims; no animations in the always-on state.

Honest targets: ~2–3 days tilt-to-wake, ~1 day always-on-dim. See
[`RESEARCH.md`](RESEARCH.md#3-battery--always-on--what-the-research-says).

<!-- ponytail: power states are the ceiling here; if a day of always-on isn't
     enough, the upgrade path is the T-Watch Ultra's 1100mAh cell, not code. -->

## Data & storage

- **NVS** — BLE bond, settings, watch-face choice, WiFi creds, step history.
- No filesystem/db needed for v1. Add LittleFS only if watch faces ship as
  loadable assets later. (YAGNI until then.)

## What's intentionally out of scope for v1

- Apple Health sync (needs a companion iOS app — HealthKit is app-only).
- Optical heart rate (not on the board; unreliable on wrist).
- On-watch app store / third-party apps (ESP-Brookesia supports an app model;
  defer until the core companion experience is solid).
