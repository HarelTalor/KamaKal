import Foundation

// MARK: - GeminiService

/// Communicates with the Google Gemini multimodal API using plain URLSession.
/// Sends a meal image + text description and receives a structured JSON response
/// with ingredient names, per-ingredient calories, macros, and totals.
final class GeminiService {

    static let shared = GeminiService()
    private init() {}

    // MARK: - Public API

    /// Analyzes a meal photo with an optional text hint and returns parsed ingredients.
    /// - Parameters:
    ///   - imageData: JPEG image data of the meal.
    ///   - description: A short user-provided description (e.g. "Chicken and rice").
    /// - Returns: A `GeminiMealResponse` containing ingredients, macros, and total calories.
    func analyzeMeal(imageData: Data, description: String) async throws -> GeminiMealResponse {
        let request = try buildRequest(imageData: imageData, description: description)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            let body = String(data: data, encoding: .utf8) ?? "No body"
            throw GeminiError.httpError(statusCode: http.statusCode, body: body)
        }

        return try parseResponse(data: data)
    }

    // MARK: - Request Builder

    private func buildRequest(imageData: Data, description: String) throws -> URLRequest {
        guard var urlComponents = URLComponents(string: Constants.geminiEndpoint) else {
            throw GeminiError.invalidURL
        }
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: Constants.geminiAPIKey)
        ]
        guard let url = urlComponents.url else {
            throw GeminiError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let base64Image = imageData.base64EncodedString()

        // Build the Gemini REST body with inline image data + text prompt.
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        [
                            "inlineData": [
                                "mimeType": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "text": promptText(description: description)
                        ]
                    ]
                ]
            ],
            "generationConfig": [
                "temperature": 0.1,
                "maxOutputTokens": 1024,
                "responseMimeType": "application/json"
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        return request
    }

    // MARK: - Prompt

    private func promptText(description: String) -> String {
        """
        You are a nutrition analysis AI. Analyze the food in this image.
        The user describes this meal as: "\(description)"

        Identify every visible ingredient or food item and estimate the calories and macronutrients for each.
        Consider typical portion sizes visible in the image.

        You MUST respond with ONLY a valid JSON object - no markdown, no explanation, no extra text.
        Use this exact structure:

        {
          "ingredients": [
            {"name": "Ingredient Name", "calories": 250, "protein": 30.0, "carbs": 5.0, "fat": 12.0},
            {"name": "Another Ingredient", "calories": 150, "protein": 10.0, "carbs": 20.0, "fat": 3.0}
          ],
          "total_calories": 400,
          "total_protein": 40.0,
          "total_carbs": 25.0,
          "total_fat": 15.0
        }

        Rules:
        - "calories" is an integer representing estimated kcal for the visible portion.
        - "protein", "carbs", "fat" are doubles in grams for the visible portion.
        - "total_calories" is the sum of all ingredient calories.
        - "total_protein", "total_carbs", "total_fat" are the sums of the respective macros.
        - Include at least 1 ingredient.
        - Do NOT wrap the JSON in markdown code fences.
        """
    }

    // MARK: - Response Parsing

    private func parseResponse(data: Data) throws -> GeminiMealResponse {
        // Gemini wraps responses in: { "candidates": [{ "content": { "parts": [{ "text": "..." }] } }] }
        let geminiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)

        guard
            let candidate = geminiResponse.candidates.first,
            let part = candidate.content.parts.first,
            let jsonText = part.text
        else {
            throw GeminiError.noContent
        }

        // Clean potential markdown fences from the response (safety net)
        let cleaned = cleanJSON(jsonText)

        guard let jsonData = cleaned.data(using: .utf8) else {
            throw GeminiError.decodingFailed("Could not convert cleaned text to Data")
        }

        do {
            let mealResponse = try JSONDecoder().decode(GeminiMealResponse.self, from: jsonData)
            return mealResponse
        } catch {
            throw GeminiError.decodingFailed("Failed to decode meal JSON: \(error.localizedDescription)\nRaw text: \(cleaned)")
        }
    }

    /// Strips markdown code fences if Gemini wraps the JSON despite instructions.
    private func cleanJSON(_ text: String) -> String {
        var result = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Remove ```json ... ``` wrapper
        if result.hasPrefix("```") {
            // Drop opening fence line
            if let firstNewline = result.firstIndex(of: "\n") {
                result = String(result[result.index(after: firstNewline)...])
            }
            // Drop closing fence
            if result.hasSuffix("```") {
                result = String(result.dropLast(3))
            }
            result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return result
    }
}

// MARK: - Gemini API Response Models (internal)

/// Maps the top-level Gemini REST response envelope.
private struct GeminiAPIResponse: Decodable {
    let candidates: [Candidate]

    struct Candidate: Decodable {
        let content: Content
    }

    struct Content: Decodable {
        let parts: [Part]
    }

    struct Part: Decodable {
        let text: String?
    }
}

// MARK: - Public Response Model

/// The decoded meal analysis returned by Gemini.
struct GeminiMealResponse: Decodable {
    let ingredients: [Ingredient]
    let totalCalories: Int
    let totalProtein: Double
    let totalCarbs: Double
    let totalFat: Double

    struct Ingredient: Decodable {
        let name: String
        let calories: Int
        let protein: Double
        let carbs: Double
        let fat: Double
    }

    enum CodingKeys: String, CodingKey {
        case ingredients
        case totalCalories = "total_calories"
        case totalProtein = "total_protein"
        case totalCarbs = "total_carbs"
        case totalFat = "total_fat"
    }
}

// MARK: - Errors

enum GeminiError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int, body: String)
    case noContent
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid Gemini API URL."
        case .invalidResponse:
            return "The server returned an invalid response."
        case .httpError(let code, let body):
            return "HTTP \(code): \(body)"
        case .noContent:
            return "Gemini returned no content in its response."
        case .decodingFailed(let detail):
            return "Failed to decode Gemini response: \(detail)"
        }
    }
}
