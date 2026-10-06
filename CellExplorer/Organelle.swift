import RealityKit
import UIKit

struct OrganelleComponent: Component {
    var id: String
}

struct Organelle: Identifiable {
    let id: String
    let name: String
    let explanation: String
    let color: UIColor
    let size: Float
    let homePosition: SIMD3<Float>
    let modelName: String?
}

extension Organelle {
    static let proteinPathway: [Organelle] = [
        Organelle(
            id: "nucleus",
            name: "Nucleus",
            explanation: "The nucleus stores the DNA. The gene for a protein is copied into messenger RNA (mRNA), which leaves through nuclear pores and travels into the cytoplasm.",
            color: .systemPurple,
            size: 0.07,
            homePosition: [0, 0.02, 0],
            modelName: "Nucleus"
        ),
        // this is missing
        Organelle(
            id: "ribosome",
            name: "Ribosome",
            explanation: "Ribosomes read the mRNA and link amino acids into a protein chain. Proteins meant for export or for the membrane are built on ribosomes attached to the rough ER.",
            color: .systemGreen,
            size: 0.02,
            homePosition: [0.11, 0.04, 0.08],
            modelName: nil
        ),
        Organelle(
            id: "rough-er",
            name: "Rough ER",
            explanation: "The new protein enters the rough endoplasmic reticulum, where it is folded, checked for errors and given first modifications. It then leaves in a transport vesicle toward the Golgi.",
            color: .systemOrange,
            size: 0.05,
            homePosition: [-0.1, 0, 0.08],
            modelName: nil
        ),
        Organelle(
            id: "golgi",
            name: "Golgi Apparatus",
            explanation: "The Golgi receives proteins from the ER, finishes modifying them, and sorts and packages them according to their destination.",
            color: .systemYellow,
            size: 0.05,
            homePosition: [-0.05, -0.08, -0.08],
            modelName: nil
        ),
        
        //this is missing
        Organelle(
            id: "vesicle",
            name: "Secretory Vesicle",
            explanation: "Vesicles bud off the Golgi carrying the finished proteins to the cell membrane, where they fuse and release their cargo outside the cell or deliver it to the membrane.",
            color: .systemPink,
            size: 0.03,
            homePosition: [0.1, -0.04, -0.1],
            modelName: nil
        ),
        Organelle(
            id: "mitochondrion",
            name: "Mitochondrion",
            explanation: "Mitochondria produce the ATP that powers every step of this pathway, from transcription and translation to folding and vesicle transport.",
            color: .systemRed,
            size: 0.04,
            homePosition: [-0.1, 0.05, -0.1],
            modelName: nil
        )
    ]
}
