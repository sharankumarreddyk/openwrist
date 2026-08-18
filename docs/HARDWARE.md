# Hardware

## Recommended board — LILYGO T-Watch S3 (ESP32-S3)

Watch-shaped, ships with a strap and case. Firmware-only project — no
soldering or PCB required for v1. Chosen because it satisfies every hard
constraint: **USB-C charging, OTA software upgrades, and official
availability in India.**

> **Status (buying): awaiting restock.** Both ready-made watch boards below are
> currently out of stock in India (checked Robu.in + Amazon.in, Aug 2026).
> Plan is to buy **whichever restocks first** — the firmware is identical, only
> the display/IMU HAL differs. Target = either:
> - **LILYGO T-Watch S3** (LCD) — Robu.in
> - **Waveshare ESP32-S3-Touch-AMOLED-2.06** (AMOLED, w/ battery) — Robu.in / Amazon.in
>
> **Bare display boards (e.g. Waveshare 1.69" Touch LCD, ~₹3,995 in stock) are
> ruled out** — they have no case, and the only case option is a 3D print (no
> printer available). Straps are a non-issue: any standard 20/22mm spring-bar
> strap fits a cased watch board.

| Part | Spec |
|------|------|
| MCU | ESP32-S3 — dual-core LX7, WiFi 802.11 b/g/n + BLE 5 |
| Memory | 8 MB PSRAM, 16 MB flash |
| Display | 1.54" capacitive touch LCD (ST7789), 240×240 |
| Motion | BMA423 accelerometer — steps, wrist-raise |
| Audio | MAX98357A amp + speaker, microphone |
| Radio | WiFi + BLE (+ LoRa on the LoRa variant — ignore for a watch) |
| Charging | **USB-C** (also the flashing port) |
| Wearable | Watch case + strap |

### Where to buy (India)
- **Robu.in** — official LILYGO distributor in India. Search "LILYGO T-Watch S3".
- Get the **plain T-Watch S3** (not specifically the LoRa/US915 variant — LoRa
  is dead weight for a watch, though it doesn't hurt if that's what's in stock).

> Confirm the exact charge port and battery size on the live product page before
> buying — LILYGO revises variants. USB-C is standard on the S3 line.

## Charging

- **Primary: USB-C.** Charges and flashes over the same port. Done.
- **Optional wireless (Qi):** no DIY watch has Qi built in. To add it, wire a
  Qi **receiver coil module** (e.g. BQ51013B-based, sold on Robu.in/Adafruit)
  to the battery input and stick the coil on the back. Adds thickness. Treat
  as a later mod, not a v1 requirement.

## Software upgrades (OTA)

ESP32 supports Over-The-Air firmware updates over **WiFi or BLE**. So every
time you build something new, you push it wirelessly — no cable needed after
the first flash. Two paths, both documented at milestone M6:
- **WiFi OTA** — watch pulls a new `.bin` from your Mac/laptop on the same network.
- **BLE OTA** — your companion iOS app pushes the update over Bluetooth.

The very first flash is over USB-C; everything after can be wireless.

## Why not the alternatives

| Board | Why not (for your constraints) |
|-------|-------------------------------|
| **PineTime (nRF52)** | Best battery + cheapest, BUT charges via a proprietary magnetic dock (no USB-C, no Qi) and is import-only in India. Fails charging + sourcing. |
| **Waveshare ESP32-S3 AMOLED 2.06** | Nicer AMOLED, but you dropped always-on (AMOLED's main edge) and it's less watch-complete than the T-Watch. Fine as a second choice; also on Robu.in. |
| **nRF52840 bare board (XIAO/Feather)** | Best battery + BLE, on Robu.in, but it's a bare board — you assemble display, case, battery, charging yourself. Most hardware fuss. |

If battery life ever becomes the top priority over WiFi/India-convenience,
the nRF52 path is the upgrade — but it's a bigger hardware project.

## Bill of materials (v1)

1. LILYGO T-Watch S3 (with strap) — Robu.in.
2. A USB-C cable — probably already have one.
3. *Optional later:* Qi receiver coil module + a larger Li-po (check the
   connector/PMIC limits first).

No breadboard, no external sensors for v1 — motion/health use the onboard IMU.

## Not solved by this board

- **Optical heart rate** — the T-Watch S3 has no HR sensor. Adding a MAX30102
  means wiring + a case hole, and wrist optical HR on ESP32 is unreliable.
  Deferred, experimental. (PineTime *does* have HR onboard — a trade-off you
  accepted for USB-C + India sourcing.)
- **Waterproofing** — not rated. Don't swim with it.
