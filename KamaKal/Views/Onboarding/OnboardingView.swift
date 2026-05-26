import SwiftUI
import SwiftData

enum OnboardingStep: Hashable {
    case bodyStats
    case lifestyle
    case result
}

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var path = NavigationPath()
    @State private var age: Int = 25
    @State private var gender: Gender = .female
    @State private var heightCm: Double = 165.0
    @State private var weightKg: Double = 65.0
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var goal: Goal = .maintain
    @State private var calculatedTarget: Int = 0
    @State private var animatedTarget: Int = 0

    private var currentStep: Int {
        path.count
    }

    var body: some View {
        NavigationStack(path: $path) {
            basicInfoView
                .navigationDestination(for: OnboardingStep.self) { step in
                    switch step {
                    case .bodyStats:
                        bodyStatsView
                    case .lifestyle:
                        lifestyleView
                    case .result:
                        resultView
                    }
                }
        }
    }

    // MARK: - Step Indicator

    private func stepIndicator(current: Int, total: Int = 4) -> some View {
        HStack(spacing: 8) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index <= current ? KTheme.accentOrange : KTheme.backgroundElevated)
                    .frame(width: index == current ? 28 : 12, height: 6)
                    .animation(.spring(response: 0.3), value: current)
            }
        }
    }

    // MARK: - Step 1: Basic Info

    private var basicInfoView: some View {
        ZStack {
            KTheme.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    stepIndicator(current: 0)
                        .padding(.top, 16)

                    // Hero Icon
                    Image(systemName: "person.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(KTheme.accentGradient)
                        .padding(.top, 20)

                    Text("About You")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(KTheme.textPrimary)

                    // Age
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Age")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(KTheme.textSecondary)

                        HStack {
                            Button(action: { if age > 10 { age -= 1 }}) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(KTheme.accentOrange)
                            }

                            Text("\(age)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(KTheme.textPrimary)
                                .frame(width: 80)

                            Button(action: { if age < 120 { age += 1 }}) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(KTheme.accentOrange)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .glassCard()
                    }

                    // Gender
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Gender")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(KTheme.textSecondary)

                        HStack(spacing: 12) {
                            genderPill("Male", value: .male, icon: "figure.stand")
                            genderPill("Female", value: .female, icon: "figure.stand.dress")
                            genderPill("Other", value: .other, icon: "person.fill")
                        }
                    }

                    Spacer(minLength: 40)

                    Button(action: { path.append(.bodyStats) }) {
                        Text("Next")
                    }
                    .buttonStyle(GradientButtonStyle())
                }
                .padding(.horizontal, KTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    private func genderPill(_ label: String, value: Gender, icon: String) -> some View {
        Button(action: { gender = value }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .foregroundColor(gender == value ? .white : KTheme.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                    .fill(gender == value ? AnyShapeStyle(KTheme.accentGradient) : AnyShapeStyle(KTheme.backgroundCard))
            )
            .overlay(
                RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                    .stroke(gender == value ? Color.clear : KTheme.border, lineWidth: 1)
            )
        }
        .animation(.spring(response: 0.3), value: gender)
    }

    // MARK: - Step 2: Body Stats

    private var bodyStatsView: some View {
        ZStack {
            KTheme.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    stepIndicator(current: 1)
                        .padding(.top, 16)

                    Image(systemName: "ruler")
                        .font(.system(size: 56))
                        .foregroundStyle(KTheme.accentGradient)
                        .padding(.top, 20)

                    Text("Your Body")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(KTheme.textPrimary)

                    // Height
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Height")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(KTheme.textSecondary)
                            Spacer()
                            Text("\(Int(heightCm)) cm")
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(KTheme.accentOrange)
                        }

                        Slider(value: $heightCm, in: 100...250, step: 1)
                            .tint(KTheme.accentOrange)
                    }
                    .padding(KTheme.cardPadding)
                    .glassCard()

                    // Weight
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Weight")
                                .font(.system(.headline, design: .rounded))
                                .foregroundColor(KTheme.textSecondary)
                            Spacer()
                            Text(String(format: "%.1f kg", weightKg))
                                .font(.system(.title3, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(KTheme.accentOrange)
                        }

                        Slider(value: $weightKg, in: 30...200, step: 0.5)
                            .tint(KTheme.accentOrange)
                    }
                    .padding(KTheme.cardPadding)
                    .glassCard()

                    Spacer(minLength: 40)

                    Button(action: { path.append(.lifestyle) }) {
                        Text("Next")
                    }
                    .buttonStyle(GradientButtonStyle())
                }
                .padding(.horizontal, KTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Step 3: Lifestyle

    private var lifestyleView: some View {
        ZStack {
            KTheme.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    stepIndicator(current: 2)
                        .padding(.top, 16)

                    Image(systemName: "figure.walk")
                        .font(.system(size: 56))
                        .foregroundStyle(KTheme.accentGradient)
                        .padding(.top, 20)

                    Text("Lifestyle & Goals")
                        .font(.system(.largeTitle, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(KTheme.textPrimary)

                    // Activity Level
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Activity Level")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(KTheme.textSecondary)

                        VStack(spacing: 8) {
                            ForEach(ActivityLevel.allCases, id: \.self) { level in
                                Button(action: { activityLevel = level }) {
                                    HStack {
                                        Text(level.displayName)
                                            .font(.system(.body, design: .rounded))
                                            .fontWeight(.medium)
                                        Spacer()
                                        if activityLevel == level {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(KTheme.accentOrange)
                                        }
                                    }
                                    .foregroundColor(activityLevel == level ? KTheme.textPrimary : KTheme.textSecondary)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(activityLevel == level ? KTheme.backgroundElevated : Color.clear)
                                    )
                                }
                            }
                        }
                        .padding(4)
                        .glassCard()
                    }

                    // Goal
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your Goal")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(KTheme.textSecondary)

                        HStack(spacing: 12) {
                            ForEach(Goal.allCases, id: \.self) { g in
                                Button(action: { goal = g }) {
                                    Text(g.displayName)
                                        .font(.system(.subheadline, design: .rounded))
                                        .fontWeight(.semibold)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .foregroundColor(goal == g ? .white : KTheme.textSecondary)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(goal == g ? AnyShapeStyle(KTheme.accentGradient) : AnyShapeStyle(KTheme.backgroundCard))
                                        )
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(goal == g ? Color.clear : KTheme.border, lineWidth: 1)
                                        )
                                }
                                .animation(.spring(response: 0.3), value: goal)
                            }
                        }
                    }

                    Spacer(minLength: 40)

                    Button(action: { calculateAndGoToResult() }) {
                        Text("Calculate My Target")
                    }
                    .buttonStyle(GradientButtonStyle())
                }
                .padding(.horizontal, KTheme.screenPadding)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Step 4: Result

    private var resultView: some View {
        ZStack {
            KTheme.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 32) {
                stepIndicator(current: 3)
                    .padding(.top, 16)

                Spacer()

                Image(systemName: "target")
                    .font(.system(size: 56))
                    .foregroundStyle(KTheme.accentGradient)

                Text("Your Daily Target")
                    .font(.system(.title2, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)

                Text("\(animatedTarget)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(KTheme.accentGradient)
                    .contentTransition(.numericText())

                Text("kcal / day")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)

                Spacer()

                Button(action: finishOnboarding) {
                    Text("Get Started")
                }
                .buttonStyle(GradientButtonStyle())
                .padding(.horizontal, KTheme.screenPadding)
                .padding(.bottom, 40)
            }
            .padding(.horizontal, KTheme.screenPadding)
        }
        .navigationBarHidden(true)
        .onAppear {
            animateCounter()
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

    private func animateCounter() {
        animatedTarget = 0
        let steps = 40
        let delay = 0.6 / Double(steps)
        for i in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(i)) {
                withAnimation(.easeOut(duration: 0.05)) {
                    animatedTarget = Int(Double(calculatedTarget) * Double(i) / Double(steps))
                }
            }
        }
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
    }
}

#Preview {
    OnboardingView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
}
