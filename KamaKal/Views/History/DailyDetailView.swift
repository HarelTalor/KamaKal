import SwiftUI
import SwiftData

struct DailyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let meals: [Meal]

    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }

    private var totalProtein: Double {
        meals.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        meals.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        meals.reduce(0) { $0 + $1.fat }
    }

    var body: some View {
        ZStack {
            KTheme.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Meals
                    ForEach(meals.sorted(by: { $0.createdAt > $1.createdAt })) { meal in
                        mealDetailCard(meal)
                            .contextMenu {
                                Button(role: .destructive) {
                                    deleteMeal(meal)
                                } label: {
                                    Label("Delete Meal", systemImage: "trash")
                                }
                            }
                    }
                }
                .padding(KTheme.screenPadding)
            }
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(totalCalories)")
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(KTheme.accentGradient)
                Text("kcal")
                    .font(.system(.title3, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
            }

            // Macro row
            HStack(spacing: 24) {
                macroItem(label: "Protein", value: totalProtein, color: KTheme.proteinColor)
                macroItem(label: "Carbs", value: totalCarbs, color: KTheme.carbsColor)
                macroItem(label: "Fat", value: totalFat, color: KTheme.fatColor)
            }
        }
        .padding(KTheme.cardPadding)
        .frame(maxWidth: .infinity)
        .glassCard()
    }

    private func macroItem(label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text("\(Int(value))g")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(KTheme.textSecondary)
        }
    }

    // MARK: - Delete

    private func deleteMeal(_ meal: Meal) {
        modelContext.delete(meal)
    }

    // MARK: - Meal Detail Card

    private func mealDetailCard(_ meal: Meal) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image Header
            if let imagePath = meal.imagePath,
               let imageURL = MealCaptureManager.imageURL(for: imagePath),
               let uiImage = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
            } else {
                Rectangle()
                    .fill(KTheme.backgroundElevated)
                    .frame(height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(KTheme.textSecondary)
                    }
            }

            VStack(alignment: .leading, spacing: 16) {
                // Title and Calories
                HStack(alignment: .top) {
                    Text(meal.textDescription.isEmpty ? "Unknown Meal" : meal.textDescription)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(KTheme.textPrimary)

                    Spacer()

                    Text("\(meal.totalCalories) kcal")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(KTheme.accentGradient)
                }

                // Macro pills
                HStack(spacing: 8) {
                    macroPill("P: \(Int(meal.protein))g", color: KTheme.proteinColor)
                    macroPill("C: \(Int(meal.carbs))g", color: KTheme.carbsColor)
                    macroPill("F: \(Int(meal.fat))g", color: KTheme.fatColor)
                }

                Rectangle()
                    .fill(KTheme.border)
                    .frame(height: 1)

                // Ingredients Breakdown
                VStack(alignment: .leading, spacing: 8) {
                    Text("Breakdown")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)
                        .textCase(.uppercase)

                    ForEach(Array(zip(meal.ingredients, meal.caloriesPerIngredient).enumerated()), id: \.offset) { index, pair in
                        let (ingredient, calories) = pair
                        HStack {
                            Text(ingredient)
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(KTheme.textPrimary)
                            Spacer()
                            Text("\(calories) kcal")
                                .font(.system(.body, design: .rounded))
                                .foregroundColor(KTheme.textSecondary)
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        .background(
                            index % 2 == 0
                                ? KTheme.backgroundElevated.opacity(0.3)
                                : Color.clear
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }

                // Time
                Text(meal.createdAt, style: .time)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }
            .padding(KTheme.cardPadding)
        }
        .glassCard(cornerRadius: KTheme.cornerRadius)
    }

    private func macroPill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold, design: .rounded))
            .foregroundColor(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
    }
}
