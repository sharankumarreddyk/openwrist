# Deep research

Everything below is the groundwork behind the design decisions. It captures
the prior art surveyed, how iPhone integration actually works, and the traps
that would otherwise cost weeks.

## 1. iPhone integration — the core problem, and its solution

iOS does not let arbitrary Bluetooth devices push data into it, and it will
not run your app in the background for long. But Apple publishes three GATT
services that any **bonded** BLE device may act as a client of, with zero app
involvement. This is exactly how the Pebble and every cheap fitness band talk
to an iPhone.

### ANCS — Apple Notification Center Service
Service UUID `7905F431-B5CE-4E99-A40F-4B1E122D00D0`. Three characteristics:

- **Notification Source** (notify) — fires on every add/modify/remove of a
  notification. Gives a 8-byte packet: event ID, flags, category (call,
  message, email, …), and a 4-byte notification UID.
- **Control Point** (write) — you write a "Get Notification Attributes"
  command with the UID to request the app identifier, title, subtitle, and
  message body.
- **Data Source** (notify) — the attribute data streams back here.

Flow: subscribe → get the UID + category from Notification Source → write a
Control Point request → read title/body from Data Source → render on screen.
For calls, the category is `IncomingCall` and Control Point supports
Positive/Negative actions (answer/decline hooks).

Requires **bonding/encryption** — the characteristics need authenticated
access, so pairing must complete first.

### CTS — Current Time Service
Standard BLE service `0x1805`. The watch reads/subscribes and gets the
phone's date/time, adjusted for timezone and DST. This is why the watch never
needs manual time-setting.

### AMS — Apple Media Service
Service UUID `89D3502B-0F36-433A-8EF4-C502AD55F8DC`. Lets the watch read
now-playing metadata (title, artist, album, playback state) and send remote
commands (play, pause, next, previous, volume). Turns the wrist into a media
remote.

### What needs the companion app (not ANCS)
- **Writing health data into Apple Health** — HealthKit is app-only. Solved by
  the self-built companion app (see §5). Steps/HR flow watch → app → HealthKit.
- **Weather, config, watch-face settings down to the watch** — a custom GATT
  profile between watch and companion app carries these.
- **Reliable long-lived background BLE** — the watch holds the connection as a
  peripheral advertising the "Solicited ANCS" UUID so iOS reconnects it.

## 2. Prior art surveyed (open-source, for reference only)

These informed the architecture. None are dependencies; they're reference
implementations to learn from.

**Firmware for this exact board (Waveshare AMOLED 2.06):**
- `joaquimorg/OLEDS3Watch` — smartwatch firmware using ESP-Brookesia. Closest
  reference for our stack.
- `Melaja/ESP32-S3-Smartwatch` — Arduino + LVGL + Arduino_GFX build for the
  same board. Good fallback reference if we ever drop to Arduino.

**Watch OSes / frameworks:**
- `espressif/esp-brookesia` — Espressif's official HMI framework; ships a
  smartwatch demo. This is our UI foundation.
- Open-SmartWatch (`open-smartwatch`) — mature OSW project, hardware + OS +
  3D-printed cases. Great for watch-face and app-model ideas.
- `OpenTimeWatch-Project/OpenTimeWatch-OS` — app/watchface/widget model ideas.
- `electricalgorithm/zephyr-watch` — Zephyr RTOS take, for power-management ideas.

**ANCS on ESP32 (notifications):**
- `espressif/esp-idf` → `examples/bluetooth/bluedroid/ble/ble_ancs` — the
  canonical native ANCS client. Primary reference for the notification module.
- `Smartphone-Companions/ESP32-ANCS-Notifications` — friendly Arduino library.
- `S-March/esp32_ANCS`, `m-hertig/esp32_ANCS` — earlier ANCS ports.

**Sensors:**
- Onboard 6-axis IMU handles step counting and wrist-raise detection.
- Optical HR (MAX30102-class) is documented as unreliable on the wrist across
  every project surveyed — treat continuous HR as experimental.

## 3. Battery + always-on — what the research says

- ESP32 active mode: ~100–240 mA. Deep sleep: ~10–150 µA (a ~1000× gap).
- Consensus across projects: no ESP32 watch exceeds ~2–3 days without
  aggressive sleep tuning; always-on full-brightness is measured in hours.
- AMOLED advantage: black pixels draw ~zero, so a mostly-black always-on face
  is far cheaper than an LCD backlight that's all-or-nothing. This is *the*
  reason to pick AMOLED over the LCD-based LILYGO T-Watch S3 for always-on.
- Winning pattern: light-sleep CPU + low-duty BLE connection + dim AMOLED
  clock as the "always-on" state; wake full UI on IMU wrist-raise or touch.

## 4. Framework decision

**ESP-IDF + ESP-Brookesia + LVGL**, not Arduino, because:
1. ANCS/AMS/CTS need fine BLE control — ESP-IDF's NimBLE/Bluedroid ANCS
   example is the reference; Arduino BLE wrappers fight you here.
2. Real power management (light/deep sleep, RTC wake sources, per-peripheral
   power domains) needs ESP-IDF.
3. ESP-Brookesia is Espressif's supported smartwatch UI framework with a demo
   for this board — we stand on maintained code, not a hobby fork.

Arduino + LVGL remains a documented fallback for faster first-light if ESP-IDF
onboarding stalls (see `Melaja/ESP32-S3-Smartwatch`).

## 5. Hardware selection — how the constraints decided it

Chip candidates for a BLE smartwatch:

| Chip | BLE/power | WiFi | Notes |
|------|-----------|------|-------|
| **nRF52832** (PineTime) | Best — years on a coin cell; ~2 µA sleep | No | Cheapest ($27), sealed IP67, HR onboard, mature InfiniTime firmware |
| **nRF52840** | Best — ~2 µA sleep, BLE 5.3 | No | More flash/RAM than 52832; bare dev boards only |
| **ESP32-S3** | Good — days on Li-po; WiFi is the drain | Yes | More CPU/RAM, WiFi+BLE, huge ecosystem |

On raw battery, nRF52 wins by a wide margin (~10× lower BLE current). So why
**ESP32-S3 / LILYGO T-Watch S3**? Because the *user's* constraints outrank raw
battery:

1. **USB-C or wireless charging.** PineTime charges only via a proprietary
   magnetic pogo dock — no USB-C, no Qi. The T-Watch S3 charges over USB-C.
2. **Parts available in India.** Robu.in is LILYGO's official India
   distributor — no import/customs friction. PineTime is import-only
   (Fab.To.Lab), pricier and slower.
3. **WiFi + BLE.** Enables WiFi-OTA and direct weather without the phone.
4. **No always-on required** → the ESP32's weaker battery is no longer the
   dealbreaker it would be for an always-on design; multi-day is fine.

Net: nRF52 is the battery-optimal chip, but T-Watch S3 is the
constraint-optimal *product*. The nRF52 respin stays in the backlog if
battery-weeks ever outrank WiFi + India convenience.

Wireless charging: no DIY watch ships Qi. It's an add-on — a BQ51013B-class Qi
receiver coil (Robu.in/Adafruit) wired to the battery. Documented as an
optional mod, not a v1 requirement.

## 6. iOS companion app + sideloading

The user builds and installs their own iOS app without a paid Apple Developer
account by **sideloading** onto their own device: a free Apple ID issues a
7-day signing certificate (re-sign weekly via Xcode or tools like Sideloadly/
SideStore). This unlocks HealthKit, CoreBluetooth, and a custom BLE profile —
everything ANCS can't do.

Structural reference: `InfiniTimeOrg/InfiniLink`, the open-source iOS
companion for InfiniTime, already does BLE connect + HealthKit + Apple Music
control + step charts. Good model for the plumbing (not a dependency).

## Sources

- [Bellafaire/ESP32-Smart-Watch](https://github.com/Bellafaire/ESP32-Smart-Watch)
- [Open-SmartWatch](https://open-smartwatch.github.io/)
- [OpenTimeWatch-OS](https://github.com/OpenTimeWatch-Project/OpenTimeWatch-OS)
- [electricalgorithm/zephyr-watch](https://github.com/electricalgorithm/zephyr-watch)
- [ESP-IDF ble_ancs example](https://github.com/espressif/esp-idf/blob/master/examples/bluetooth/bluedroid/ble/ble_ancs/README.md)
- [Smartphone-Companions/ESP32-ANCS-Notifications](https://github.com/Smartphone-Companions/ESP32-ANCS-Notifications)
- [S-March/esp32_ANCS](https://github.com/S-March/esp32_ANCS)
- [Receiving iOS Notifications via BLE — Hackaday](https://hackaday.io/project/169103-low-power-esp32-handheld/log/180691-receiving-ios-notifications-via-ble)
- [espressif/esp-brookesia](https://github.com/espressif/esp-brookesia)
- [joaquimorg/OLEDS3Watch](https://github.com/joaquimorg/OLEDS3Watch)
- [Melaja/ESP32-S3-Smartwatch](https://github.com/Melaja/ESP32-S3-Smartwatch)
- [ESP32-S3-Touch-AMOLED-2.06 — Waveshare](https://www.waveshare.com/esp32-s3-touch-amoled-2.06.htm)
- [How to Achieve 2-Year Battery Life with ESP32 — Hubble](https://hubble.com/community/guides/how-to-achieve-2-year-battery-life-with-esp32/)
- [LILYGO T-Watch Ultra — CNX Software](https://www.cnx-software.com/2026/04/20/lilygo-t-watch-ultra-an-ip65-rated-esp32-s3-smartwatch-with-2-01-inch-amoled-lora-and-gnss/)
- [PineTime — PINE64](https://pine64.org/devices/pinetime/)
- [PineTime in India — Fab.To.Lab](https://www.fabtolab.com/pine64-pinetime-open-source-smartwatch)
- [nRF52840 vs ESP32 BLE for wearables — Zbotic](https://zbotic.in/nrf52840-vs-esp32-ble-5-0-module-comparison-for-wearables/)
- [LILYGO T-Watch S3 — official product page](https://lilygo.cc/products/t-watch-s3)
- [LILYGO at Robu.in (India distributor)](https://robu.in/brand/lilygo/)
- [InfiniLink — iOS companion for InfiniTime](https://github.com/InfiniTimeOrg/InfiniLink)
- [Sideloadly — free iOS sideloading](https://sideloadly.io/)
- [Qi wireless receiver module — Adafruit](https://www.adafruit.com/product/1901)
