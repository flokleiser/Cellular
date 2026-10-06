import SwiftUI

struct LaunchView: View {
    @Environment(AppModel.self) private var model
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace

    var body: some View {
        VStack(spacing: 24) {
            Text("Cell Explorer")
                .font(.extraLargeTitle)
            Text("Explore how a cell makes and ships proteins.")
            Button(model.immersiveSpaceState == .open ? "Leave" : "Enter") {
                Task { await toggleImmersiveSpace() }
            }
            .disabled(model.immersiveSpaceState == .inTransition)
        }
        .padding(40)
    }

    private func toggleImmersiveSpace() async {
        switch model.immersiveSpaceState {
        case .open:
            model.immersiveSpaceState = .inTransition
            await dismissImmersiveSpace()
        case .closed:
            model.immersiveSpaceState = .inTransition
            switch await openImmersiveSpace(id: model.immersiveSpaceID) {
            case .opened:
                break
            default:
                model.immersiveSpaceState = .closed
            }
        case .inTransition:
            break
        }
    }
}
