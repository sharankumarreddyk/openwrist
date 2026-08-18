// TOTP (RFC 6238) + HOTP (RFC 4226) over HMAC-SHA1 — the offline 2FA
// authenticator (M9). Works for any TOTP account, including Microsoft/Google/
// GitHub/AWS enrolled as "other authenticator app". Portable C, host-tested.
#pragma once
#include <stdint.h>
#include <stddef.h>

// HMAC-SHA1 of msg under key -> out[20].
void hmac_sha1(const uint8_t *key, size_t key_len,
               const uint8_t *msg, size_t msg_len, uint8_t out[20]);

// Decode a base32 secret (RFC 4648; spaces and lowercase tolerated, padding
// ignored) into bytes. Returns decoded length, or 0 on an invalid character.
size_t base32_decode(const char *in, uint8_t *out, size_t out_cap);

// HOTP code for a counter. `digits` is typically 6.
uint32_t hotp(const uint8_t *key, size_t key_len, uint64_t counter, int digits);

// TOTP code: HOTP over counter = unix_time / step_seconds (step usually 30).
uint32_t totp(const uint8_t *key, size_t key_len,
              uint64_t unix_time, uint32_t step_seconds, int digits);
