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
    
    func getTodaysStepCount(completion: @escaping (Double?, Error?) -> Void) {
        // First check if we already have authorization
        let status = healthStore.authorizationStatus(for: stepCountType)
        
        if status == .notDetermined {
            // Request authorization first, then fetch data
            requestAuthorization { success, error in
                if success {
                    self.fetchTodaysStepCount(completion: completion)
                } else {
                    DispatchQueue.main.async {
                        completion(nil, error ?? NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Authorization denied"]))
                    }
                }
            }
        } else if status == .sharingDenied {
            // Authorization was denied
            DispatchQueue.main.async {
                completion(nil, NSError(domain: "HealthKitError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Access denied"]))
            }
        } else {
            // Already authorized, fetch the data now
            fetchTodaysStepCount(completion: completion)
        }
    }
    
    private func fetchTodaysStepCount(completion: @escaping (Double?, Error?) -> Void) {
        // Create a predicate for today's steps
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        // Create the query
        let query = HKSampleQuery(
            sampleType: stepCountType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: nil) { _, samples, error in
                
                guard let samples = samples as? [HKQuantitySample] else {
                    DispatchQueue.main.async {
                        completion(nil, error)
                    }
                    return
                }
                
                // Sum up all the steps
                let totalSteps = samples.reduce(0.0) { total, sample in
                    let stepCount = sample.quantity.doubleValue(for: HKUnit.count())
                    return total + stepCount
                }
                
                DispatchQueue.main.async {
                    completion(totalSteps, error)
                }
            }
        
        healthStore.execute(query)
    }
    
    func isHealthDataAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
}
