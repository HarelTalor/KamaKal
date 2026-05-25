import Foundation
import Supabase

/// Manages all communication with the Supabase backend.
/// Handles authentication, data syncing, and remote storage.
final class SupabaseManager: ObservableObject {

    // MARK: - Singleton

    static let shared = SupabaseManager()

    // MARK: - Supabase Client

    /// The main Supabase client instance.
    /// Replace the placeholder URL and anon key with your actual Supabase project credentials.
    let client: SupabaseClient

    // MARK: - Init

    private init() {
        guard
            let url = URL(string: Constants.supabaseURL)
        else {
            fatalError("Invalid Supabase URL. Check Constants.swift.")
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Constants.supabaseAnonKey
        )
    }

    // MARK: - Meal Sync

    /// Syncs unsynced local `Meal` records to the Supabase `meals` table.
    /// - Parameter meals: An array of `Meal` objects to upload.
    /// - Throws: A Supabase or network error if the upload fails.
    func syncMeals(_ meals: [MealDTO]) async throws {
        // TODO: Implement upsert logic
        // Example (uncomment when table is ready):
        //
        // try await client
        //     .from("meals")
        //     .upsert(meals)
        //     .execute()
    }
}

// MARK: - MealDTO

/// A Codable transfer object that mirrors the Supabase `meals` table schema.
/// SwiftData `@Model` classes are not directly `Codable`, so we map through this DTO.
struct MealDTO: Codable {
    let id: UUID
    let date: Date
    let imagePath: String?
    let textDescription: String
    let ingredients: [String]
    let caloriesPerIngredient: [Int]
    let totalCalories: Int

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case imagePath       = "image_path"
        case textDescription = "text_description"
        case ingredients
        case caloriesPerIngredient = "calories_per_ingredient"
        case totalCalories        = "total_calories"
    }
}

// MARK: - Meal → DTO Conversion

extension Meal {
    /// Converts a SwiftData `Meal` model to a Codable `MealDTO` for Supabase sync.
    func toDTO() -> MealDTO {
        MealDTO(
            id: id,
            date: date,
            imagePath: imagePath,
            textDescription: textDescription,
            ingredients: ingredients,
            caloriesPerIngredient: caloriesPerIngredient,
            totalCalories: totalCalories
        )
    }
}
