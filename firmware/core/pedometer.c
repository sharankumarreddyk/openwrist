#include "pedometer.h"

// Tunables. ponytail: hand-tuned defaults; recalibrate against real BMA423
// walking traces at M6 — a model can't guess the physical noise floor.
#define PED_ALPHA       0.10f   // low-pass factor for gravity estimate
#define PED_THRESH_HI   0.13f   // residual (g) that marks a step peak
#define PED_THRESH_LO   0.04f   // must fall below this to re-arm (hysteresis)
#define PED_REFRACT_MS  250     // min gap between steps (~4 steps/s cap)

void ped_init(pedometer_t *p) {
    p->avg = 1.0f;              // 1g at rest
    p->armed = true;
    p->last_step_ms = 0;
    p->steps = 0;
    p->initialized = false;
}

uint32_t ped_update(pedometer_t *p, float mag_g, uint32_t t_ms) {
    if (!p->initialized) { p->avg = mag_g; p->initialized = true; }
    p->avg += PED_ALPHA * (mag_g - p->avg);
    float residual = mag_g - p->avg;

    if (p->armed && residual > PED_THRESH_HI) {
        if (t_ms - p->last_step_ms >= PED_REFRACT_MS || p->last_step_ms == 0) {
            p->steps++;
            p->last_step_ms = t_ms;
        }
        p->armed = false;                       // wait for the dip before next
    } else if (!p->armed && residual < PED_THRESH_LO) {
        p->armed = true;
    }
    return p->steps;
}
