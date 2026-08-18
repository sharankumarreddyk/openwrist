import Foundation
import CoreBluetooth

// Connects to the watch's custom OpenWrist profile, subscribes to Steps/Status,
// and writes Config/Weather. iOS-standard ANCS/CTS/AMS are handled by iOS
// itself and are not touched here.
//
// CBCentralManager is created with queue: nil, so every delegate callback runs
// on the main thread — hence the whole manager is @MainActor, which keeps
// WatchState (@MainActor) updates valid without hops.
@MainActor
final class BLEManager: NSObject {
    private let state: WatchState
    private let health: HealthKitManager
    private var central: CBCentralManager!
    private var watch: CBPeripheral?
    private var configChar: CBCharacteristic?
    private var weatherChar: CBCharacteristic?
    private var wantScan = false

    init(state: WatchState, health: HealthKitManager) {
        self.state = state
        self.health = health
        super.init()
        central = CBCentralManager(delegate: self, queue: nil)
    }

    func start() {
        wantScan = true
        if central.state == .poweredOn { scan() }
    }

    func disconnect() {
        wantScan = false
        if let w = watch { central.cancelPeripheralConnection(w) }
        state.connection = .idle
    }

    func sendConfig(_ c: ConfigPacket) { write(c.encode(), to: configChar) }
    func sendWeather(_ w: WeatherPacket) { write(w.encode(), to: weatherChar) }

    private func scan() {
        state.connection = .scanning
        central.scanForPeripherals(withServices: [OpenWristGATT.service])
    }

    private func write(_ data: Data, to char: CBCharacteristic?) {
        guard let char, let watch else { state.lastError = "Not connected"; return }
        watch.writeValue(data, for: char, type: .withResponse)
    }
}

extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn: if wantScan { scan() }
        case .poweredOff: state.lastError = "Bluetooth is off"; state.connection = .idle
        case .unauthorized: state.lastError = "Bluetooth permission denied"
        default: break
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {
        central.stopScan()
        watch = peripheral
        state.connection = .connecting
        central.connect(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([OpenWristGATT.service])
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        state.connection = .idle
        configChar = nil; weatherChar = nil
        if wantScan { scan() }   // auto-reconnect
    }
}

extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        for s in peripheral.services ?? [] where s.uuid == OpenWristGATT.service {
            peripheral.discoverCharacteristics(nil, for: s)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        for c in service.characteristics ?? [] {
            switch c.uuid {
            case OpenWristGATT.steps, OpenWristGATT.status: peripheral.setNotifyValue(true, for: c)
            case OpenWristGATT.config: configChar = c
            case OpenWristGATT.weather: weatherChar = c
            default: break
            }
        }
        state.connection = .connected
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value else { return }
        switch characteristic.uuid {
        case OpenWristGATT.steps:
            if let s = StepUpdate.decode(data) {
                state.steps = s.steps
                state.activeMinutes = s.activeMinutes
                health.writeSteps(Int(s.steps))
            }
        case OpenWristGATT.status:
            if let s = StatusUpdate.decode(data) {
                state.batteryPct = s.batteryPct
                state.charging = s.charging
                state.fwVersion = s.versionString
            }
        default: break
        }
    }
}
