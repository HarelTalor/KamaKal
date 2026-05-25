import SwiftUI
import SwiftData

enum OnboardingStep: Hashable {
    case bodyStats
    case lifestyle
    case result
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    
    // Navigation State
    @State private var path = NavigationPath()
    
    // User Data State
    @State private var age: Int = 25
    @State private var gender: Gender = .female
    @State private var heightCm: Double = 165.0
    @State private var weightKg: Double = 65.0
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var goal: Goal = .maintain
    
    // Calculated Result
    @State private var calculatedTarget: Int = 0
    
    var body: some View {
        NavigationStack(path: $path) {
            basicInfoView
                .navigationTitle("About You")
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .bodyStats:
                        bodyStatsView
                            .navigationTitle("Your Body")
                    case .lifestyle:
                        lifestyleView
                            .navigationTitle("Lifestyle & Goals")
                    case .result:
                        resultView
                            .navigationTitle("Your Target")
                    }
                }
        }
    }
    
    // MARK: - Step 1: Basic Info
    private var basicInfoView: some View {
        Form {
            Section(header: Text("Basic Information")) {
                Stepper("Age: \(age)", value: $age, in: 10...120)
                
                Picker("Gender", selection: $gender) {
                    Text("Male").tag(Gender.male)
                    Text("Female").tag(Gender.female)
                    Text("Other").tag(Gender.other)
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                Button(action: {
                    path.append(OnboardingStep.bodyStats)
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
        }
    }
    
    // MARK: - Step 2: Body Stats
    private var bodyStatsView: some View {
        Form {
            Section(header: Text("Measurements")) {
                VStack(alignment: .leading) {
                    Text("Height: \(Int(heightCm)) cm")
                    Slider(value: $heightCm, in: 100...250, step: 1)
                }
                .padding(.vertical, 4)
                
                VStack(alignment: .leading) {
                    Text("Weight: \(weightKg, specifier: "%.1f") kg")
                    Slider(value: $weightKg, in: 30...200, step: 0.5)
                }
                .padding(.vertical, 4)
            }
            
            Section {
                Button(action: {
                    path.append(OnboardingStep.lifestyle)
                }) {
                    Text("Next")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
        }
    }
    
    // MARK: - Step 3: Lifestyle & Goals
    private var lifestyleView: some View {
        Form {
            Section(header: Text("Activity Level")) {
                Picker("Activity Level", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.menu)
            }
            
            Section(header: Text("Your Goal")) {
                Picker("Goal", selection: $goal) {
                    ForEach(Goal.allCases, id: \.self) { g in
                        Text(g.displayName).tag(g)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section {
                Button(action: {
                    calculateAndGoToResult()
                }) {
                    Text("Calculate My Target")
                        .frame(maxWidth: .infinity)
                        .bold()
                }
            }
        }
    }
    
    // MARK: - Step 4: Result
    private var resultView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Your Daily Calorie Target")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("\(calculatedTarget)")
                .font(.system(size: 64, weight: .bold, design: .rounded))
                .foregroundColor(.blue)
            
            Text("kcal / day")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: finishOnboarding) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 40)
        }
    }
    
    // MARK: - Logic
    
    private func calculateAndGoToResult() {
        calculatedTarget = CalculatorService.calculateDailyTarget(
            age: age,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal
        )
        path.append(OnboardingStep.result)
    }
    
    private func finishOnboarding() {
        let newUser = User(
            age: age,
            gender: gender,
            heightCm: heightCm,
            weightKg: weightKg,
            activityLevel: activityLevel,
            goal: goal,
            dailyCalorieTarget: calculatedTarget
        )
        
        modelContext.insert(newUser)
        // SwiftUI View will automatically switch since @Query in ContentView will detect the new user
    }
}

#Preview {
    OnboardingView()
}
