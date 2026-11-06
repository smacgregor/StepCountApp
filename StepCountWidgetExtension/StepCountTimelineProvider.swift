import WidgetKit
import SwiftUI

struct StepCountTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), stepCount: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), stepCount: 0)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Get today's step count directly from HealthKit
        HealthKitService.shared.getTodaysStepCount { stepCount, error in
            let entry = SimpleEntry(date: Date(), stepCount: stepCount ?? 0)
            
            // Schedule next update in 20 minutes - this is what Apple recommends for apps that need frequent updates.
            let refreshDate = Calendar.current.date(byAdding: .minute, value: 20, to: Date())!
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            
            completion(timeline)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let stepCount: Double
}
