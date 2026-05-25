import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var users: [User]
    
    var body: some View {
        if users.isEmpty {
            OnboardingView()
        } else {
            MainDashboardView()
        }
    }
}

#Preview {
    ContentView()
}
