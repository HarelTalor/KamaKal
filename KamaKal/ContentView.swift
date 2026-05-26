import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var users: [User]
    
    var body: some View {
        if users.isEmpty {
            OnboardingView()
        } else {
            TabView {
                MainDashboardView()
                    .tabItem {
                        Label("Today", systemImage: "flame.fill")
                    }
                
                HistoryView()
                    .tabItem {
                        Label("History", systemImage: "clock.fill")
                    }
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
}
