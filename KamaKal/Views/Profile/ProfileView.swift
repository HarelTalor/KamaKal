import SwiftUI
import SwiftData

struct ProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var users: [User]
    @State private var isEditing = false
    @State private var showResetConfirm = false

    private var user: User? { users.first }

    var body: some View {
        NavigationStack {
            ZStack {
                KTheme.backgroundPrimary.ignoresSafeArea()

                if let user {
                    ScrollView {
                        VStack(spacing: 20) {
                            avatarHeader(user: user)
                                .padding(.top, 24)
                            statsGrid(user: user)
                            goalsCard(user: user)
                            resetButton
                        }
                        .padding(.horizontal, KTheme.screenPadding)
                        .padding(.bottom, 100)
                    }
                } else {
                    Text("No profile found")
                        .foregroundColor(KTheme.textSecondary)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $isEditing) {
                if let user {
                    EditProfileView(user: user)
                        .preferredColorScheme(.dark)
                }
            }
            .confirmationDialog(
                "Reset your profile?",
                isPresented: $showResetConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete Profile & All Data", role: .destructive) { resetAll() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will delete all your meals and profile data. This cannot be undone.")
            }
        }
    }

    // MARK: - Avatar / Header

    private func avatarHeader(user: User) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(KTheme.accentGradient)
                    .frame(width: 90, height: 90)
                    .shadow(color: KTheme.accentOrange.opacity(0.35), radius: 16)

                Image(systemName: "person.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }

            VStack(spacing: 4) {
                Text(user.gender.displayName)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(KTheme.textPrimary)

                Text(user.goal.displayName + " · " + user.activityLevel.displayName)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Button(action: { isEditing = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                }
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(KTheme.accentOrange)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule()
                        .fill(KTheme.accentOrange.opacity(0.12))
                        .overlay(Capsule().stroke(KTheme.accentOrange.opacity(0.3), lineWidth: 1))
                )
            }
        }
    }

    // MARK: - Stats Grid

    private func statsGrid(user: User) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            statCard(label: "Age", value: "\(user.age)", unit: "years", icon: "person.fill")
            statCard(label: "Height", value: "\(Int(user.heightCm))", unit: "cm", icon: "ruler")
            statCard(label: "Weight", value: String(format: "%.1f", user.weightKg), unit: "kg", icon: "scalemass.fill")
            statCard(label: "Daily Target", value: "\(user.dailyCalorieTarget)", unit: "kcal", icon: "target")
        }
    }

    private func statCard(label: String, value: String, unit: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(KTheme.accentGradient)
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
            }

            HStack(alignment: .lastTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(KTheme.textPrimary)
                Text(unit)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(KTheme.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(KTheme.cardPadding)
        .glassCard()
    }

    // MARK: - Goals Card

    private func goalsCard(user: User) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("Goal & Activity", systemImage: "figure.run")
                .font(.system(.subheadline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(KTheme.textSecondary)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Goal")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)
                    Text(user.goal.displayName)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(KTheme.textPrimary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Activity")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(KTheme.textSecondary)
                    Text(user.activityLevel.displayName)
                        .font(.system(.body, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(KTheme.textPrimary)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: user.usesCustomCalorieTarget ? "slider.horizontal.3" : "wand.and.stars")
                    .font(.system(size: 12))
                Text(user.usesCustomCalorieTarget ? "Custom calorie target" : "Formula-calculated target")
                    .font(.system(.caption, design: .rounded))
            }
            .foregroundColor(KTheme.accentOrange)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Capsule().fill(KTheme.accentOrange.opacity(0.12)))
        }
        .padding(KTheme.cardPadding)
        .glassCard()
    }

    // MARK: - Reset Button

    private var resetButton: some View {
        Button(action: { showResetConfirm = true }) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                Text("Reset Profile & Log Out")
            }
            .font(.system(.body, design: .rounded))
            .fontWeight(.semibold)
            .foregroundColor(KTheme.danger)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius)
                    .fill(KTheme.danger.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius)
                            .stroke(KTheme.danger.opacity(0.25), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Actions

    private func resetAll() {
        let allMeals = (try? modelContext.fetch(FetchDescriptor<Meal>())) ?? []
        for meal in allMeals { modelContext.delete(meal) }

        let allSummaries = (try? modelContext.fetch(FetchDescriptor<DailySummary>())) ?? []
        for summary in allSummaries { modelContext.delete(summary) }

        let allUsers = (try? modelContext.fetch(FetchDescriptor<User>())) ?? []
        for user in allUsers { modelContext.delete(user) }
    }
}

#Preview {
    ProfileView()
        .modelContainer(for: [User.self, Meal.self, DailySummary.self], inMemory: true)
        .preferredColorScheme(.dark)
}
