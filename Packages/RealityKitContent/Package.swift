// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "RealityKitContent",
    platforms: [
        .visionOS(.v1),
        .macOS(.v15),
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "RealityKitContent",
            targets: ["RealityKitContent"]
        )
    ],
    targets: [
        .target(
            name: "RealityKitContent",
            dependencies: []
        )
    ]
)
