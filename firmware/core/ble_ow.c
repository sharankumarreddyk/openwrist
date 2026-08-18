#include "ble_ow.h"

size_t ow_encode_step(const ow_step_update_t *s, uint8_t *out, size_t cap) {
    if (cap < 6) return 0;
    out[0] = (uint8_t)(s->steps);
    out[1] = (uint8_t)(s->steps >> 8);
    out[2] = (uint8_t)(s->steps >> 16);
    out[3] = (uint8_t)(s->steps >> 24);
    out[4] = (uint8_t)(s->active_minutes);
    out[5] = (uint8_t)(s->active_minutes >> 8);
    return 6;
}

size_t ow_encode_status(const ow_status_t *s, uint8_t *out, size_t cap) {
    if (cap < 4) return 0;
    out[0] = s->battery_pct;
    out[1] = s->charging ? 1 : 0;
    out[2] = (uint8_t)(s->fw_version);
    out[3] = (uint8_t)(s->fw_version >> 8);
    return 4;
}

bool ow_decode_config(const uint8_t *in, size_t len, ow_config_t *out) {
    if (len < 3) return false;
    out->use_24h = in[0] != 0;
    out->brightness = in[1] > 100 ? 100 : in[1];
    out->watch_face_id = in[2];
    return true;
}

bool ow_decode_weather(const uint8_t *in, size_t len, ow_weather_t *out) {
    if (len < 4) return false;
    out->temp_c_x10 = (int16_t)((uint16_t)in[0] | ((uint16_t)in[1] << 8));
    out->condition_code = in[2];
    out->humidity_pct = in[3] > 100 ? 100 : in[3];
    return true;
}
