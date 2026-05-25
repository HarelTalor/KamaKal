import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Query private var users: [User]
    @Query(
        filter: #Predicate<Meal> {
            $0.date >= Calendar.current.startOfDay(for: Date())
        },
        sort: \Meal.createdAt, order: .reverse
    ) private var todayMeals: [Meal]
    
    @State private var showMealCapture = false
    
    private var user: User? { users.first }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Summary Section
                if let user {
                    Section {
                        VStack(spacing: 8) {
                            Text("\(totalConsumed) / \(user.dailyCalorieTarget)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))

                            Text("kcal consumed today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            ProgressView(value: min(progress, 1.0))
                                .tint(progress > 1.0 ? .red : .blue)
                                .padding(.top, 4)

                            Text("\(remaining) kcal remaining")
                                .font(.caption)
                                .foregroundColor(remaining < 0 ? .red : .green)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                    }
                }

                // MARK: - Today's Meals
                Section(header: Text("Today's Meals")) {
                    if todayMeals.isEmpty {
                        ContentUnavailableView(
                            "No meals yet",
                            systemImage: "fork.knife",
                            description: Text("Tap + to log your first meal")
                        )
                    } else {
                        ForEach(todayMeals, id: \.id) { meal in
                            mealRow(meal)
                        }
                    }
                }
            }
            .navigationTitle("KamaKal")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showMealCapture = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showMealCapture) {
                MealCaptureView()
            }
        }
    }

    // MARK: - Computed

    private var totalConsumed: Int {
        todayMeals.reduce(0) { $0 + $1.totalCalories }
    }

    private var remaining: Int {
        (user?.dailyCalorieTarget ?? 0) - totalConsumed
    }

    private var progress: Double {
        guard let target = user?.dailyCalorieTarget, target > 0 else { return 0 }
        return Double(totalConsumed) / Double(target)
    }

    // MARK: - Row

    private func mealRow(_ meal: Meal) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.textDescription)
                    .font(.headline)
                    .lineLimit(1)

                Text(meal.ingredients.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            Text("\(meal.totalCalories) kcal")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    MainDashboardView()
}

