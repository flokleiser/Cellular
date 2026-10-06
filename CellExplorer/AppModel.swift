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

    static let minimumCellScale: Float = 0.5
    static let maximumCellScale: Float = 2.0

    var infoTitle = ""
    var infoBody = ""
    var hint = ""

    var nextOrganelle: Organelle? {
        placedCount < organelles.count ? organelles[placedCount] : nil
    }
}
