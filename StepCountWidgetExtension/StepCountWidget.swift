import WidgetKit
import SwiftUI

@main
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
        VStack(spacing: 2) {
            Image(systemName: "shoe.running.and.shadow.fill")
                .font(.system(size: 18, weight: .medium))

            Text(formatStepCount(entry.stepCount))
                .font(.system(size: 15, weight: .bold))
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
    

    private func formatStepCount(_ count: Double) -> String {
        guard count > 0 else { return "--" }

        if count >= 10_000 {
            return String(format: "%.1fk", count / 1_000)
        }

        return NumberFormatter.localizedString(
            from: NSNumber(value: Int(count)),
            number: .decimal
        )
    }
}

struct StepCountWidget_Previews: PreviewProvider {
    static var previews: some View {
        StepCountWidgetEntryView(entry: SimpleEntry(date: Date(), stepCount: 1234))
            .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    }
}
