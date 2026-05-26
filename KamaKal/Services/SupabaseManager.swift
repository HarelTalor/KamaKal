import Foundation
import os

private let logger = Logger(subsystem: "com.kamakal", category: "SupabaseManager")

#if canImport(Supabase)
import Supabase

/// Manages all communication with the Supabase backend.
/// Handles authentication, data syncing, and remote storage.
final class SupabaseManager {

    // MARK: - Singleton

    static let shared = SupabaseManager()

    // MARK: - Supabase Client

    /// The main Supabase client instance. `nil` if the URL is a placeholder.
    let client: SupabaseClient?

    /// Whether the manager was initialized with valid credentials.
    var isConfigured: Bool { client != nil }

    // MARK: - Init

    private init() {
        // Guard against placeholder credentials
        if Constants.supabaseURL.contains("YOUR_PROJECT_ID") ||
           Constants.supabaseAnonKey.contains("YOUR_SUPABASE_ANON_KEY") {
            logger.warning("Supabase is not configured — using placeholder credentials. Sync is disabled.")
            self.client = nil
            return
        }

        guard let url = URL(string: Constants.supabaseURL) else {
            logger.error("Invalid Supabase URL in Constants.swift. Sync is disabled.")
            self.client = nil
            return
        }

        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Constants.supabaseAnonKey
        )
        logger.info("SupabaseManager initialized successfully.")
    }

    // MARK: - Meal Sync

    /// Syncs unsynced local `Meal` records to the Supabase `meals` table.
    /// - Parameter meals: An array of `MealDTO` objects to upload.
    /// - Throws: A Supabase or network error if the upload fails.
    func syncMeals(_ meals: [MealDTO]) async throws {
        guard let client else {
            logger.warning("syncMeals called with \(meals.count) meals — sync skipped (Supabase not configured).")
            return
        }

        logger.info("syncMeals called with \(meals.count) meals — sync not yet implemented.")
        // TODO: Implement upsert logic
        // Example (uncomment when table is ready):
        //
        // try await client
        //     .from("meals")
        //     .upsert(meals)
        //     .execute()
    }
}

#else

// MARK: - Stub when Supabase SDK is not available

/// Stub SupabaseManager used when the Supabase SPM package is not linked.
/// All sync operations log warnings and return gracefully.
final class SupabaseManager {

    static let shared = SupabaseManager()
    private init() {
        logger.warning("Supabase SDK not available — SupabaseManager is a no-op stub.")
    }

    var isConfigured: Bool { false }

    func syncMeals(_ meals: [MealDTO]) async throws {
        logger.warning("syncMeals called with \(meals.count) meals — Supabase SDK not linked, skipping.")
    }
}

#endif

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
