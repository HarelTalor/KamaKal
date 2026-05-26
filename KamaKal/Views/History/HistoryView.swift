import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Meal.date, order: .reverse) private var allMeals: [Meal]
    @Query private var users: [User]
    
    /// Groups all meals by their calendar day, calculates the total calories, and sorts descending.
    private var groupedMeals: [(date: Date, meals: [Meal], totalCalories: Int, isUnderTarget: Bool)] {
        let target = users.first?.dailyCalorieTarget ?? 2000
        
        let grouped = Dictionary(grouping: allMeals) { meal in
            Calendar.current.startOfDay(for: meal.date)
        }
        
        return grouped.map { (date, meals) in
            let total = meals.reduce(0) { $0 + $1.totalCalories }
            return (
                date: date,
                meals: meals,
                totalCalories: total,
                isUnderTarget: total <= target
            )
        }.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            List {
                if groupedMeals.isEmpty {
                    ContentUnavailableView(
                        "No History",
                        systemImage: "clock",
                        description: Text("Your past logged meals will appear here.")
                    )
                } else {
                    ForEach(groupedMeals, id: \.date) { group in
                        NavigationLink(destination: DailyDetailView(date: group.date, meals: group.meals)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(group.date, style: .date)
                                        .font(.headline)
                                    
                                    Text("\(group.meals.count) meals")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Text("\(group.totalCalories) kcal")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(group.isUnderTarget ? .green : .red)
                                
                                Image(systemName: group.isUnderTarget ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(group.isUnderTarget ? .green : .red)
                                    .font(.title3)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .onDelete { offsets in
                        deleteMeals(from: groupedMeals, at: offsets)
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    // MARK: - Deletion

    private func deleteMeals(
        from groups: [(date: Date, meals: [Meal], totalCalories: Int, isUnderTarget: Bool)],
        at offsets: IndexSet
    ) {
        for index in offsets {
            let group = groups[index]
            for meal in group.meals {
                modelContext.delete(meal)
            }
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
}
