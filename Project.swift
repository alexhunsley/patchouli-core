import ProjectDescription

let project = Project(
    name: "PatchouliCore",
    targets: [
        .target(
            name: "PatchouliCore",
            destinations: .macOS,
            product: .staticLibrary,
            bundleId: "io.tuist.PatchouliCore",
//            infoPlist: .extendingDefault(
//                with: [
//                    "UILaunchStoryboardName": "LaunchScreen.storyboard",
//                ]
//            ),
            sources: ["Sources/**"],
//            resources: ["PatchouliCore/Resources/**"],
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
