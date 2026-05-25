import Foundation

/// Service for calculating Total Daily Energy Expenditure (TDEE) and calorie goals.
struct CalculatorService {
    
    /// Calculates the daily calorie target based on the user's stats and goals.
    /// Uses the Mifflin-St Jeor equation for Basal Metabolic Rate (BMR).
    static func calculateDailyTarget(
        age: Int,
        gender: Gender,
        heightCm: Double,
        weightKg: Double,
        activityLevel: ActivityLevel,
        goal: Goal
    ) -> Int {
        // Mifflin-St Jeor Equation
        // Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5
        // Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161
        
        let weightFactor = 10.0 * weightKg
        let heightFactor = 6.25 * heightCm
        let ageFactor = 5.0 * Double(age)
        
        let baseBMR = weightFactor + heightFactor - ageFactor
        
        let genderAdjustment: Double
        switch gender {
        case .male:
            genderAdjustment = 5.0
        case .female:
            genderAdjustment = -161.0
        case .other:
            // Average of male and female adjustments for a neutral baseline
            genderAdjustment = -78.0
        }
        
        let bmr = baseBMR + genderAdjustment
        
        // TDEE = BMR × Activity Multiplier
        let tdee = bmr * activityLevel.multiplier
        
        // Goal Adjustment
        let goalAdjustment: Double
        switch goal {
        case .lose:
            goalAdjustment = -500.0 // 500 calorie deficit (~1 lb per week)
        case .maintain:
            goalAdjustment = 0.0
        case .gain:
            goalAdjustment = 500.0 // 500 calorie surplus
        }
        
        let targetCalories = tdee + goalAdjustment
        
        // Ensure we don't return dangerously low calorie targets
        let minimumCalories = gender == .male ? 1500.0 : 1200.0
        
        return Int(max(targetCalories, minimumCalories))
    }
}
