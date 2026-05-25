import SwiftUI
import PhotosUI
import SwiftData

/// ViewModel that orchestrates photo selection, Gemini analysis, and Meal creation.
@MainActor
final class MealCaptureManager: ObservableObject {

    // MARK: - Photo State

    /// Bound to PhotosPicker's selection.
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet { loadImageFromPickerItem() }
    }

    /// The displayable image after loading.
    @Published var selectedImage: UIImage?

    /// Raw JPEG data sent to Gemini.
    @Published var imageData: Data?

    // MARK: - Input / Output State

    @Published var mealDescription: String = ""
    @Published var isAnalyzing: Bool = false
    @Published var analysisResult: GeminiMealResponse?
    @Published var errorMessage: String?

    // MARK: - Photo Loading

    private func loadImageFromPickerItem() {
        guard let item = selectedPhotoItem else { return }

        Task {
            do {
                // Load the transferable image data
                guard let data = try await item.loadTransferable(type: Data.self) else {
                    errorMessage = "Could not load image data."
                    return
                }

                guard let uiImage = UIImage(data: data) else {
                    errorMessage = "Selected file is not a valid image."
                    return
                }

                // Compress to JPEG for a smaller payload
                guard let jpeg = uiImage.jpegData(compressionQuality: 0.7) else {
                    errorMessage = "Failed to compress image to JPEG."
                    return
                }

                self.selectedImage = uiImage
                self.imageData = jpeg
                self.errorMessage = nil
                self.analysisResult = nil
            } catch {
                errorMessage = "Image load error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Gemini Analysis

    /// Sends the captured image + description to Gemini and stores the result.
    func analyzeWithGemini() async {
        guard let data = imageData else {
            errorMessage = "Please select a photo first."
            return
        }
        guard !mealDescription.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please add a short description of your meal."
            return
        }

        isAnalyzing = true
        errorMessage = nil
        analysisResult = nil

        do {
            let result = try await GeminiService.shared.analyzeMeal(
                imageData: data,
                description: mealDescription
            )
            analysisResult = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    // MARK: - Save Meal

    /// Creates a SwiftData `Meal` from the Gemini result, saves the image to disk,
    /// and inserts it into the model context.
    func saveMeal(context: ModelContext) -> Meal? {
        guard let result = analysisResult else { return nil }

        // Save image to the app's documents directory
        let imagePath = saveImageToDisk()

        let meal = Meal(
            textDescription: mealDescription,
            ingredients: result.ingredients.map(\.name),
            caloriesPerIngredient: result.ingredients.map(\.calories),
            totalCalories: result.totalCalories
        )
        meal.imagePath = imagePath

        context.insert(meal)
        return meal
    }

    /// Writes the JPEG data to Documents/<UUID>.jpg and returns the path.
    private func saveImageToDisk() -> String? {
        guard let data = imageData else { return nil }

        let filename = "\(UUID().uuidString).jpg"
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL.path
        } catch {
            print("Failed to save meal image: \(error)")
            return nil
        }
    }

    // MARK: - Reset

    func reset() {
        selectedPhotoItem = nil
        selectedImage = nil
        imageData = nil
        mealDescription = ""
        isAnalyzing = false
        analysisResult = nil
        errorMessage = nil
    }
}
