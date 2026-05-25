import Foundation
import SwiftData

/// Aggregates all meals for a single calendar day and compares against the user's target.
@Model
final class DailySummary {
    #Unique<DailySummary>([\.id])

    var id: UUID
    var date: Date
    var totalConsumed: Int
    var calorieTarget: Int

    /// One-to-many relationship: a daily summary owns many meals.
    @Relationship(deleteRule: .cascade, inverse: \Meal.dailySummary)
    var meals: [Meal]

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
        calorieTarget: Int = 2000,
        meals: [Meal] = []
    ) {
        self.id = id
        self.date = date
        self.totalConsumed = totalConsumed
        self.calorieTarget = calorieTarget
        self.meals = meals
    }

    /// Recalculates `totalConsumed` from the associated meals array.
    func recalculate() {
        totalConsumed = meals.reduce(0) { $0 + $1.totalCalories }
    }
}
