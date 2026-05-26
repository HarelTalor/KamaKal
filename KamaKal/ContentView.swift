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
            ZStack(alignment: .bottom) {
                // Tab Content
                Group {
                    if selectedTab == 0 {
                        MainDashboardView()
                    } else {
                        HistoryView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Custom Tab Bar
                customTabBar
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
            // Today Tab
            tabButton(icon: "flame.fill", label: "Today", index: 0)

            Spacer()

            // Center FAB
            Button(action: { showMealCapture = true }) {
                ZStack {
                    Circle()
                        .fill(KTheme.accentGradient)
                        .frame(width: 60, height: 60)
                        .shadow(color: KTheme.accentOrange.opacity(0.4), radius: 12, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -20)

            Spacer()

            // History Tab
            tabButton(icon: "clock.fill", label: "History", index: 1)
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
        .padding(.bottom, 8)
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
                .shadow(color: .black.opacity(0.3), radius: 16, y: -4)
        )
    }

    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .scaleEffect(selectedTab == index ? 1.15 : 1.0)

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
            }
            .foregroundColor(selectedTab == index ? KTheme.accentOrange : KTheme.textSecondary)
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, Meal.self], inMemory: true)
}
