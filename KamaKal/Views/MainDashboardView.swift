import SwiftUI
import SwiftData

struct MainDashboardView: View {
    @Query private var users: [User]
    @Query private var todayMeals: [Meal]

    init() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let predicate = #Predicate<Meal> { meal in meal.date >= startOfDay }
        _todayMeals = Query(filter: predicate, sort: \Meal.date, order: .reverse)
    }

    @State private var animatedProgress: Double = 0.0

    private var user: User? { users.first }

    private var totalConsumed: Int {
        todayMeals.reduce(0) { $0 + $1.totalCalories }
    }

    private var target: Int {
        user?.dailyCalorieTarget ?? 2000
    }

    private var remaining: Int {
        target - totalConsumed
    }

    private var progress: Double {
        guard target > 0 else { return 0 }
        return Double(totalConsumed) / Double(target)
    }

    private var totalProtein: Double {
        todayMeals.reduce(0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        todayMeals.reduce(0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        todayMeals.reduce(0) { $0 + $1.fat }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good morning!" }
        if hour < 17 { return "Good afternoon!" }
        return "Good evening!"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    // Greeting
                    greetingHeader
                        .padding(.top, 8)

                    // Progress Ring
                    progressRing
                        .padding(.horizontal)

                    // Macro Cards
                    macroRow

                    // Today's Meals
                    mealsSection
                }
                .padding(.bottom, 100)
            }
            .background(KTheme.backgroundPrimary)
            .navigationBarHidden(true)
            .onAppear {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.75)) {
                    animatedProgress = min(progress, 1.0)
                }
            }
            .onChange(of: progress) { _, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedProgress = min(newValue, 1.0)
                }
            }
        }
    }

    // MARK: - Greeting Header

    private var greetingHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(greeting)
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(KTheme.textPrimary)

            Text(Date(), style: .date)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(KTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, KTheme.screenPadding)
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        VStack(spacing: 20) {
            ZStack {
                // Background ring
                Circle()
                    .stroke(KTheme.backgroundElevated, lineWidth: 20)

                // Progress ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(animatedProgress))
                    .stroke(
                        AngularGradient(
                            colors: [KTheme.accentOrange, KTheme.accentPink, KTheme.accentOrange],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: KTheme.accentOrange.opacity(0.3), radius: 8)

                // Inner text
                VStack(spacing: 4) {
                    Text("\(totalConsumed)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(KTheme.textPrimary)

                    Text("/ \(target) kcal")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)
                }
            }
            .frame(width: 220, height: 220)

            // Remaining
            Text("\(remaining) kcal remaining")
                .font(.system(.headline, design: .rounded))
                .foregroundColor(remaining < 0 ? KTheme.danger : KTheme.textSecondary)
        }
        .padding()
        .glassCard(cornerRadius: KTheme.cornerRadius)
    }

    // MARK: - Macro Row

    private var macroRow: some View {
        HStack(spacing: 12) {
            macroCard(label: "Protein", value: totalProtein, unit: "g", color: KTheme.proteinColor, icon: "fish.fill")
            macroCard(label: "Carbs", value: totalCarbs, unit: "g", color: KTheme.carbsColor, icon: "leaf.fill")
            macroCard(label: "Fat", value: totalFat, unit: "g", color: KTheme.fatColor, icon: "drop.fill")
        }
        .padding(.horizontal, KTheme.screenPadding)
    }

    private func macroCard(label: String, value: Double, unit: String, color: Color, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)

            Text("\(Int(value))\(unit)")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(KTheme.textPrimary)

            Text(label)
                .font(.system(.caption, design: .rounded))
                .foregroundColor(KTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassCard()
    }

    // MARK: - Meals Section

    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Meals")
                .font(.system(.title3, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(KTheme.textPrimary)
                .padding(.horizontal, KTheme.screenPadding)

            if todayMeals.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife.circle")
                        .font(.system(size: 40))
                        .foregroundColor(KTheme.textSecondary)

                    Text("No meals logged today")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)

                    Text("Tap + to add your first meal!")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(KTheme.textSecondary.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(spacing: 12) {
                    ForEach(todayMeals) { meal in
                        MealCardView(meal: meal)
                    }
                }
                .padding(.horizontal, KTheme.screenPadding)
            }
        }
    }
}

// MARK: - Meal Card View

struct MealCardView: View {
    let meal: Meal

    var body: some View {
        HStack(spacing: 14) {
            // Thumbnail
            if let imagePath = meal.imagePath,
               let imageURL = MealCaptureManager.imageURL(for: imagePath),
               let uiImage = UIImage(contentsOfFile: imageURL.path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(KTheme.backgroundElevated)
                    .frame(width: 64, height: 64)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundColor(KTheme.textSecondary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.textDescription.isEmpty ? "Meal" : meal.textDescription)
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(KTheme.textPrimary)
                    .lineLimit(1)

                Text(meal.createdAt, style: .time)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
            }

            Spacer()

            // Calories
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text("\(meal.totalCalories)")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(KTheme.accentGradient)
                Text("kcal")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
            }
        }
        .padding(KTheme.cardPadding)
        .glassCard()
    }
}

#Preview {
    MainDashboardView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
        .preferredColorScheme(.dark)
}
