// OpenWrist custom BLE profile — packet codec (watch side).
// Mirror of docs/PROTOCOL.md and the app's Packets.swift. Portable C, no
// ESP-IDF dependency, so it builds and is unit-tested on the host.
// All multi-byte fields are little-endian.
#pragma once
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

typedef struct { uint32_t steps; uint16_t active_minutes; } ow_step_update_t;
typedef struct { uint8_t battery_pct; bool charging; uint16_t fw_version; } ow_status_t;
typedef struct { bool use_24h; uint8_t brightness; uint8_t watch_face_id; } ow_config_t;
typedef struct { int16_t temp_c_x10; uint8_t condition_code; uint8_t humidity_pct; } ow_weather_t;

// Watch -> app (notify): encode into `out` (cap bytes). Returns bytes written, 0 if too small.
size_t ow_encode_step(const ow_step_update_t *s, uint8_t *out, size_t cap);
size_t ow_encode_status(const ow_status_t *s, uint8_t *out, size_t cap);

// App -> watch (write): decode. Returns false if the payload is too short.
bool ow_decode_config(const uint8_t *in, size_t len, ow_config_t *out);
bool ow_decode_weather(const uint8_t *in, size_t len, ow_weather_t *out);
