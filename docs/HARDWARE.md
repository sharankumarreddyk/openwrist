# Hardware

## Recommended board — Waveshare ESP32-S3-Touch-AMOLED-2.06 (~$45)

Watch-shaped development board, ships with a strap. Everything the firmware
needs is already on it, so this project is **firmware-only** — no soldering,
no PCB, no case CAD.

| Part | Spec |
|------|------|
| MCU | ESP32-S3R8 — dual-core LX7 @ up to 240 MHz, WiFi + BLE 5 |
| Memory | 8 MB PSRAM, 16 MB flash |
| Display | 2.06" AMOLED, 410×502, QSPI interface |
| Touch | Capacitive |
| Motion | 6-axis IMU (accel + gyro) — steps, wrist-raise |
| Clock | Hardware RTC (keeps time in deep sleep) |
| Power | Onboard PMIC + Li-po charger, battery connector |
| Audio | Dual digital mic array + codec |
| Wearable | Watch-shaped enclosure + strap |

### Why AMOLED, not the popular LILYGO T-Watch S3

The T-Watch S3 has a bigger community, but it uses an **LCD**. An LCD backlight
is all-or-nothing, so an "always-on" face burns full backlight power. AMOLED
lights pixels individually and draws ~zero on black — an always-on face that's
mostly black costs a fraction of the power. Since always-on is a hard
requirement, AMOLED wins.

## Alternatives (if you'd rather)

| Board | Trade-off |
|-------|-----------|
| **LILYGO T-Watch S3** (~$40) | Best community + case, most reference firmware. LCD, so worse always-on battery. Solid if always-on matters less than ecosystem. |
| **LILYGO T-Watch Ultra** (~$$) | 2.01" AMOLED, big 1100 mAh battery, IP65, LoRa/GNSS. Best battery + water resistance, pricier and newer (less reference firmware). |

## What to buy

1. The board above (with strap).
2. A USB-C cable (flashing + charging) — likely already have one.
3. Optional later: a small Li-po if you want to swap the included cell for
   more capacity (check the connector + PMIC limits first).

That's the entire bill of materials. No breadboard, no jumper wires, no
external sensors for v1 — health uses the onboard IMU.

## Things the board does NOT solve

- **Optical heart rate** — not onboard. Adding a MAX30102 later means wiring +
  a hole in the case; and wrist optical HR on ESP32 is unreliable regardless.
  Deferred, marked experimental.
- **Waterproofing** — the Waveshare enclosure is not rated. Don't shower with
  it. The T-Watch Ultra is the IP65 option if that matters.
