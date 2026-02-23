import SwiftUI

// MARK: - Adaptive colour helper
// Mirrors the web CSS :root (dark) and [data-theme="light"] variables exactly.

private extension Color {
    /// Creates a colour that switches automatically between dark and light mode.
    init(dark: Color, light: Color) {
        self.init(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }
}

// MARK: - Brand colour palette

enum AppTheme {

    // ── Accent ─────────────────────────────────────────────────────────────
    // dark  → --accent:       #00f2fe
    // light → --accent:       #0284c7
    static let accent = Color(
        dark:  Color(red: 0.000, green: 0.949, blue: 0.996),
        light: Color(red: 0.008, green: 0.518, blue: 0.780)
    )

    // ── Right eye ──────────────────────────────────────────────────────────
    // dark  → --color-right:  #00e5ff
    // light → --color-right:  #0284c7
    static let rightEye = Color(
        dark:  Color(red: 0.000, green: 0.898, blue: 1.000),
        light: Color(red: 0.008, green: 0.518, blue: 0.780)
    )

    // ── Left eye ───────────────────────────────────────────────────────────
    // dark  → --color-left:   #ff00ea
    // light → --color-left:   #c026d3
    static let leftEye = Color(
        dark:  Color(red: 1.000, green: 0.000, blue: 0.918),
        light: Color(red: 0.753, green: 0.149, blue: 0.827)
    )

    // ── DOF zone fill (uses accent colour, opacity set at call site) ───────
    static let dof = accent

    // ── Status colours: positive (+) = green, negative (−) = red ───────────
    // dark:  neon green  #00e676  /  neon red   #ff1744
    // light: forest green #16a34a /  crimson    #dc2626
    static let positiveColor = Color(
        dark:  Color(red: 0.000, green: 0.902, blue: 0.463),
        light: Color(red: 0.086, green: 0.639, blue: 0.290)
    )
    static let negativeColor = Color(
        dark:  Color(red: 1.000, green: 0.090, blue: 0.267),
        light: Color(red: 0.863, green: 0.149, blue: 0.149)
    )
    // Convenience aliases
    static var good: Color { positiveColor }
    static var bad:  Color { negativeColor }

    /// Returns green for positive, red for negative, secondary-gray for zero.
    static func signColor(for value: Double) -> Color {
        if value >= 0 { return positiveColor }
        return negativeColor
    }

    // ── Background tokens ──────────────────────────────────────────────────
    // dark  → --bg-main:      #050505
    // light → --bg-main:      #f1f5f9
    static let bgMain = Color(
        dark:  Color(red: 0.020, green: 0.020, blue: 0.020),
        light: Color(red: 0.945, green: 0.961, blue: 0.976)
    )

    // Background gradient accent blobs (used in AppBackground)
    // dark  → --bg-grad-1/2:  cyan 8% / magenta 8%
    static let bgGrad1 = Color(red: 0.000, green: 0.898, blue: 1.000)   // #00e5ff
    static let bgGrad2 = Color(red: 1.000, green: 0.000, blue: 0.918)   // #ff00ea

    // ── Card background ────────────────────────────────────────────────────
    // dark  → --bg-card:      rgba(15, 23, 42, 0.85)   (#0F172A)
    // light → --bg-card:      rgba(255, 255, 255, 0.85)
    static let cardBg = Color(
        dark:  Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.85),
        light: Color(red: 1.000, green: 1.000, blue: 1.000).opacity(0.85)
    )

    // ── Card border ────────────────────────────────────────────────────────
    // dark  → --border-color: rgba(51, 65, 85, 0.5)
    // light → --border-color: rgba(15, 23, 42, 0.10)
    static let borderColor = Color(
        dark:  Color(red: 0.200, green: 0.255, blue: 0.333).opacity(0.5),
        light: Color(red: 0.059, green: 0.090, blue: 0.165).opacity(0.10)
    )
}

// MARK: - App background gradient

struct AppBackground: View {
    @Environment(\.colorScheme) private var cs

    var body: some View {
        ZStack {
            // Base colour — dark: #050505 / light: #f1f5f9
            AppTheme.bgMain.ignoresSafeArea()

            if cs == .dark {
                // Subtle radial blobs matching web --bg-grad-1/2
                GeometryReader { geo in
                    Circle()
                        .fill(AppTheme.bgGrad1.opacity(0.08))
                        .frame(width: geo.size.width * 1.2)
                        .offset(x: -geo.size.width * 0.2, y: -geo.size.height * 0.1)
                        .blur(radius: 80)
                    Circle()
                        .fill(AppTheme.bgGrad2.opacity(0.08))
                        .frame(width: geo.size.width * 1.2)
                        .offset(x: geo.size.width * 0.4, y: geo.size.height * 0.5)
                        .blur(radius: 80)
                }
                .ignoresSafeArea()
            }
        }
    }
}

// MARK: - Modern card modifier

struct ModernCard: ViewModifier {
    @Environment(\.colorScheme) private var cs
    var tint: Color = .clear
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(AppTheme.cardBg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        tint == .clear
                            ? AppTheme.borderColor
                            : tint.opacity(cs == .dark ? 0.40 : 0.28),
                        lineWidth: 1
                    )
            )
    }
}

extension View {
    /// Apply the app's modern card background.
    func modernCard(tint: Color = .clear, cornerRadius: CGFloat = 14) -> some View {
        modifier(ModernCard(tint: tint, cornerRadius: cornerRadius))
    }
}

// MARK: - Accent gradient text helper

extension Text {
    /// Gradient text using the brand accent colour.
    /// dark:  #00f2fe → #4ff8ff   light: #0284c7 → #38bdf8
    func accentGradient() -> some View {
        self.foregroundStyle(
            LinearGradient(
                colors: [
                    AppTheme.accent,
                    Color(UIColor { tc in
                        tc.userInterfaceStyle == .dark
                            ? UIColor(red: 0.31, green: 0.97, blue: 1.00, alpha: 1)
                            : UIColor(red: 0.22, green: 0.74, blue: 0.97, alpha: 1)
                    })
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
}
