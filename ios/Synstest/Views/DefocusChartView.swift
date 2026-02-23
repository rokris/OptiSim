import SwiftUI
import Charts

// MARK: - Chart data point

struct DefocusDataPoint: Identifiable {
    let id = UUID()
    let distanceName: String
    let distanceIndex: Int  // 0 = Far, 1 = Mid, 2 = Near
    let restDefocus: Double
}

// MARK: - Single eye chart

struct DefocusChartView: View {
    let title: String
    let color: Color
    let results: [DistanceResult]
    let dofRange: Double

    @Environment(\.colorScheme) private var cs

    private var dataPoints: [DefocusDataPoint] {
        let count = results.count
        return results.enumerated().map { index, result in
            DefocusDataPoint(
                distanceName: result.distance.name,
                distanceIndex: count - 1 - index,
                restDefocus: result.restDefocus
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: "eye.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(color)

            Chart {
                // DOF zone
                RectangleMark(
                    xStart: .value("DOF Start", -dofRange),
                    xEnd: .value("DOF End", dofRange),
                    yStart: .value("Y Start", -0.5),
                    yEnd: .value("Y End", Double(ViewingDistance.all.count - 1) + 0.5)
                )
                .foregroundStyle(AppTheme.dof.opacity(0.12))

                // DOF boundary lines
                RuleMark(x: .value("DOF Left", -dofRange))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(AppTheme.dof.opacity(0.45))

                RuleMark(x: .value("DOF Right", dofRange))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(AppTheme.dof.opacity(0.45))

                // Zero line
                RuleMark(x: .value("Zero", 0))
                    .lineStyle(StrokeStyle(lineWidth: 1.5))
                    .foregroundStyle(.secondary.opacity(0.4))

                // Data line + points + labels
                ForEach(dataPoints) { point in
                    LineMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(color)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)

                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(color)
                    .symbolSize(70)

                    // Distance label (leading)
                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .leading, spacing: 6) {
                        Text(point.distanceName)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    // Value label (trailing)
                    PointMark(
                        x: .value("Rest-defokus", point.restDefocus),
                        y: .value("Avstand", point.distanceIndex)
                    )
                    .foregroundStyle(.clear)
                    .annotation(position: .trailing, spacing: 6) {
                        Text(point.restDefocus.diopterString)
                            .font(.caption2.monospacedDigit().weight(.bold))
                            .foregroundStyle(AppTheme.signColor(for: point.restDefocus))
                    }
                }
            }
            .chartXScale(domain: -6...6)
            .chartYScale(domain: -0.5...2.5)
            .chartXAxis {
                AxisMarks(values: stride(from: -6.0, through: 6.0, by: 2.0).map { $0 }) { value in
                    AxisGridLine().foregroundStyle(Color.secondary.opacity(0.15))
                    AxisTick()
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(v > 0 ? "+\(Int(v))" : "\(Int(v))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 200)
            .padding(8)
            .modernCard(tint: color)
        }
    }
}

// MARK: - Combined charts view

struct DefocusChartsView: View {
    @Environment(SynsViewModel.self) private var vm
    @State private var infoExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header row with info toggle
            HStack {
                Label("Visuell fremstilling av rest-defokus", systemImage: "chart.xyaxis.line")
                    .font(.headline)
                    .foregroundStyle(AppTheme.accent)
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        infoExpanded.toggle()
                    }
                } label: {
                    Image(systemName: infoExpanded ? "info.circle.fill" : "info.circle")
                        .foregroundStyle(AppTheme.accent)
                        .font(.title3)
                }
                .accessibilityLabel(infoExpanded ? "Skjul informasjon" : "Vis informasjon")
            }

            // Collapsible info panel
            if infoExpanded {
                infoPanel
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            DefocusChartView(
                title: "Høyre øye",
                color: AppTheme.rightEye,
                results: vm.rightResults,
                dofRange: vm.dofRange
            )

            DefocusChartView(
                title: "Venstre øye",
                color: AppTheme.leftEye,
                results: vm.leftResults,
                dofRange: vm.dofRange
            )
        }
        .padding()
        .modernCard(tint: AppTheme.accent)
    }

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            // DOF row
            HStack(alignment: .top, spacing: 8) {
                Circle()
                    .fill(AppTheme.dof.opacity(0.7))
                    .frame(width: 10, height: 10)
                    .padding(.top, 3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Fremhevet område = DOF (Depth of Field)")
                        .font(.caption.weight(.semibold))
                    Text("Det skraverte området viser fokusområdet hvor synet er akseptabelt skarpt.")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("• Uten Monovision/Presbyond: ±0.50 D")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("• Med Monovision/Presbyond: ±1.25 D")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Divider().opacity(0.3)

            // Three situations
            Text("Tre situasjoner:")
                .font(.caption.weight(.semibold))

            VStack(alignment: .leading, spacing: 4) {
                Label {
                    Text("Myopi (−): Fokus foran netthinnen → uklart på avstand")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.negativeColor)
                } icon: {
                    Text("1️⃣").font(.caption2)
                }
                Label {
                    Text("Hyperopi (+): Fokus bak netthinnen → uklart uten akkommodasjon")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.positiveColor)
                } icon: {
                    Text("2️⃣").font(.caption2)
                }
                Label {
                    Text("Plano (0): Fokus på netthinnen → skarpt på avstand")
                        .font(.caption2)
                        .foregroundStyle(AppTheme.positiveColor)
                } icon: {
                    Text("3️⃣").font(.caption2)
                }
            }

            Divider().opacity(0.3)

            // Axis explanation
            Text("X-aksen viser rest-defokus i dioptrier (D). Verdier nær 0 D betyr skarp visjon. Jo større avstand fra 0, jo mer uskarp blir visningen.")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.accent.opacity(0.05), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(AppTheme.accent.opacity(0.20), lineWidth: 1)
        )
    }
}

