import RealityKit
import RealityKitContent
import UIKit
import simd

@MainActor
final class CellScene {
    static let cellRadius: Float = 0.25
    static let scatterRadius: Float = 0.6
    static let cellModelName = "Cell"

    let root = Entity()
    private let model: AppModel
    private let cellContents = Entity()
    private var membrane = Entity()
    private var infoPanel: Entity?
    private var organelleEntities: [String: Entity] = [:]

    init(model: AppModel) {
        self.model = model
    }

    func build() async {
        root.name = "CellRoot"
        cellContents.name = "CellContents"
        cellContents.scale = SIMD3(repeating: model.cellScale)
        root.addChild(cellContents)

        membrane = await makeMembrane()
        cellContents.addChild(membrane)

        for organelle in model.organelles {
            let entity = await makeOrganelle(organelle)
            organelleEntities[organelle.id] = entity
            cellContents.addChild(entity)
        }

        reset()
    }

    func resizeCell(by amount: Float) {
        model.cellScale = min(
            max(model.cellScale + amount, AppModel.minimumCellScale),
            model.maximumAllowedCellScale
        )
        cellContents.scale = SIMD3(repeating: model.cellScale)
    }

    func attachInfoPanel(_ panel: Entity) {
        infoPanel = panel
        root.addChild(panel)
        positionInfoPanelBesideCell()
    }

    func reset() {
        model.phase = .intact
        model.placedCount = 0
        model.cellScale = 1.0
        cellContents.scale = SIMD3(repeating: model.cellScale)
        model.infoTitle = "Cell Explorer"
        model.infoBody = "Look at the cell and tap it to open it up."
        model.hint = ""
        positionInfoPanelBesideCell()

        membrane.components.set(InputTargetComponent())

        for organelle in model.organelles {
            guard let entity = organelleEntities[organelle.id] else { continue }
            entity.position = organelle.homePosition
            entity.components.remove(InputTargetComponent.self)
            entity.components.remove(HoverEffectComponent.self)
        }
    }

    func explode() {
        guard model.phase == .intact else { return }
        model.phase = .exploded
        membrane.components.remove(InputTargetComponent.self)

        for (index, organelle) in model.organelles.enumerated() {
            guard let entity = organelleEntities[organelle.id] else { continue }
            entity.move(
                to: Transform(translation: scatterPosition(index)),
                relativeTo: root,
                duration: 1.2,
                timingFunction: .easeInOut
            )
        }

        model.infoTitle = "The cell is open"
        model.infoBody = "These organelles work together to make and ship proteins. Drag them back into the cell in the order the protein passes through them."
        positionInfoPanelBesideCell()
        activateNext()
    }

    func drop(_ entity: Entity) {
        guard model.phase == .exploded,
              let component = entity.components[OrganelleComponent.self],
              let organelle = model.nextOrganelle,
              organelle.id == component.id,
              length(entity.position) < Self.cellRadius else { return }

        entity.components.remove(InputTargetComponent.self)
        entity.components.remove(HoverEffectComponent.self)
        entity.move(
            to: Transform(translation: organelle.homePosition),
            relativeTo: cellContents,
            duration: 0.5,
            timingFunction: .easeOut
        )

        model.placedCount += 1
        model.infoTitle = organelle.name
        model.infoBody = organelle.explanation
        positionInfoPanel(nextTo: organelle.homePosition * model.cellScale)

        if model.nextOrganelle == nil {
            model.phase = .completed
            model.hint = "Pathway complete. The cell can now make and ship proteins."
        } else {
            activateNext()
        }
    }

    func organelleEntity(containing entity: Entity) -> Entity? {
        var current: Entity? = entity
        while let candidate = current {
            if candidate.components[OrganelleComponent.self] != nil {
                return candidate
            }
            current = candidate.parent
        }
        return nil
    }

    func showInfo(for entity: Entity) {
        guard let component = entity.components[OrganelleComponent.self],
              let organelle = model.organelles.first(where: { $0.id == component.id }) else { return }
        model.infoTitle = organelle.name
        model.infoBody = organelle.explanation
        positionInfoPanel(nextTo: entity)
    }

    private func activateNext() {
        guard let next = model.nextOrganelle,
              let entity = organelleEntities[next.id] else { return }
        entity.components.set([InputTargetComponent(), HoverEffectComponent()])
        model.hint = "Next: drag the \(next.name) into the cell."
    }

    private func positionInfoPanelBesideCell() {
        infoPanel?.position = [0.7, 0, 0]
    }

    private func positionInfoPanel(nextTo entity: Entity) {
        let position = entity.position(relativeTo: root)
        positionInfoPanel(nextTo: position)
    }

    private func positionInfoPanel(nextTo position: SIMD3<Float>) {
        let horizontalOffset: Float = position.x >= 0 ? -0.55 : 0.55
        infoPanel?.position = [position.x + horizontalOffset, position.y, position.z]
    }

    private func scatterPosition(_ index: Int) -> SIMD3<Float> {
        let angle = Float(index) / Float(model.organelles.count) * 2 * .pi
        return [
            cos(angle) * Self.scatterRadius,
            sin(angle) * Self.scatterRadius,
            0
        ]
    }

    private func makeMembrane() async -> Entity {
        let fallback = ModelEntity(
            mesh: .generateSphere(radius: Self.cellRadius),
            materials: [translucentMaterial(.systemTeal, opacity: 0.25)]
        )
        let visual = await loadVisual(
            named: Self.cellModelName,
            diameter: Self.cellRadius * 2,
            fallback: fallback
        )

        let entity = Entity()
        entity.name = "Membrane"
        entity.addChild(visual)
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: Self.cellRadius)]))
        entity.components.set(InputTargetComponent())
        return entity
    }

    private func makeOrganelle(_ organelle: Organelle) async -> Entity {
        let fallback = ModelEntity(
            mesh: .generateSphere(radius: organelle.size),
            materials: [SimpleMaterial(color: organelle.color, isMetallic: false)]
        )
        let visual = await loadVisual(
            named: organelle.modelName,
            diameter: organelle.size * 2,
            fallback: fallback
        )

        let entity = Entity()
        entity.name = organelle.name
        entity.addChild(visual)
        entity.components.set(OrganelleComponent(id: organelle.id))
        entity.components.set(CollisionComponent(shapes: [.generateSphere(radius: max(organelle.size * 1.3, 0.03))]))
        return entity
    }

    private func loadVisual(named name: String?, diameter: Float, fallback: Entity) async -> Entity {
        guard let name, let loaded = await loadEntity(named: name) else { return fallback }
        fit(loaded, toDiameter: diameter)
        return loaded
    }

    private func loadEntity(named name: String) async -> Entity? {
        if let entity = try? await Entity(named: name, in: realityKitContentBundle) {
            return entity
        }
        return try? await Entity(named: name)
    }

    private func fit(_ entity: Entity, toDiameter diameter: Float) {
        let bounds = entity.visualBounds(relativeTo: nil)
        let longest = max(bounds.extents.x, bounds.extents.y, bounds.extents.z)
        guard longest > 0 else { return }
        let factor = diameter / longest
        entity.scale *= factor
        entity.position = -bounds.center * factor
    }

    private func translucentMaterial(_ color: UIColor, opacity: Float) -> PhysicallyBasedMaterial {
        var material = PhysicallyBasedMaterial()
        material.baseColor = .init(tint: color)
        material.blending = .transparent(opacity: .init(floatLiteral: opacity))
        return material
    }
}
