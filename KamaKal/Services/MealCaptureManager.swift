import SwiftUI
import PhotosUI
import SwiftData
import os

private let logger = Logger(subsystem: "com.kamakal", category: "MealCapture")

/// ViewModel that orchestrates photo selection, Gemini analysis, and Meal creation.
@MainActor
final class MealCaptureManager: ObservableObject {

    // MARK: - Photo State

    /// Bound to PhotosPicker's selection.
    @Published var selectedPhotoItem: PhotosPickerItem? {
        didSet {
            // Avoid triggering a load during reset()
            guard !isResetting else { return }
            loadImageFromPickerItem()
        }
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

    /// Guard flag to prevent didSet from firing during reset().
    private var isResetting = false

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

                // Resize large images to limit memory / upload size
                let resized = resizeImage(uiImage, maxDimension: 1024)

                // Compress to JPEG for a smaller payload
                guard let jpeg = resized.jpegData(compressionQuality: 0.7) else {
                    errorMessage = "Failed to compress image to JPEG."
                    return
                }

                self.selectedImage = resized
                self.imageData = jpeg
                self.errorMessage = nil
                self.analysisResult = nil
            } catch {
                logger.error("Image load error: \(error.localizedDescription)")
                errorMessage = "Image load error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Image Resizing (I12)

    /// Resizes an image so its longest dimension does not exceed `maxDimension`.
    private func resizeImage(_ image: UIImage, maxDimension: CGFloat = 1024) -> UIImage {
        let size = image.size
        guard max(size.width, size.height) > maxDimension else { return image }
        let scale = maxDimension / max(size.width, size.height)
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
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
            logger.error("Gemini analysis failed: \(error.localizedDescription)")
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    // MARK: - Save Meal

    /// Creates a SwiftData `Meal` from the Gemini result, saves the image to disk,
    /// and inserts it into the model context.
    func saveMeal(context: ModelContext) -> Meal? {
        guard let result = analysisResult else { return nil }

        // Save image to the app's documents directory (returns only the filename)
        let imageFilename = saveImageToDisk()

        let meal = Meal(
            textDescription: mealDescription,
            ingredients: result.ingredients.map(\.name),
            caloriesPerIngredient: result.ingredients.map(\.calories),
            totalCalories: result.totalCalories,
            protein: result.totalProtein,
            carbs: result.totalCarbs,
            fat: result.totalFat
        )
        meal.imagePath = imageFilename

        context.insert(meal)
        
        let dto = meal.toDTO()
        Task { [weak meal] in
            do {
                try await SupabaseManager.shared.syncMeals([dto])
                if let meal = meal {
                    meal.isSyncedToSupabase = true
                }
            } catch {
                logger.error("Failed to sync meal to Supabase: \(error.localizedDescription)")
            }
        }
        
        return meal
    }

    /// Writes the JPEG data to Documents/<UUID>.jpg and returns only the filename.
    /// Storing only the filename (not the full path) avoids breakage when the
    /// sandbox container path changes across app updates.
    private func saveImageToDisk() -> String? {
        guard let data = imageData else { return nil }

        let filename = "\(UUID().uuidString).jpg"
        guard let fileURL = Self.imageURL(for: filename) else {
            logger.error("Failed to resolve documents directory for image save.")
            return nil
        }

        do {
            try data.write(to: fileURL)
            return filename
        } catch {
            logger.error("Failed to save meal image: \(error.localizedDescription)")
            return nil
        }
    }

    /// Reconstructs the full URL for an image given its filename.
    /// Use this whenever you need to load an image from its stored relative path.
    static func imageURL(for filename: String) -> URL? {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        return dir.appendingPathComponent(filename)
    }

    // MARK: - Reset

    func reset() {
        isResetting = true
        selectedPhotoItem = nil
        isResetting = false

        selectedImage = nil
        imageData = nil
        mealDescription = ""
        isAnalyzing = false
        analysisResult = nil
        errorMessage = nil
    }
}
