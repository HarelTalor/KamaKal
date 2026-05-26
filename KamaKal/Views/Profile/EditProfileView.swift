import SwiftUI
import SwiftData

/// Sheet for editing all user profile fields in-place.
struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    let user: User

    // Local editable copies of all fields
    @State private var age: Int
    @State private var gender: Gender
    @State private var heightCm: Double
    @State private var weightKg: Double
    @State private var activityLevel: ActivityLevel
    @State private var goal: Goal
    @State private var calorieMode: CalorieMode
    @State private var customCalorieTarget: Int

    init(user: User) {
        self.user = user
        _age = State(initialValue: user.age)
        _gender = State(initialValue: user.gender)
        _heightCm = State(initialValue: user.heightCm)
        _weightKg = State(initialValue: user.weightKg)
        _activityLevel = State(initialValue: user.activityLevel)
        _goal = State(initialValue: user.goal)
        _calorieMode = State(initialValue: user.usesCustomCalorieTarget ? .custom : .formula)
        _customCalorieTarget = State(initialValue: user.dailyCalorieTarget)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                KTheme.backgroundPrimary.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {

                        // ── Age ──────────────────────────────────────────────
                        sectionHeader("Age")
                        HStack {
                            Button(action: { if age > 10 { age -= 1 } }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(KTheme.accentOrange)
                            }
                            Text("\(age)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(KTheme.textPrimary)
                                .frame(maxWidth: .infinity)
                            Button(action: { if age < 120 { age += 1 } }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(KTheme.accentOrange)
                            }
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, KTheme.cardPadding)
                        .glassCard()

                        // ── Gender ───────────────────────────────────────────
                        sectionHeader("Gender")
                        HStack(spacing: 12) {
                            genderPill("Male", value: .male, icon: "figure.stand")
                            genderPill("Female", value: .female, icon: "figure.stand.dress")
                            genderPill("Other", value: .other, icon: "person.fill")
                        }

                        // ── Height ───────────────────────────────────────────
                        sectionHeader("Height")
                        VStack(spacing: 8) {
                            HStack {
                                Text("\(Int(heightCm)) cm")
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(KTheme.accentOrange)
                                Spacer()
                            }
                            Slider(value: $heightCm, in: 100...250, step: 1)
                                .tint(KTheme.accentOrange)
                        }
                        .padding(KTheme.cardPadding)
                        .glassCard()

                        // ── Weight ───────────────────────────────────────────
                        sectionHeader("Weight")
                        VStack(spacing: 8) {
                            HStack {
                                Text(String(format: "%.1f kg", weightKg))
                                    .font(.system(.title3, design: .rounded))
                                    .fontWeight(.bold)
                                    .foregroundColor(KTheme.accentOrange)
                                Spacer()
                            }
                            Slider(value: $weightKg, in: 30...200, step: 0.5)
                                .tint(KTheme.accentOrange)
                        }
                        .padding(KTheme.cardPadding)
                        .glassCard()

                        // ── Calorie Mode ─────────────────────────────────────
                        sectionHeader("Calorie Target")
                        HStack(spacing: 0) {
                            modeTab(label: "Formula", icon: "wand.and.stars", mode: .formula)
                            modeTab(label: "Custom", icon: "slider.horizontal.3", mode: .custom)
                        }
                        .padding(4)
                        .glassCard()

                        if calorieMode == .formula {
                            // Activity
                            sectionHeader("Activity Level")
                            VStack(spacing: 6) {
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
                                        .padding(.vertical, 12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(activityLevel == level ? KTheme.backgroundElevated : Color.clear)
                                        )
                                    }
                                }
                            }
                            .padding(4)
                            .glassCard()

                            // Goal
                            sectionHeader("Goal")
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

                        if calorieMode == .custom {
                            VStack(spacing: 16) {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(customCalorieTarget)")
                                        .font(.system(size: 56, weight: .bold, design: .rounded))
                                        .foregroundStyle(KTheme.accentGradient)
                                        .contentTransition(.numericText())
                                        .animation(.spring(response: 0.3), value: customCalorieTarget)
                                    Text("kcal")
                                        .font(.system(.title2, design: .rounded))
                                        .foregroundColor(KTheme.textSecondary)
                                }
                                .padding(.vertical, 20)
                                .frame(maxWidth: .infinity)
                                .glassCard()

                                HStack(spacing: 12) {
                                    stepperBtn("-100", amount: -100)
                                    stepperBtn("-50", amount: -50)
                                    stepperBtn("+50", amount: 50)
                                    stepperBtn("+100", amount: 100)
                                }

                                Slider(value: Binding(
                                    get: { Double(customCalorieTarget) },
                                    set: { customCalorieTarget = Int($0) }
                                ), in: 800...5000, step: 50)
                                .tint(KTheme.accentOrange)
                                .padding(KTheme.cardPadding)
                                .glassCard()
                            }
                        }

                        // ── Save Button ──────────────────────────────────────
                        Button(action: save) {
                            Text("Save Changes")
                        }
                        .buttonStyle(GradientButtonStyle())
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, KTheme.screenPadding)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Profile")
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

    // MARK: - Helpers

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(.headline, design: .rounded))
            .foregroundColor(KTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func genderPill(_ label: String, value: Gender, icon: String) -> some View {
        Button(action: { gender = value }) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 22))
                Text(label).font(.system(.subheadline, design: .rounded)).fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .foregroundColor(gender == value ? .white : KTheme.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                    .fill(gender == value ? AnyShapeStyle(KTheme.accentGradient) : AnyShapeStyle(KTheme.backgroundCard))
            )
            .overlay(RoundedRectangle(cornerRadius: KTheme.cardCornerRadius)
                .stroke(gender == value ? Color.clear : KTheme.border, lineWidth: 1))
        }
        .animation(.spring(response: 0.3), value: gender)
    }

    private func modeTab(label: String, icon: String, mode: CalorieMode) -> some View {
        let isSelected = calorieMode == mode
        return Button(action: { withAnimation(.spring(response: 0.3)) { calorieMode = mode } }) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 13))
                Text(label).font(.system(.subheadline, design: .rounded)).fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundColor(isSelected ? .white : KTheme.textSecondary)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? AnyShapeStyle(KTheme.accentGradient) : AnyShapeStyle(Color.clear))
            )
        }
    }

    private func stepperBtn(_ label: String, amount: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3)) {
                customCalorieTarget = max(800, min(5000, customCalorieTarget + amount))
            }
        }) {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.bold)
                .foregroundColor(KTheme.accentOrange)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(KTheme.accentOrange.opacity(0.12))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(KTheme.accentOrange.opacity(0.3), lineWidth: 1))
                )
        }
    }

    // MARK: - Save

    private func save() {
        user.age = age
        user.gender = gender
        user.heightCm = heightCm
        user.weightKg = weightKg
        user.activityLevel = activityLevel
        user.goal = goal
        user.usesCustomCalorieTarget = (calorieMode == .custom)
        user.updatedAt = .now

        if calorieMode == .custom {
            user.dailyCalorieTarget = customCalorieTarget
        } else {
            user.dailyCalorieTarget = CalculatorService.calculateDailyTarget(
                age: age,
                gender: gender,
                heightCm: heightCm,
                weightKg: weightKg,
                activityLevel: activityLevel,
                goal: goal
            )
        }

        dismiss()
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: User.self, Meal.self, configurations: config)
    let sample = User(age: 28, gender: .female, heightCm: 165, weightKg: 62,
                      activityLevel: .moderatelyActive, goal: .maintain, dailyCalorieTarget: 1900)
    container.mainContext.insert(sample)
    return EditProfileView(user: sample)
        .modelContainer(container)
        .preferredColorScheme(.dark)
}
