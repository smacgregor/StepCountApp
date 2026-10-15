import WidgetKit
import SwiftUI

struct StepCountWidget: Widget {
    let kind: String = "StepCountWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StepCountTimelineProvider()) { entry in
            StepCountWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Step Count")
        .description("Displays today's step count.")
        .supportedFamilies([.accessoryCircular])
    }
}

struct StepCountWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        VStack {
            Image(systemName: "figure.run")
                .font(.system(size: 20))
                .foregroundColor(.blue)
            
            Text(formatStepCount(entry.stepCount))
                .font(.system(size: 16, weight: .bold))
        }
    }
    
    private func formatStepCount(_ count: Double) -> String {
        if count == 0 {
            return "--"
        } else if count >= 10000 {
            let formatted = count / 1000
            return "\(formatted)k"
        } else {
            // Format with commas for numbers less than 10,000
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            numberFormatter.minimumIntegerDigits = 1
            return numberFormatter.string(from: NSNumber(value: count)) ?? "\(count)"
        }
    }
}

struct StepCountWidget_Previews: PreviewProvider {
    static var previews: some View {
        StepCountWidgetEntryView(entry: SimpleEntry(date: Date(), stepCount: 1234))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
