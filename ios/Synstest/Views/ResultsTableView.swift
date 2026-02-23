import SwiftUI

struct ResultsTableView: View {
    let leftResults: [DistanceResult]
    let rightResults: [DistanceResult]

    @Environment(\.colorScheme) private var cs

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Resultater", systemImage: "tablecells.fill")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)

            // Table header
            HStack(spacing: 0) {
                headerCell("Øye")
                headerCell("Residual")
                headerCell("Avstand")
                headerCell("Krav")
                headerCell("Rest-def")
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(
                cs == .dark
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [AppTheme.accent.opacity(0.20), AppTheme.accent.opacity(0.08)],
                            startPoint: .leading, endPoint: .trailing
                        )
                    )
                    : AnyShapeStyle(AppTheme.accent.opacity(0.10))
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))

            // Right eye rows
            VStack(spacing: 0) {
                ForEach(Array(rightResults.enumerated()), id: \.offset) { index, result in
                    resultRow(eye: "Høyre", showResidual: index == 0, result: result, rowIndex: index)
                }
            }

            // Divider between eyes
            HStack(spacing: 6) {
                Rectangle().fill(AppTheme.leftEye.opacity(0.4)).frame(height: 1)
            }

            // Left eye rows
            VStack(spacing: 0) {
                ForEach(Array(leftResults.enumerated()), id: \.offset) { index, result in
                    resultRow(eye: "Venstre", showResidual: index == 0, result: result, rowIndex: index)
                }
            }
        }
        .padding(16)
        .modernCard(tint: AppTheme.accent)
    }

    // MARK: - Subviews

    private func headerCell(_ text: String) -> some View {
        Text(text)
            .font(.caption2.weight(.semibold))
            .textCase(.uppercase)
            .foregroundStyle(AppTheme.accent)
            .tracking(0.4)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func resultRow(eye: String, showResidual: Bool, result: DistanceResult, rowIndex: Int) -> some View {
        let eyeColor: Color = eye == "Høyre" ? AppTheme.rightEye : AppTheme.leftEye
        let defColor: Color = AppTheme.signColor(for: result.restDefocus)

        return HStack(spacing: 0) {
            Text(eye)
                .font(.caption.weight(.semibold))
                .foregroundStyle(eyeColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(showResidual ? result.residual.diopterString : "")
                .font(.caption.monospacedDigit())
                .foregroundStyle(showResidual ? AppTheme.signColor(for: result.residual) : .clear)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.distance.name)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.demand.diopterString)
                .font(.caption.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text(result.restDefocus.diopterString)
                .font(.callout.weight(.bold).monospacedDigit())
                .foregroundStyle(defColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            rowIndex % 2 == 0
                ? eyeColor.opacity(cs == .dark ? 0.04 : 0.03)
                : Color.clear
        )
        .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

