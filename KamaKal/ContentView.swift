import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var users: [User]
    @State private var selectedTab: Int = 0
    @State private var showMealCapture = false

    var body: some View {
        if users.isEmpty {
            OnboardingView()
                .preferredColorScheme(.dark)
        } else {
            ZStack(alignment: .bottomTrailing) {
                // Tab Content
                Group {
                    switch selectedTab {
                    case 0:
                        MainDashboardView()
                    case 1:
                        HistoryView()
                    default:
                        ProfileView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                customTabBar

                // Floating Action Button
                floatingFAB
            }
            .ignoresSafeArea(.keyboard)
            .preferredColorScheme(.dark)
            .sheet(isPresented: $showMealCapture) {
                MealCaptureView()
                    .preferredColorScheme(.dark)
            }
        }
    }

    // MARK: - Custom Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "flame.fill", label: "Today", index: 0)
            tabButton(icon: "clock.fill", label: "History", index: 1)
            tabButton(icon: "person.fill", label: "Profile", index: 2)
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(KTheme.backgroundCard.opacity(0.85))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(KTheme.border, lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.35), radius: 16, y: -4)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 12)
    }

    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .scaleEffect(selectedTab == index ? 1.15 : 1.0)
                    .foregroundColor(selectedTab == index ? KTheme.accentOrange : KTheme.textSecondary)

                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(selectedTab == index ? KTheme.textPrimary : KTheme.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Floating Action Button

    private var floatingFAB: some View {
        Button(action: { showMealCapture = true }) {
            ZStack {
                Circle()
                    .fill(KTheme.accentGradient)
                    .frame(width: 56, height: 56)
                    .shadow(color: KTheme.accentOrange.opacity(0.4), radius: 12, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        .padding(.trailing, 24)
        .padding(.bottom, 106) // Elevated to perfectly float above the custom tab bar
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Meal.self, DailySummary.self], inMemory: true)
        .preferredColorScheme(.dark)
}
