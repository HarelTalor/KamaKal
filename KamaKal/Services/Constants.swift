import Foundation

/// App-wide constants. Replace placeholder values with your real Supabase credentials.
enum Constants {

    // MARK: - Supabase

    /// Your Supabase project URL (e.g. "https://xyzcompany.supabase.co").
    static let supabaseURL = "https://YOUR_PROJECT_ID.supabase.co"

    /// Your Supabase anonymous (public) API key.
    static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY"

    // MARK: - Google Gemini

    /// Your Google Gemini API key from https://aistudio.google.com/apikey
    static let geminiAPIKey = "YOUR_GEMINI_API_KEY"

    /// Gemini model to use. `gemini-3.1-flash-lite` is fast and cost-effective.
    static let geminiModel = "gemini-3.1-flash-lite"

    /// The full Gemini REST endpoint (key is appended at call time).
    static var geminiEndpoint: String {
        "https://generativelanguage.googleapis.com/v1beta/models/\(geminiModel):generateContent"
    }
}
