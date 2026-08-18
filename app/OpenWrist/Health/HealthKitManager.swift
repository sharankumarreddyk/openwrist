import Foundation
import HealthKit

// Writes step data from the watch into Apple Health.
// The watch reports a running daily total; HealthKit wants per-interval
// samples, so we write only the positive delta since the last sample.
final class HealthKitManager {
    private let store = HKHealthStore()
    private let stepType = HKQuantityType(.stepCount)
    private var lastTotal = 0
    private var lastDate = Date()

    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        store.requestAuthorization(toShare: [stepType], read: []) { _, _ in }
    }

    func writeSteps(_ runningTotal: Int) {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        // ponytail: naive running-total delta. Resets (e.g. watch reboot to a
        // lower total) are treated as a new baseline, not negative steps.
        let delta = runningTotal - lastTotal
        let now = Date()
        defer { lastTotal = max(runningTotal, 0); lastDate = now }
        guard delta > 0 else { return }

        let qty = HKQuantity(unit: .count(), doubleValue: Double(delta))
        let sample = HKQuantitySample(type: stepType, quantity: qty,
                                      start: lastDate, end: now)
        store.save(sample) { _, _ in }
    }
}
