import SwiftUI

struct ContentView: View {
    @State private var vm = SynsViewModel()
    @AppStorage("prefersDarkMode") private var prefersDark: Bool = true
    @State private var introExpanded = false
    @Environment(\.colorScheme) private var cs

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView {
                    VStack(spacing: 16) {
                        heroHeader
                        introSection
                        settingsSection
                        MonovisionToggleView()
                        ResultsTableView(
                            leftResults: vm.leftResults,
                            rightResults: vm.rightResults
                        )
                        DefocusChartsView()
                    }
                    .padding()
                }
            }
            .navigationTitle("OptiSim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.cardBg, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        prefersDark.toggle()
                    } label: {
                        Image(systemName: prefersDark ? "sun.max.fill" : "moon.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(AppTheme.accent)
                    }
                    .accessibilityLabel(prefersDark ? "Bytt til lyst modus" : "Bytt til mørkt modus")
                }
            }
        }
        .preferredColorScheme(prefersDark ? .dark : .light)
        .environment(vm)
    }

    // MARK: - Hero header

    private var heroHeader: some View {
        HStack(spacing: 16) {
            // Left: icon with glow ring
            ZStack {
                Circle()
                    .fill(AppTheme.accent.opacity(cs == .dark ? 0.15 : 0.10))
                    .frame(width: 58, height: 58)
                Circle()
                    .strokeBorder(AppTheme.accent.opacity(cs == .dark ? 0.35 : 0.20), lineWidth: 1.5)
                    .frame(width: 58, height: 58)
                Text("👁️")
                    .font(.system(size: 30))
            }

            // Right: title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Refraktiv kirurgi-kalkulator")
                    .font(.system(.title2, design: .rounded, weight: .black))
                    .accentGradient()

                Text("LASIK · PRK · SMILE · Monovision")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .tracking(1.0)
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(AppTheme.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(AppTheme.accent.opacity(cs == .dark ? 0.35 : 0.22), lineWidth: 1)
        )
    }

    // MARK: - Intro section

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    introExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Hva er dette?", systemImage: "info.circle.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(AppTheme.accent)
                    Spacer()
                    Image(systemName: introExpanded ? "info.circle.fill" : "info.circle")
                        .font(.system(size: 18))
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .buttonStyle(.plain)

            if introExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Divider().padding(.top, 8)

                    Text("Denne kalkulatoren simulerer hvordan øynene dine ser på ulike avstander etter refraktiv kirurgi (LASIK, PRK, SMILE). Juster brillestyrken (R0), linseverdien (korreksjon via kirurgi/linser) og akkommodasjon (øyets evne til å fokusere på nært hold) — resultatet viser rest-defokus på nær, middels og fjern avstand.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(AppTheme.accent)
                        Text("Monovision/Presbyond: ett øye korrigeres for avstand (dominant øye) og det andre for nærarbeid — nyttig for personer over 40–45 år som gradvis mister akkommodasjon (presbyopi).")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .modernCard(tint: AppTheme.accent)
    }

    // MARK: - Settings section

    private var settingsSection: some View {
        @Bindable var vm = vm

        return VStack(alignment: .leading, spacing: 16) {
            Label("Innstillinger", systemImage: "slider.horizontal.3")
                .font(.headline)
                .foregroundStyle(AppTheme.accent)

            // Eye cards — right eye first
            EyeCardView(
                title: "Høyre øye",
                icon: "eye.fill",
                tintColor: AppTheme.rightEye,
                r0: $vm.rightR0,
                lens: $vm.rightLens,
                isLensDisabled: vm.isRightNearEye,
                effectiveLens: vm.rightEye.lensCorrection
            )

            EyeCardView(
                title: "Venstre øye",
                icon: "eye.fill",
                tintColor: AppTheme.leftEye,
                r0: $vm.leftR0,
                lens: $vm.leftLens,
                isLensDisabled: vm.isLeftNearEye,
                effectiveLens: vm.leftEye.lensCorrection
            )

            // Accommodation slider (shared)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Label("Akkommodasjon (A)", systemImage: "eye.circle")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Text(vm.accommodation.diopterString)
                        .font(.subheadline.monospacedDigit())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 3)
                        .background(AppTheme.signColor(for: vm.accommodation).opacity(0.15), in: Capsule())
                        .foregroundStyle(AppTheme.signColor(for: vm.accommodation))
                }

                Slider(value: $vm.accommodation, in: 0...12, step: 0.25)
                    .tint(AppTheme.accent)

                HStack(spacing: 6) {
                    Image(systemName: "person.fill")
                        .font(.caption2)
                    Text("Gjennomsnittsalder: ~\(estimatedAge) år  (Hofstetters formel)")
                        .font(.caption.weight(.medium))
                }
                .foregroundStyle(AppTheme.accent)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 8))

                Text("Øyets evne til å fokusere på nært hold reduseres med alderen.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .modernCard()
        }
    }

    /// Estimated average age — Hofstetter: age = (18.5 − A) / 0.3
    private var estimatedAge: Int {
        let age = (18.5 - vm.accommodation) / 0.3
        return max(10, min(70, Int(age.rounded())))
    }
}

#Preview {
    ContentView()
}
