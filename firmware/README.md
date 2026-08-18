# Firmware

ESP-IDF + ESP-Brookesia + LVGL for the Waveshare ESP32-S3-Touch-AMOLED-2.06.

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
   - Board BSP + demos: Waveshare ESP32-S3-Touch-AMOLED-2.06 wiki/demo.
   - UI framework: `espressif/esp-brookesia` (has a smartwatch example).
   - ANCS client: `esp-idf/examples/bluetooth/bluedroid/ble/ble_ancs`.
   - Closest full reference for this exact board: `joaquimorg/OLEDS3Watch`.

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
      wifi_svc.*              # M6 weather / NTP / OTA
      motion.*                # M5 steps / wrist-raise
      power_mgr.*             # sleep states, wake sources
    hal/                      # board BSP glue (display, touch, IMU, RTC, PMIC)
  components/                 # esp-brookesia, lvgl, board BSP (managed deps)
```

## Verifying without a phone

For BLE bring-up before wiring the real UI, `nRF Connect` (iOS/Android) can
mock a central and inspect the watch's GATT. But ANCS/AMS need a real bonded
iPhone — those get tested against the actual phone at M2/M4.
