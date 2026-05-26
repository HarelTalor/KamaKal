import Foundation
import SwiftData

/// Represents the app user's profile, including physical stats and calorie goals.
@Model
final class User {
    @Attribute(.unique) var id: UUID
    var age: Int
    var gender: Gender
    var heightCm: Double
    var weightKg: Double
    var activityLevel: ActivityLevel
    var goal: Goal
    var dailyCalorieTarget: Int
    /// True when the user manually typed a specific calorie number rather than using the formula.
    var usesCustomCalorieTarget: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        age: Int,
        gender: Gender,
        heightCm: Double,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal,
        dailyCalorieTarget: Int,
        usesCustomCalorieTarget: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.age = age
        self.gender = gender
        self.heightCm = heightCm
        self.weightKg = weightKg
        self.activityLevel = activityLevel
        self.goal = goal
        self.dailyCalorieTarget = dailyCalorieTarget
        self.usesCustomCalorieTarget = usesCustomCalorieTarget
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Enums

enum Gender: String, Codable, CaseIterable {
    case male
    case female
    case other

    var displayName: String {
        switch self {
        case .male:   return "Male"
        case .female: return "Female"
        case .other:  return "Other"
        }
    }
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary
    case lightlyActive
    case moderatelyActive
    case veryActive
    case extraActive

    var displayName: String {
        switch self {
        case .sedentary:        return "Sedentary"
        case .lightlyActive:    return "Lightly Active"
        case .moderatelyActive: return "Moderately Active"
        case .veryActive:       return "Very Active"
        case .extraActive:      return "Extra Active"
        }
    }

    /// Activity multiplier for TDEE calculation (Harris-Benedict).
    var multiplier: Double {
        switch self {
        case .sedentary:        return 1.2
        case .lightlyActive:    return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive:       return 1.725
        case .extraActive:      return 1.9
        }
    }
}

enum Goal: String, Codable, CaseIterable {
    case lose
    case maintain
    case gain

    var displayName: String {
        switch self {
        case .lose:     return "Lose Weight"
        case .maintain: return "Maintain Weight"
        case .gain:     return "Gain Weight"
        }
    }
}
