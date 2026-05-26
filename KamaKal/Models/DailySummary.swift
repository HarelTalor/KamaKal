import Foundation
import SwiftData

/// Aggregates all meals for a single calendar day and compares against the user's target.
/// Currently kept as a standalone model for future use — no active relationship to Meal.
@Model
final class DailySummary {
    @Attribute(.unique) var id: UUID
    var date: Date
    var totalConsumed: Int
    var calorieTarget: Int

    /// Remaining calories for the day (positive = under target, negative = over target).
    var remaining: Int {
        calorieTarget - totalConsumed
    }

    /// Progress ratio (0.0 – 1.0+). Values above 1.0 mean the user exceeded their target.
    var progress: Double {
        guard calorieTarget > 0 else { return 0 }
        return Double(totalConsumed) / Double(calorieTarget)
    }

    init(
        id: UUID = UUID(),
        date: Date = .now,
        totalConsumed: Int = 0,
        calorieTarget: Int = 2000
    ) {
        self.id = id
        self.date = date
        self.totalConsumed = totalConsumed
        self.calorieTarget = calorieTarget
    }
}
