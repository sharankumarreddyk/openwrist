# Firmware

ESP-IDF + ESP-Brookesia + LVGL for the LILYGO T-Watch S3 (ESP32-S3).
The iOS companion app lives in [`../app/`](../app) (added at M5).

> No source yet — implementation starts at **M1**, once the board is in hand.
> Writing firmware for hardware you can't flash is untestable guesswork, so
> this holds the setup path instead. Each milestone in
> [`../docs/ROADMAP.md`](../docs/ROADMAP.md) lands its code here.

## One-time setup (when the board arrives)

1. **Install ESP-IDF** (v5.x):
   ```bash
   mkdir -p ~/esp && cd ~/esp
   git clone -b v5.3 --recursive https://github.com/espressif/esp-idf.git
   ./esp-idf/install.sh esp32s3
   . ./esp-idf/export.sh          # run in every new shell (or alias it)
   ```

2. **Start from the board + framework references** (copy, then trim to ours):
   - Board BSP + examples: LILYGO T-Watch S3 repo (`Xinyuan-LilyGO/T-Watch-Deps`
     / `LilyGO/TTGO_TWatch_Library`) for display, touch, BMA423, PMIC pins.
   - UI framework: `espressif/esp-brookesia` (has a smartwatch example).
   - ANCS client: `esp-idf/examples/bluetooth/bluedroid/ble/ble_ancs`.
   - OTA: `esp-idf/examples/system/ota` (WiFi) + a BLE-OTA example for the app path.

3. **Build / flash / monitor:**
   ```bash
   idf.py set-target esp32s3
   idf.py build
   idf.py -p /dev/tty.usbmodem* flash monitor   # Ctrl-] to exit monitor
   ```

## Intended layout (created as milestones land)

```
firmware/
  CMakeLists.txt
  sdkconfig.defaults          # PSRAM, BLE, power tuning
  main/
    main.c                    # app entry, task startup
    ui/                       # ESP-Brookesia screens + watch faces
    services/
      ble_ancs.*              # M2 notifications + call actions
      ble_cts.*               # M3 time sync
      ble_ams.*               # M4 music
      ble_w1.*                # M5 custom profile <-> companion app
      ota.*                   # M5 WiFi + BLE firmware update
      wifi_svc.*              # M7 weather / NTP
      motion.*                # M6 steps / wrist-raise
      power_mgr.*             # tap/tilt-to-wake, sleep states
    hal/                      # board BSP glue (display, touch, IMU, RTC, PMIC)
  components/                 # esp-brookesia, lvgl, board BSP (managed deps)
```

## Verifying without a phone

For BLE bring-up before wiring the real UI, `nRF Connect` (iOS/Android) can
mock a central and inspect the watch's GATT. But ANCS/AMS need a real bonded
iPhone — those get tested against the actual phone at M2/M4.
