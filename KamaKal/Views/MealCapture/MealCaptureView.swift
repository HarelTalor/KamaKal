import SwiftUI
import PhotosUI
import SwiftData

/// The meal logging screen: pick a photo, describe the meal, analyze with Gemini, and save.
struct MealCaptureView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = MealCaptureManager()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Photo Section
                    photoSection

                    // MARK: - Description
                    descriptionSection

                    // MARK: - Analyze Button
                    analyzeButton

                    // MARK: - Results
                    if let result = manager.analysisResult {
                        resultCard(result)
                    }

                    // MARK: - Error
                    if let error = manager.errorMessage {
                        errorBanner(error)
                    }
                }
                .padding()
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    // MARK: - Photo Section

    private var photoSection: some View {
        VStack(spacing: 12) {
            if let image = manager.selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("Select a meal photo")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
            }

            PhotosPicker(
                selection: $manager.selectedPhotoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(
                    manager.selectedImage == nil ? "Choose Photo" : "Change Photo",
                    systemImage: "photo.on.rectangle"
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(Color(.systemGray5))
                .foregroundColor(.primary)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    // MARK: - Description Input

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What are you eating?")
                .font(.headline)

            TextField("e.g. Grilled chicken with rice and salad", text: $manager.mealDescription)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled(false)
        }
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button(action: {
            Task { await manager.analyzeWithGemini() }
        }) {
            HStack {
                if manager.isAnalyzing {
                    ProgressView()
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(manager.isAnalyzing ? "Analyzing..." : "Analyze with AI")
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                manager.imageData != nil && !manager.mealDescription.isEmpty
                    ? Color.blue
                    : Color.gray
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(manager.isAnalyzing || manager.imageData == nil || manager.mealDescription.isEmpty)
    }

    // MARK: - Result Card

    private func resultCard(_ result: GeminiMealResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis Result")
                .font(.headline)

            // Ingredients list
            ForEach(Array(result.ingredients.enumerated()), id: \.offset) { _, ingredient in
                HStack {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.orange)
                        .frame(width: 24)

                    Text(ingredient.name)
                        .font(.body)

                    Spacer()

                    Text("\(ingredient.calories) kcal")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }

            Divider()

            // Total
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text("\(result.totalCalories) kcal")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }

            // Save Button
            Button(action: saveMeal) {
                Text("Save Meal")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.callout)
                .foregroundColor(.red)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    // MARK: - Save

    private func saveMeal() {
        guard manager.saveMeal(context: modelContext) != nil else {
            manager.errorMessage = "Failed to save meal."
            return
        }
        dismiss()
    }
}

#Preview {
    MealCaptureView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
}
