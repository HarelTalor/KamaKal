import SwiftUI
import SwiftData

@main
struct KamaKalApp: App {

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Meal.self,
            DailySummary.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false // persists data to disk
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
