import SwiftUI

/// KamaKal Design System - Warm Sunset Theme
enum KTheme {

    // MARK: - Colors

    /// Deep charcoal background
    static let backgroundPrimary = Color(red: 0.051, green: 0.051, blue: 0.059)  // #0D0D0F

    /// Dark slate card surface
    static let backgroundCard = Color(red: 0.102, green: 0.102, blue: 0.18)      // #1A1A2E

    /// Elevated card surface (slightly lighter)
    static let backgroundElevated = Color(red: 0.133, green: 0.133, blue: 0.22)  // #22223A

    /// Vibrant orange primary accent
    static let accentOrange = Color(red: 1.0, green: 0.42, blue: 0.21)           // #FF6B35

    /// Coral pink secondary accent
    static let accentPink = Color(red: 1.0, green: 0.176, blue: 0.529)           // #FF2D87

    /// Mint green for success / under target
    static let success = Color(red: 0.18, green: 0.8, blue: 0.443)              // #2ECC71

    /// Amber for warnings / close to target
    static let warning = Color(red: 0.953, green: 0.612, blue: 0.071)           // #F39C12

    /// Soft red for danger / over target
    static let danger = Color(red: 0.906, green: 0.298, blue: 0.235)            // #E74C3C

    /// Off-white primary text
    static let textPrimary = Color(red: 0.961, green: 0.961, blue: 0.969)       // #F5F5F7

    /// Silver gray secondary text
    static let textSecondary = Color(red: 0.557, green: 0.557, blue: 0.576)     // #8E8E93

    /// Subtle border / divider
    static let border = Color.white.opacity(0.08)

    // MARK: - Gradients

    /// Primary accent gradient (orange -> pink)
    static let accentGradient = LinearGradient(
        colors: [accentOrange, accentPink],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Progress ring gradient
    static let ringGradient = AngularGradient(
        colors: [accentOrange, accentPink, accentOrange],
        center: .center,
        startAngle: .degrees(0),
        endAngle: .degrees(360)
    )

    /// Card glassmorphic gradient overlay
    static let glassGradient = LinearGradient(
        colors: [Color.white.opacity(0.08), Color.white.opacity(0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Success gradient (green tones)
    static let successGradient = LinearGradient(
        colors: [success, Color(red: 0.0, green: 0.7, blue: 0.5)],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Protein / Carbs / Fat colors

    static let proteinColor = Color(red: 0.39, green: 0.58, blue: 1.0)   // Soft blue
    static let carbsColor = Color(red: 1.0, green: 0.75, blue: 0.28)     // Golden
    static let fatColor = Color(red: 0.96, green: 0.44, blue: 0.63)      // Rose

    // MARK: - Dimensions

    static let cornerRadius: CGFloat = 20
    static let cardCornerRadius: CGFloat = 16
    static let buttonCornerRadius: CGFloat = 14
    static let iconSize: CGFloat = 24
    static let cardPadding: CGFloat = 16
    static let screenPadding: CGFloat = 20
}

// MARK: - Glass Card Modifier

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = KTheme.cardCornerRadius

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(KTheme.backgroundCard)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(KTheme.glassGradient)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(KTheme.border, lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = KTheme.cardCornerRadius) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius))
    }
}

// MARK: - Gradient Button Style

struct GradientButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: KTheme.buttonCornerRadius)
                    .fill(isEnabled ? KTheme.accentGradient : LinearGradient(colors: [.gray.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Modifier

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.12), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(25))
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 400
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}
