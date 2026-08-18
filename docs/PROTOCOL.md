# OpenWrist BLE protocol (`ble_ow`) — v0

The custom GATT profile between the watch and the companion iOS app. This is
the contract; the app (`app/`) and firmware (`firmware/`) both implement it.
iOS-standard services (ANCS/CTS/AMS) are separate and not redefined here.

All multi-byte fields are **little-endian**.

## Service

`E1F7A100-9C1E-4B2A-8B21-2A4F9C3D0001`

## Characteristics

| Char UUID (suffix) | Name | Dir | Props | Payload |
|---|---|---|---|---|
| `…0002` | Steps | watch → app | notify | `u32 steps`, `u16 activeMinutes` (6 bytes) |
| `…0003` | Status | watch → app | notify | `u8 batteryPct`, `u8 charging`, `u16 fwVersion` (4 bytes) |
| `…0004` | Config | app → watch | write | `u8 use24h`, `u8 brightness` (0–100), `u8 watchFaceId` (3 bytes) |
| `…0005` | Weather | app → watch | write | `i16 tempC_x10`, `u8 conditionCode`, `u8 humidityPct` (4 bytes) |

Full char UUIDs share the service base, differing in the last group
(`…0002`…`…0005`).

### Notes
- `tempC_x10` = temperature °C × 10 (e.g. 235 = 23.5 °C). Signed.
- `conditionCode`: 0 clear, 1 clouds, 2 rain, 3 snow, 4 thunder, 5 fog. (Maps
  from whatever weather API the app uses.)
- `fwVersion`: `(major<<8)|minor`, e.g. `0x0001` = v0.1.
- `charging`: 0 = on battery, 1 = charging.
- Steps notify cadence: on change, throttled to ≤ once/30 s by the watch.

## OTA (deferred to M5)
Firmware update uses a separate characteristic set defined when M5 lands
(chunked write + status notify). Not part of v0.

## Versioning
Bump the `-v0` on any payload change and update both implementations in the
same PR. The app reads `fwVersion` from Status to refuse mismatched watches.
