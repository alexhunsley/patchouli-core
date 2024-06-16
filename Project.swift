import ProjectDescription

let project = Project(
    name: "PatchouliCore",
    targets: [
        .target(
            name: "PatchouliCore",
            destinations: .macOS,
            product: .staticLibrary,
            bundleId: "io.tuist.PatchouliCore",
            sources: ["Sources/**"],
            dependencies: []
        ),
        .target(
            name: "PatchouliCoreTests",
            destinations: .macOS,
            product: .unitTests,
            bundleId: "io.tuist.PatchouliCoreTests",
            infoPlist: .default,
            sources: ["Tests/**"],
            resources: [],
            dependencies: [.target(name: "PatchouliCore")]
        ),
    ]
)
