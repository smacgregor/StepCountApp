
import Foundation
import HealthKit
import WidgetKit

final class HealthKitService {

    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    private let stepCountType =
        HKQuantityType.quantityType(forIdentifier: .stepCount)!

    private var stepCountObserverQuery: HKObserverQuery?
    private let observerLock = NSLock()

    private var isObserving = false

    // Change this to match the kind in your WidgetConfiguration.
    private let widgetKind = "StepCountWidget"

    private init() {}

    // MARK: - Authorization

    func requestAuthorization(
        completion: @escaping (Bool, Error?) -> Void
    ) {
        healthStore.requestAuthorization(
            toShare: nil,
            read: [stepCountType]
        ) { success, error in

            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }

    // MARK: - Step Count

    func getTodaysStepCount(
        completion: @escaping (Double?, Error?) -> Void
    ) {
        fetchTodaysStepCount(completion: completion)
    }

    private func fetchTodaysStepCount(
        completion: @escaping (Double?, Error?) -> Void
    ) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        let query = HKStatisticsQuery(
            quantityType: stepCountType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum
        ) { _, statistics, error in

            if let error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            let totalSteps = statistics?
                .sumQuantity()?
                .doubleValue(for: HKUnit.count()) ?? 0

            DispatchQueue.main.async {
                completion(totalSteps, nil)
            }
        }

        healthStore.execute(query)
    }

    // MARK: - Background Observation

    func startObservingStepCount() {

        observerLock.lock()

        guard !isObserving else {
            observerLock.unlock()
            return
        }

        isObserving = true
        observerLock.unlock()

        let observerQuery = HKObserverQuery(
            sampleType: stepCountType,
            predicate: nil
        ) { [weak self] _, observerCompletion, error in

            guard let self else {
                observerCompletion()
                return
            }

            if let error {
                print("HealthKit observer error: \(error)")
                observerCompletion()
                return
            }

            // Fetch the latest cumulative step count.
            self.fetchTodaysStepCount { _, queryError in

                if let queryError {
                    print("Step count refresh error: \(queryError)")
                } else {
                    // Ask WidgetKit to generate a fresh timeline.
                    WidgetCenter.shared.reloadTimelines(
                        ofKind: self.widgetKind
                    )
                }

                // Tell HealthKit processing is complete.
                observerCompletion()
            }
        }

        stepCountObserverQuery = observerQuery
        healthStore.execute(observerQuery)

        // Request background delivery.
        healthStore.enableBackgroundDelivery(
            for: stepCountType,
            frequency: .immediate
        ) { success, error in

            if let error {
                print("HealthKit background delivery error: \(error)")
            } else {
                print(
                    "HealthKit background delivery enabled: \(success)"
                )
            }
        }
    }

    // MARK: - Availability

    func isHealthDataAvailable() -> Bool {
        HKHealthStore.isHealthDataAvailable()
    }
}
