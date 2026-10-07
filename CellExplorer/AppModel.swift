import SwiftUI

enum CellPhase {
    case intact
    case exploded
    case completed
}

@MainActor
@Observable
final class AppModel {
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }

    let immersiveSpaceID = "CellSpace"
    var immersiveSpaceState = ImmersiveSpaceState.closed

    let organelles = Organelle.proteinPathway
    var phase = CellPhase.intact
    var placedCount = 0
    var cellScale: Float = 1.0

    static let baseCellDiameter: Float = 0.5
    static let minimumCellScale: Float = 0.5
    static let maximumCellScale: Float = 2.0
    static let maximumCompletedCellScale: Float = 20.0

    var maximumAllowedCellScale: Float {
        phase == .completed ? Self.maximumCompletedCellScale : Self.maximumCellScale
    }

    var cellResizeStep: Float {
        phase == .completed ? 1.0 : 0.1
    }

    var cellDiameter: Float {
        Self.baseCellDiameter * cellScale
    }

    var infoTitle = ""
    var infoBody = ""
    var hint = ""

    var nextOrganelle: Organelle? {
        placedCount < organelles.count ? organelles[placedCount] : nil
    }
}
