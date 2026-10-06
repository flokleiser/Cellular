import SwiftUI

@main
struct CellExplorerApp: App {
    @State private var model = AppModel()

    init() {
        OrganelleComponent.registerComponent()
    }

    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environment(model)
        }

        ImmersiveSpace(id: model.immersiveSpaceID) {
            ImmersiveView()
                .environment(model)
                .onAppear { model.immersiveSpaceState = .open }
                .onDisappear { model.immersiveSpaceState = .closed }
        }
        .immersionStyle(selection: .constant(.mixed), in: .mixed)
    }
}
