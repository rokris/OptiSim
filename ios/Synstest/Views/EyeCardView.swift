import SwiftUI

private struct SliderTickMarks: View {
    var color: Color = AppTheme.accent
    private let ticks: [Int] = [-8, -6, -4, -2, 0, 2, 4, 6, 8]

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                let inset: CGFloat = 11
                let usable = geo.size.width - inset * 2
                let totalSteps = 32
                let bottomY: CGFloat = geo.size.height

                Path { path in
                    path.move(to: CGPoint(x: inset, y: bottomY))
                    path.addLine(to: CGPoint(x: inset + usable, y: bottomY))

                    for i in 0...totalSteps {
                        let value = -8.0 + Double(i) * 0.5
                        let x = inset + usable * CGFloat(i) / CGFloat(totalSteps)
                        let tickHeight: CGFloat
                        if value.truncatingRemainder(dividingBy: 2) == 0 {
                            tickHeight = 10
                        } else if value.truncatingRemainder(dividingBy: 1) == 0 {
                            tickHeight = 6
                        } else {
                            tickHeight = 3
                        }
                        path.move(to: CGPoint(x: x, y: bottomY))
                        path.addLine(to: CGPoint(x: x, y: bottomY - tickHeight))
                    }
                }
                .stroke(color.opacity(0.35), lineWidth: 0.5)
            }
            .frame(height: 11)

            HStack {
                ForEach(ticks, id: \.self) { value in
                    Text(value > 0 ? "+\(value)" : "\(value)")
                        .font(.system(size: 9, weight: value == 0 ? .semibold : .regular).monospacedDigit())
                        .foregroundStyle(value == 0 ? color : .secondary)
                    if value != ticks.last {
                        Spacer()
                    }
                }
            }
        }
        .padding(.horizontal, 7)
    }
}

struct EyeCardView: View {
    let title: String
    let icon: String
    let tintColor: Color

    @Binding var r0: Double
    @Binding var lens: Double
    let isLensDisabled: Bool
    let effectiveLens: Double

    @Environment(SynsViewModel.self) private var vm
    @Environment(\.colorScheme) private var cs

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(tintColor)
                Spacer()
            }

            Divider().overlay(tintColor.opacity(0.2))

            // R0 slider
            sliderRow(
                label: "Brillestyrke (R0)",
                hint: "Øyets naturlige styrke  (+  langsynthet  ·  −  nærsynt)",
                value: $r0,
                displayValue: r0,
                disabled: false
            )

            // Lens slider
            lensRow
        }
        .padding(16)
        // Card background
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                AppTheme.cardBg,
                                tintColor.opacity(cs == .dark ? 0.06 : 0.04)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                )
        )
        // Border
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(tintColor.opacity(cs == .dark ? 0.40 : 0.22), lineWidth: 1)
        )
        // Left colour bar
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: 4)
                .foregroundStyle(
                    LinearGradient(
                        colors: [tintColor, tintColor.opacity(0.4)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
        }
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sliderRow(
        label: String,
        hint: String,
        value: Binding<Double>,
        displayValue: Double,
        disabled: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(displayValue.diopterString)
                    .font(.subheadline.monospacedDigit())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(AppTheme.signColor(for: displayValue).opacity(0.15), in: Capsule())
                    .foregroundStyle(AppTheme.signColor(for: displayValue))
            }
            Slider(value: disabled ? .constant(displayValue) : value, in: -8...8, step: 0.25)
                .tint(disabled ? .secondary : tintColor)
                .disabled(disabled)
            SliderTickMarks(color: disabled ? .secondary : tintColor)
            Text(hint)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var lensRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Linseverdi (Korreksjon)")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Text(effectiveLens.diopterString)
                    .font(.subheadline.monospacedDigit())
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(
                        AppTheme.signColor(for: effectiveLens).opacity(0.15),
                        in: Capsule()
                    )
                    .foregroundStyle(AppTheme.signColor(for: effectiveLens))
            }

            if isLensDisabled {
                Slider(value: .constant(effectiveLens), in: -8...8, step: 0.25)
                    .disabled(true)
                    .tint(.secondary)
                SliderTickMarks(color: .secondary)
                HStack(spacing: 4) {
                    Image(systemName: "lock.fill").font(.caption2)
                    Text("Beregnes automatisk for nærøye ved Monovision")
                }
                .font(.caption)
                .foregroundStyle(.orange)
            } else {
                Slider(value: $lens, in: -8...8, step: 0.25)
                    .tint(tintColor)
                SliderTickMarks(color: tintColor)
                Text("Korreksjon via kirurgi/linser")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

