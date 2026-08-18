#include "totp.h"
#include "sha1.h"
#include <string.h>

void hmac_sha1(const uint8_t *key, size_t key_len,
               const uint8_t *msg, size_t msg_len, uint8_t out[20]) {
    uint8_t k[SHA1_BLOCK_LEN] = {0};
    if (key_len > SHA1_BLOCK_LEN) {
        sha1(key, key_len, k);                 // long keys are hashed down
    } else {
        memcpy(k, key, key_len);
    }

    uint8_t ipad[SHA1_BLOCK_LEN], opad[SHA1_BLOCK_LEN];
    for (int i = 0; i < SHA1_BLOCK_LEN; i++) {
        ipad[i] = k[i] ^ 0x36;
        opad[i] = k[i] ^ 0x5C;
    }

    // inner = sha1(ipad || msg)
    uint8_t inner_in[SHA1_BLOCK_LEN + 8 + 64];  // block + counter/message; sized for our use
    uint8_t inner[SHA1_DIGEST_LEN];
    // Build inner buffer dynamically to any msg_len via a two-pass sha1 would be
    // cleaner, but msg_len here is small (<= 8 for HOTP). Keep it simple + bounded.
    if (msg_len > 64) msg_len = 64;             // ponytail: HOTP messages are 8 bytes
    memcpy(inner_in, ipad, SHA1_BLOCK_LEN);
    memcpy(inner_in + SHA1_BLOCK_LEN, msg, msg_len);
    sha1(inner_in, SHA1_BLOCK_LEN + msg_len, inner);

    // out = sha1(opad || inner)
    uint8_t outer_in[SHA1_BLOCK_LEN + SHA1_DIGEST_LEN];
    memcpy(outer_in, opad, SHA1_BLOCK_LEN);
    memcpy(outer_in + SHA1_BLOCK_LEN, inner, SHA1_DIGEST_LEN);
    sha1(outer_in, SHA1_BLOCK_LEN + SHA1_DIGEST_LEN, out);
}

size_t base32_decode(const char *in, uint8_t *out, size_t out_cap) {
    uint32_t buf = 0;
    int bits = 0;
    size_t n = 0;
    for (const char *p = in; *p; p++) {
        char c = *p;
        if (c == ' ' || c == '=' || c == '\t') continue;
        int v;
        if (c >= 'A' && c <= 'Z') v = c - 'A';
        else if (c >= 'a' && c <= 'z') v = c - 'a';
        else if (c >= '2' && c <= '7') v = c - '2' + 26;
        else return 0;                          // invalid character
        buf = (buf << 5) | (uint32_t)v;
        bits += 5;
        if (bits >= 8) {
            bits -= 8;
            if (n >= out_cap) return 0;
            out[n++] = (uint8_t)(buf >> bits);
        }
    }
    return n;
}

uint32_t hotp(const uint8_t *key, size_t key_len, uint64_t counter, int digits) {
    uint8_t msg[8];
    for (int i = 7; i >= 0; i--) { msg[i] = (uint8_t)(counter & 0xFF); counter >>= 8; }

    uint8_t mac[20];
    hmac_sha1(key, key_len, msg, 8, mac);

    int off = mac[19] & 0x0F;                   // dynamic truncation
    uint32_t bin = ((uint32_t)(mac[off]   & 0x7F) << 24) |
                   ((uint32_t)(mac[off+1] & 0xFF) << 16) |
                   ((uint32_t)(mac[off+2] & 0xFF) << 8)  |
                   ((uint32_t)(mac[off+3] & 0xFF));
    uint32_t mod = 1;
    for (int i = 0; i < digits; i++) mod *= 10;
    return bin % mod;
}

uint32_t totp(const uint8_t *key, size_t key_len,
              uint64_t unix_time, uint32_t step_seconds, int digits) {
    return hotp(key, key_len, unix_time / step_seconds, digits);
}
