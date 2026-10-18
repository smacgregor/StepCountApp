import Foundation
import HealthKit

class HealthKitService {
    static let shared = HealthKitService()
    
    private let healthStore = HKHealthStore()
    private let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool, Error?) -> Void) {
        healthStore.requestAuthorization(toShare: nil, read: [stepCountType]) { success, error in
            DispatchQueue.main.async {
                completion(success, error)
            }
        }
    }
    
    func getTodaysStepCount(
        completion: @escaping (Double?, Error?) -> Void
    ) {
        self.fetchTodaysStepCount(completion: completion)
        /*
        healthStore.requestAuthorization(
            toShare: [],
            read: [stepCountType]
        ) { success, error in

            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }

            // "success" means the authorization request completed,
            // not that read access was granted.
            self.fetchTodaysStepCount(completion: completion)
        }
         */
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

/*            if let error = error {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            } */

            // No aggregate quantity means no step data was returned.
            guard let quantity = statistics?.sumQuantity() else {
                DispatchQueue.main.async {
                    completion(nil, nil)
                }
                return
            }

            let totalSteps = quantity.doubleValue(for: HKUnit.count())

            DispatchQueue.main.async {
                completion(totalSteps, nil)
            }
        }

        healthStore.execute(query)
    }
    
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
}
