# Hardware

OpenWrist targets an ESP32-S3 watch-form development board. It is a
firmware-only project — no custom PCB or soldering required. Any board with a
touch display, a 6-axis IMU, WiFi/BLE, USB-C charging, and a Li-po works; the
firmware's board layer abstracts the specifics.

## Reference boards

| Board | Display | Notes |
|-------|---------|-------|
| **LILYGO T-Watch S3** | 1.54" LCD (ST7789), 240×240 touch | ESP32-S3, BMA423 IMU, speaker/mic, USB-C, strap + case included |
| **Waveshare ESP32-S3-Touch-AMOLED-2.06** | 2.06" AMOLED, 410×502 touch | ESP32-S3R8, 6-axis IMU, RTC, dual mics, USB-C, strap included |

Both are ESP32-S3, WiFi + BLE 5, USB-C, and run the same firmware stack
(ESP-IDF + ESP-Brookesia + LVGL). AMOLED draws ~zero on black pixels, which
helps if an always-on face is ever added; the LCD board is otherwise
equivalent for a tap/tilt-to-wake design.

## Other options

| Board | Trade-off |
|-------|-----------|
| **PineTime (nRF52832)** | Best battery, cheapest, HR onboard, sealed IP67 — but charges via a proprietary magnetic dock (no USB-C) and runs a different (non-ESP32) firmware stack. |
| **nRF52840 dev board + display** | Best battery + BLE, but a bare board: display, case, battery, and charging are DIY. |
| **LILYGO T-Watch Ultra** | Larger AMOLED, bigger battery, IP65 — pricier, newer. |

If battery life is the top priority over WiFi and the ESP32 ecosystem, the
nRF52 family is the better silicon; it is out of scope for this repository's
firmware.

## Charging

- **USB-C** is the primary path (also the flashing port).
- **Qi wireless** is not built into these boards. It can be added by wiring a
  Qi receiver-coil module (e.g. BQ51013B-based) to the battery input; this adds
  thickness and is an optional mod, not a requirement.

## Firmware updates (OTA)

ESP32 supports OTA over **WiFi or BLE**. After the first USB-C flash, new builds
can be delivered wirelessly — WiFi (watch pulls a `.bin`) or BLE (the companion
app pushes it). See milestone M5 in [`ROADMAP.md`](ROADMAP.md).

## Bill of materials

1. An ESP32-S3 watch board from the tables above (with strap).
2. A USB-C cable.
3. A Li-po battery if the chosen board ships without one (check the connector
   and PMIC limits before buying).
4. *Optional:* Qi receiver-coil module for wireless charging.

No breadboard or external sensors are needed for v1 — motion/health use the
onboard IMU.

## Not covered by these boards

- **Optical heart rate** — not present on the T-Watch S3 / Waveshare 2.06.
  Adding a MAX30102 requires wiring and a case opening, and wrist optical HR on
  ESP32 is unreliable. Deferred and experimental. (PineTime has HR onboard.)
- **Water resistance** — the reference boards are not rated. The T-Watch Ultra
  is the IP-rated option.
