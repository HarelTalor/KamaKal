import Foundation

/// Mode chosen by the user for setting their daily calorie target.
enum CalorieMode: String, Codable, CaseIterable {
    /// Auto-calculate using the Mifflin-St Jeor formula
    case formula
    
    /// Manually typed custom number
    case custom
}
