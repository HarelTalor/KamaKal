import SwiftUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.kamakal", category: "App")

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
            // Attempt recovery: try in-memory only so the app at least launches.
            logger.error("Could not create persistent ModelContainer: \(error.localizedDescription). Falling back to in-memory store.")
            do {
                let fallback = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [fallback])
            } catch {
                // If even in-memory fails, there's a fundamental schema issue — nothing we can recover from.
                fatalError("Could not create any ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
