import SwiftUI
import SwiftData

struct DailyDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let date: Date
    let meals: [Meal]
    
    var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 4) {
                    Text("\(totalCalories) kcal")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                    Text("Total for the day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Meals List
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
            .padding()
        }
        .navigationTitle(date.formatted(date: .abbreviated, time: .omitted))
        .navigationBarTitleDisplayMode(.inline)
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
                    .fill(Color(.systemGray5))
                    .frame(height: 120)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                    }
            }
            
            VStack(alignment: .leading, spacing: 16) {
                // Title and Calories
                HStack(alignment: .top) {
                    Text(meal.textDescription.isEmpty ? "Unknown Meal" : meal.textDescription)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(meal.totalCalories) kcal")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                
                Divider()
                
                // Ingredients Breakdown — use enumerated offset as ID to handle duplicates (W10)
                VStack(alignment: .leading, spacing: 8) {
                    Text("AI Analysis Breakdown")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                    
                    ForEach(Array(zip(meal.ingredients, meal.caloriesPerIngredient).enumerated()), id: \.offset) { _, pair in
                        let (ingredient, calories) = pair
                        HStack {
                            Text(ingredient)
                                .font(.body)
                            Spacer()
                            Text("\(calories) kcal")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Time
                Text(meal.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.top, 4)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        .padding(.horizontal, 4) // slight padding for shadow visibility
    }
}
