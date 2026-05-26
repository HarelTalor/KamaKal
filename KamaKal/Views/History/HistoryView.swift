import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.date, order: .reverse) private var allMeals: [Meal]
    @Query private var users: [User]

    private var target: Int {
        users.first?.dailyCalorieTarget ?? 2000
    }

    private var groupedMeals: [(date: Date, meals: [Meal], totalCalories: Int, progress: Double)] {
        let grouped = Dictionary(grouping: allMeals) { meal in
            Calendar.current.startOfDay(for: meal.date)
        }

        return grouped.map { (date, meals) in
            let total = meals.reduce(0) { $0 + $1.totalCalories }
            let prog = target > 0 ? Double(total) / Double(target) : 0
            return (date: date, meals: meals, totalCalories: total, progress: prog)
        }.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KTheme.backgroundPrimary.ignoresSafeArea()

                if groupedMeals.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(groupedMeals, id: \.date) { group in
                                NavigationLink(destination: DailyDetailView(date: group.date, meals: group.meals)) {
                                    dayCard(group)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, KTheme.screenPadding)
                        .padding(.top, 8)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("History")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.badge.questionmark")
                .font(.system(size: 56))
                .foregroundColor(KTheme.textSecondary.opacity(0.5))

            Text("No History")
                .font(.system(.title2, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(KTheme.textPrimary)

            Text("Your past meals will appear here.")
                .font(.system(.body, design: .rounded))
                .foregroundColor(KTheme.textSecondary)
        }
    }

    // MARK: - Day Card

    private func dayCard(_ group: (date: Date, meals: [Meal], totalCalories: Int, progress: Double)) -> some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(group.date, style: .date)
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(KTheme.textPrimary)

                    Text("\(group.meals.count) meal\(group.meals.count == 1 ? "" : "s")")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)
                }

                Spacer()

                Text("\(group.totalCalories) kcal")
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(statusColor(for: group.progress))

                Image(systemName: statusIcon(for: group.progress))
                    .foregroundColor(statusColor(for: group.progress))
                    .font(.title3)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(KTheme.backgroundElevated)
                        .frame(height: 6)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(statusColor(for: group.progress))
                        .frame(width: min(geo.size.width * CGFloat(group.progress), geo.size.width), height: 6)
                }
            }
            .frame(height: 6)
        }
        .padding(KTheme.cardPadding)
        .glassCard()
    }

    private func statusColor(for progress: Double) -> Color {
        if progress <= 0.8 { return KTheme.success }
        if progress <= 1.0 { return KTheme.warning }
        return KTheme.danger
    }

    private func statusIcon(for progress: Double) -> String {
        if progress <= 1.0 { return "checkmark.circle.fill" }
        return "xmark.circle.fill"
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
        .preferredColorScheme(.dark)
}
