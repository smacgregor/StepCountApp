import SwiftUI

struct ContentView: View {
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
                Text(formatStepCount(stepCount))
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
        }
        .onAppear(perform: loadStepCount)
    }
    
    private func loadStepCount() {
        isLoading = true
        errorMessage = nil
        
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
            }
        }
    }
    
    private func formatStepCount(_ count: Double) -> String {
        if count == 0 {
            return "--"
        } else if count >= 1000 {
            let formatted = count / 1000
            return "\(formatted)k"
        } else {
            return String(format: "%.0f", count)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}