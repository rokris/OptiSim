import SwiftUI

struct MonovisionToggleView: View {
    @Environment(SynsViewModel.self) private var vm
    @Environment(\.colorScheme) private var cs

    var body: some View {
        @Bindable var vm = vm

        VStack(alignment: .leading, spacing: 14) {
            // Header
            Label("Monovision / Presbyond", systemImage: "eye.trianglebadge.exclamationmark")
                .font(.headline.weight(.bold))
                .foregroundStyle(AppTheme.accent)

            // Toggle row
            HStack {
                Text("Aktiver Monovision / Presbyond")
                    .font(.subheadline.weight(.medium))
                Spacer()
                Toggle("", isOn: $vm.isMonovision)
                    .tint(AppTheme.accent)
                    .labelsHidden()
            }

            if vm.isMonovision {
                Divider().overlay(AppTheme.accent.opacity(0.2))

                HStack(spacing: 16) {
                    // Dominant eye picker
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Dominant øye")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)
                        Picker("Dominant øye", selection: $vm.dominantEye) {
                            ForEach(DominantEye.allCases) { eye in
                                Text(eye.displayName).tag(eye)
                            }
                        }
                        .pickerStyle(.segmented)
                    }

                    // Near target stepper
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Mål nærøye")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                            .tracking(0.5)

                        Stepper(
                            value: $vm.nearTarget,
                            in: -4...0,
                            step: 0.25
                        ) {
                            Text(vm.nearTarget.diopterString)
                                .font(.subheadline.monospacedDigit().weight(.semibold))
                                .fixedSize()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(AppTheme.signColor(for: vm.nearTarget).opacity(0.15), in: Capsule())
                                .foregroundStyle(AppTheme.signColor(for: vm.nearTarget))
                        }
                    }
                }

                // Info badge
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                    Text("Dominant øye (\(vm.dominantLabel)) justeres fritt. Nærøye (\(vm.nearEyeLabel)) beregnes automatisk til \(vm.nearTarget.diopterString).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(AppTheme.accent.opacity(0.20), lineWidth: 1)
                )

                // Eye summary — two rows, one per eye
                VStack(spacing: 5) {
                    eyeRow(color: AppTheme.leftEye,
                           label: "Venstre",
                           value: vm.leftEye.residual,
                           role: vm.isLeftNearEye ? "nærøye" : "dominant")
                    eyeRow(color: AppTheme.rightEye,
                           label: "Høyre",
                           value: vm.rightEye.residual,
                           role: vm.isRightNearEye ? "nærøye" : "dominant")
                }
                .font(.caption.monospacedDigit())
                .padding(.horizontal, 14)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.fill.tertiary, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .modernCard(tint: AppTheme.accent)
    }

    // MARK: - Eye summary row

    private func eyeRow(color: Color, label: String, value: Double, role: String) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label + ":")
                .foregroundStyle(color)
                .fontWeight(.semibold)
            Text(value.diopterString)
                .foregroundStyle(AppTheme.signColor(for: value))
                .fontWeight(.bold)
            Text("· " + role)
                .foregroundStyle(.secondary)
        }
    }
}

