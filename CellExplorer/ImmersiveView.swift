import SwiftUI
import RealityKit

struct ImmersiveView: View {
    @Environment(AppModel.self) private var model
    @State private var scene: CellScene?
    @State private var dragOffset: SIMD3<Float>?

    var body: some View {
        RealityView { content, attachments in
            let cell = CellScene(model: model)
            await cell.build()
            cell.root.position = [0, 1.3, -1.5]
            content.add(cell.root)

            if let panel = attachments.entity(for: "info") {
                panel.position = [0, -0.55, 0.3]
                cell.root.addChild(panel)
            }

            scene = cell
        } attachments: {
            Attachment(id: "info") {
                InfoPanel(model: model) {
                    scene?.reset()
                } onResize: { amount in
                    scene?.resizeCell(by: amount)
                }
            }
        }
        .gesture(
            SpatialTapGesture()
                .targetedToAnyEntity()
                .onEnded { _ in
                    scene?.explode()
                }
        )
        .gesture(
            DragGesture()
                .targetedToAnyEntity()
                .onChanged { value in
                    guard let entity = scene?.organelleEntity(containing: value.entity),
                          let parent = entity.parent else { return }
                    let location = value.convert(value.location3D, from: .local, to: parent)
                    if dragOffset == nil {
                        dragOffset = entity.position - location
                    }
                    entity.position = location + (dragOffset ?? .zero)
                }
                .onEnded { value in
                    dragOffset = nil
                    guard let entity = scene?.organelleEntity(containing: value.entity) else { return }
                    scene?.drop(entity)
                }
        )
    }
}
