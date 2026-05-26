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
            ZStack {
                KTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        photoSection
                        descriptionSection
                        analyzeButton

                        if manager.isAnalyzing {
                            loadingPlaceholder
                        }

                        if let result = manager.analysisResult {
                            resultCard(result)
                        }

                        if let error = manager.errorMessage {
                            errorBanner(error)
                        }
                    }
                    .padding(KTheme.screenPadding)
                }
            }
            .navigationTitle("Log Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(KTheme.accentOrange)
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
                    .clipShape(RoundedRectangle(cornerRadius: KTheme.cornerRadius))
                    .overlay(
                        RoundedRectangle(cornerRadius: KTheme.cornerRadius)
                            .stroke(KTheme.border, lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: KTheme.cornerRadius)
                    .fill(KTheme.backgroundCard)
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: KTheme.cornerRadius)
                            .stroke(KTheme.accentOrange.opacity(0.3), lineWidth: 2)
                    )
                    .overlay {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(KTheme.accentGradient)
                            Text("Select a meal photo")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundColor(KTheme.textSecondary)
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
                .font(.system(.body, design: .rounded))
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(KTheme.backgroundElevated)
                .foregroundColor(KTheme.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius)
                        .stroke(KTheme.border, lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Description Input

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What are you eating?")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(KTheme.textPrimary)

            TextField("e.g. Grilled chicken with rice and salad", text: $manager.mealDescription)
                .font(.system(.body, design: .rounded))
                .padding(14)
                .background(KTheme.backgroundCard)
                .foregroundColor(KTheme.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(KTheme.border, lineWidth: 1)
                )
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
            }
        }
        .buttonStyle(GradientButtonStyle(
            isEnabled: manager.imageData != nil && !manager.mealDescription.isEmpty
        ))
        .disabled(manager.isAnalyzing || manager.imageData == nil || manager.mealDescription.isEmpty)
    }

    // MARK: - Loading Placeholder

    private var loadingPlaceholder: some View {
        VStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 8)
                .fill(KTheme.backgroundElevated)
                .frame(height: 20)
            RoundedRectangle(cornerRadius: 8)
                .fill(KTheme.backgroundElevated)
                .frame(height: 20)
                .padding(.trailing, 60)
            RoundedRectangle(cornerRadius: 8)
                .fill(KTheme.backgroundElevated)
                .frame(height: 20)
                .padding(.trailing, 120)
        }
        .padding(KTheme.cardPadding)
        .glassCard()
        .shimmer()
    }

    // MARK: - Result Card

    private func resultCard(_ result: GeminiMealResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Analysis Result")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(KTheme.textPrimary)

            // Ingredients
            ForEach(Array(result.ingredients.enumerated()), id: \.offset) { _, ingredient in
                HStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(KTheme.accentOrange)
                        .frame(width: 24)

                    Text(ingredient.name)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(KTheme.textPrimary)

                    Spacer()

                    // Macro pills
                    HStack(spacing: 4) {
                        macroPill("\(Int(ingredient.protein))p", color: KTheme.proteinColor)
                        macroPill("\(Int(ingredient.carbs))c", color: KTheme.carbsColor)
                        macroPill("\(Int(ingredient.fat))f", color: KTheme.fatColor)
                    }

                    Text("\(ingredient.calories)")
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(KTheme.textSecondary)
                }
            }

            Rectangle()
                .fill(KTheme.border)
                .frame(height: 1)

            // Total
            HStack {
                Text("Total")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(KTheme.textPrimary)
                Spacer()
                Text("\(result.totalCalories) kcal")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(KTheme.accentGradient)
            }

            // Macro summary
            HStack(spacing: 16) {
                macroSummaryItem("Protein", value: result.totalProtein, color: KTheme.proteinColor)
                macroSummaryItem("Carbs", value: result.totalCarbs, color: KTheme.carbsColor)
                macroSummaryItem("Fat", value: result.totalFat, color: KTheme.fatColor)
            }

            // Save Button
            Button(action: saveMeal) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Meal")
                }
                .font(.system(.headline, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius)
                        .fill(KTheme.successGradient)
                )
            }
        }
        .padding(KTheme.cardPadding)
        .glassCard()
    }

    private func macroPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }

    private func macroSummaryItem(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(value))g")
                .font(.system(.body, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(.caption2, design: .rounded))
                .foregroundColor(KTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error Banner

    private func errorBanner(_ message: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(KTheme.danger)
            Text(message)
                .font(.system(.callout, design: .rounded))
                .foregroundColor(KTheme.danger)
        }
        .padding(KTheme.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                .fill(KTheme.danger.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                        .stroke(KTheme.danger.opacity(0.3), lineWidth: 1)
                )
        )
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
        .preferredColorScheme(.dark)
}
