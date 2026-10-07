import SwiftUI

struct InfoPanel: View {
    let model: AppModel
    let onRestart: () -> Void
    let onResize: (Float) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(model.infoTitle)
                .font(.title)
            Text(model.infoBody)
                .font(.body)
            if !model.hint.isEmpty {
                Text(model.hint)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                Button {
                    onResize(-model.cellResizeStep)
                } label: {
                    Image(systemName: "minus")
                }
                .accessibilityLabel("Decrease cell size")
                .disabled(model.cellScale <= AppModel.minimumCellScale)

                Text("Cell diameter \(Int((model.cellDiameter * 100).rounded())) cm")
                    .font(.subheadline)
                    .monospacedDigit()

                Button {
                    onResize(model.cellResizeStep)
                } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Increase cell size")
                .disabled(model.cellScale >= model.maximumAllowedCellScale)
            }
            .buttonStyle(.bordered)
            if model.phase != .intact {
                Button("Restart", action: onRestart)
            }
        }
        .padding(24)
        .frame(width: 420, alignment: .leading)
        .glassBackgroundEffect()
    }
}
