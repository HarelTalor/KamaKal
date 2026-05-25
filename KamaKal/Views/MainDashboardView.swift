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
    @State private var animatedProgress: Double = 0.0
    
    private var user: User? { users.first }
    
    // Computed Properties
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
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 40) {
                        // 1 & 2: Progress Ring & Remaining Text
                        progressSection
                            .padding(.top, 32)
                        
                        // 4: Today's Meals (Horizontal List)
                        mealsSection
                    }
                    .padding(.bottom, 100) // Space for FAB
                }
                
                // 3: FAB
                fabButton
            }
            .navigationTitle("Today")
            .sheet(isPresented: $showMealCapture) {
                MealCaptureView()
            }
            .onChange(of: progress) { oldValue, newValue in
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedProgress = min(newValue, 1.0)
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animatedProgress = min(progress, 1.0)
                }
            }
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 32) {
            ZStack {
                // Background Ring
                Circle()
                    .stroke(lineWidth: 24)
                    .opacity(0.2)
                    .foregroundColor(.blue)
                
                // Progress Ring
                Circle()
                    .trim(from: 0.0, to: CGFloat(animatedProgress))
                    .stroke(style: StrokeStyle(lineWidth: 24, lineCap: .round, lineJoin: .round))
                    .foregroundColor(progress > 1.0 ? .red : .blue)
                    .rotationEffect(Angle(degrees: 270.0))
                
                // Inner Text
                VStack(spacing: 8) {
                    Text("\(totalConsumed)")
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                    Text("/ \(target) kcal")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 250, height: 250)
            .padding()
            
            Text("Remaining Calories: \(remaining)")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(remaining < 0 ? .red : .primary)
        }
    }
    
    // MARK: - Meals Section
    private var mealsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Logs")
                .font(.headline)
                .padding(.horizontal)
            
            if todayMeals.isEmpty {
                Text("No meals logged today. Tap + to add one!")
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(todayMeals) { meal in
                            MealCardView(meal: meal)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    // MARK: - FAB
    private var fabButton: some View {
        Button(action: {
            showMealCapture = true
        }) {
            Image(systemName: "plus")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .padding(24)
    }
}

// MARK: - Meal Card View
struct MealCardView: View {
    let meal: Meal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imagePath = meal.imagePath,
               let uiImage = UIImage(contentsOfFile: imagePath) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .frame(width: 140, height: 100)
                    .overlay {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.secondary)
                            .font(.largeTitle)
                    }
            }
            
            Text(meal.textDescription.isEmpty ? "Meal" : meal.textDescription)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text("\(meal.totalCalories) kcal")
                .font(.caption)
                .foregroundColor(.blue)
                .fontWeight(.bold)
        }
        .frame(width: 140)
    }
}

#Preview {
    MainDashboardView()
}
