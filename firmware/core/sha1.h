// Minimal SHA-1 (FIPS 180). Used only for HMAC-SHA1 in TOTP.
#pragma once
#include <stdint.h>
#include <stddef.h>

#define SHA1_DIGEST_LEN 20
#define SHA1_BLOCK_LEN  64

void sha1(const uint8_t *data, size_t len, uint8_t out[SHA1_DIGEST_LEN]);
