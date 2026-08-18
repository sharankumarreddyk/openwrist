// Host tests for the board-agnostic firmware core. Build + run:
//   make -C firmware test
#include "../core/ble_ow.h"
#include "../core/totp.h"
#include "../core/pedometer.h"
#include <stdio.h>
#include <string.h>
#include <math.h>

static int failures = 0;
#define CHECK(cond, msg) do { \
    if (cond) { printf("  ok  %s\n", msg); } \
    else { printf("  FAIL %s  (%s:%d)\n", msg, __FILE__, __LINE__); failures++; } \
} while (0)

// ---- BLE codec: same byte vectors the Swift side (Packets.swift) asserts ----
static void test_ble_ow(void) {
    printf("ble_ow codec\n");
    uint8_t buf[8];

    ow_step_update_t s = { .steps = 200000, .active_minutes = 30 };  // 0x00030D40
    size_t n = ow_encode_step(&s, buf, sizeof buf);
    uint8_t exp_step[] = {0x40, 0x0D, 0x03, 0x00, 0x1E, 0x00};
    CHECK(n == 6 && memcmp(buf, exp_step, 6) == 0, "encode step");

    ow_status_t st = { .battery_pct = 72, .charging = true, .fw_version = 0x0001 };
    n = ow_encode_status(&st, buf, sizeof buf);
    uint8_t exp_status[] = {72, 1, 0x01, 0x00};
    CHECK(n == 4 && memcmp(buf, exp_status, 4) == 0, "encode status");

    uint8_t cfg_bytes[] = {1, 100, 2};
    ow_config_t c;
    CHECK(ow_decode_config(cfg_bytes, 3, &c) && c.use_24h && c.brightness == 100
          && c.watch_face_id == 2, "decode config");

    uint8_t wx_bytes[] = {0xCE, 0xFF, 2, 80};   // -5.0C, clouds, 80%
    ow_weather_t w;
    CHECK(ow_decode_weather(wx_bytes, 4, &w) && w.temp_c_x10 == -50
          && w.condition_code == 2 && w.humidity_pct == 80, "decode weather");

    CHECK(!ow_decode_config(cfg_bytes, 2, &c), "reject short config");
}

// ---- TOTP: RFC 6238 Appendix B vectors (SHA1, 8 digits, secret ascii) ----
static void test_totp(void) {
    printf("totp (RFC 6238)\n");
    const uint8_t *key = (const uint8_t *)"12345678901234567890";
    size_t klen = 20;
    struct { uint64_t t; uint32_t code; } v[] = {
        {59,          94287082},
        {1111111109,   7081804},
        {1111111111,  14050471},
        {1234567890,  89005924},
        {2000000000,  69279037},
        {20000000000, 65353130},
    };
    for (size_t i = 0; i < sizeof v / sizeof v[0]; i++) {
        uint32_t got = totp(key, klen, v[i].t, 30, 8);
        char msg[64];
        snprintf(msg, sizeof msg, "T=%llu -> %08u", (unsigned long long)v[i].t, got);
        CHECK(got == v[i].code, msg);
    }

    // base32 secret decodes to the same key, and drives the same code.
    uint8_t dec[32];
    size_t dn = base32_decode("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", dec, sizeof dec);
    CHECK(dn == 20 && memcmp(dec, key, 20) == 0, "base32 decode secret");
    CHECK(totp(dec, dn, 59, 30, 8) == 94287082, "totp from base32 secret");

    CHECK(base32_decode("!!bad!!", dec, sizeof dec) == 0, "reject bad base32");
}

// ---- pedometer: synthetic 2 Hz walk, 5 s @ 50 Hz => ~10 steps ----
static void test_pedometer(void) {
    printf("pedometer\n");
    pedometer_t p;
    ped_init(&p);
    const int hz = 50;
    const float freq = 2.0f;   // steps per second
    for (int i = 0; i < hz * 5; i++) {
        float t = (float)i / hz;
        float mag = 1.0f + 0.30f * sinf(2.0f * 3.14159265f * freq * t);
        ped_update(&p, mag, (uint32_t)(t * 1000.0f));
    }
    char msg[48];
    snprintf(msg, sizeof msg, "10 expected, got %u", p.steps);
    CHECK(p.steps >= 8 && p.steps <= 12, msg);

    // At rest (constant 1g), no steps.
    pedometer_t q; ped_init(&q);
    for (int i = 0; i < hz * 5; i++) ped_update(&q, 1.0f, (uint32_t)(i * 20));
    CHECK(q.steps == 0, "no steps at rest");
}

int main(void) {
    test_ble_ow();
    test_totp();
    test_pedometer();
    printf(failures ? "\n%d FAILED\n" : "\nall core tests passed\n", failures);
    return failures ? 1 : 0;
}
