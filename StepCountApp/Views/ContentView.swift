import SwiftUI
import WidgetKit

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase

    @State private var stepCount: Double = 0
    @State private var isLoading = true
    @State private var errorMessage: String?
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            } else {
                VStack(spacing: 2) {
                    Image(systemName: "shoe.running.and.shadow.fill")
                    Text(formatStepCount(stepCount))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                }
            }
        }
        .onAppear(perform: loadStepCount)
        .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        loadStepCount()
                    }
                }
    }
    
    private func loadStepCount() {
        isLoading = true
        errorMessage = nil
        
        HealthKitService.shared.requestAuthorization { success, error in
            HealthKitService.shared.getTodaysStepCount { stepCount, error in
                DispatchQueue.main.async {
                    self.isLoading = false
                    
                    if let error = error {
                        self.errorMessage = error.localizedDescription
                        return
                    }
                    
                    if let stepCount = stepCount {
                        self.stepCount = stepCount
                    } else {
                        self.stepCount = 0
                    }
                    WidgetCenter.shared.reloadTimelines(ofKind: "StepCountWidget")
                }
            }
        }
    }
    
    private func formatStepCount(_ count: Double) -> String {
        if count == 0 {
            return "--"
        } else {
            let numberFormatter = NumberFormatter()
            numberFormatter.minimumIntegerDigits = 1
            return NumberFormatter.localizedString(
                from: NSNumber(value: Int(count)),
                number: .decimal
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
