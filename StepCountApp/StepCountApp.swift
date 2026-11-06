import SwiftUI
import WatchKit

@main
struct StepCountApp: App {
    init() {
        HealthKitService.shared.requestAuthorization { success, error in

            if let error {
                print("HealthKit authorization error: \(error)")
                return
            }

            guard success else {
                print("HealthKit authorization request failed")
                return
            }

            HealthKitService.shared.startObservingStepCount()
        }
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
