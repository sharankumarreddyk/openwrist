// Step counter from accelerometer magnitude. Low-pass to estimate gravity,
// then count upward threshold crossings of the residual with a refractory
// period. Deliberately simple; tune THRESH/refractory on real IMU data (M6).
#pragma once
#include <stdint.h>
#include <stdbool.h>

typedef struct {
    float avg;             // running gravity estimate (g)
    bool armed;            // ready to count the next peak
    uint32_t last_step_ms;
    uint32_t steps;
    bool initialized;
} pedometer_t;

void ped_init(pedometer_t *p);

// Feed one sample: |accel| in g at time t_ms. Returns the running step total.
uint32_t ped_update(pedometer_t *p, float mag_g, uint32_t t_ms);
