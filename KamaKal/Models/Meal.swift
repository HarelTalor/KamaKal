import Foundation
import SwiftData

/// Represents a single meal entry, including AI-recognized ingredients and calorie breakdown.
@Model
final class Meal {
    @Attribute(.unique) var id: UUID
    var date: Date
    var imagePath: String?
    var textDescription: String
    var ingredients: [String]
    var caloriesPerIngredient: [Int]
    var totalCalories: Int
    var isSyncedToSupabase: Bool
    var createdAt: Date

    init(
        id: UUID = UUID(),
        date: Date = .now,
        imagePath: String? = nil,
        textDescription: String,
        ingredients: [String] = [],
        caloriesPerIngredient: [Int] = [],
        totalCalories: Int = 0,
        isSyncedToSupabase: Bool = false,
        createdAt: Date = .now
    ) {
        self.id = id
        self.date = date
        self.imagePath = imagePath
        self.textDescription = textDescription
        self.ingredients = ingredients
        self.caloriesPerIngredient = caloriesPerIngredient
        self.totalCalories = totalCalories
        self.isSyncedToSupabase = isSyncedToSupabase
        self.createdAt = createdAt
    }
}
