// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "PatchouliCore",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "PatchouliCore",
            targets: ["PatchouliCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/raymccrae/swift-jsonpatch", .upToNextMajor(from: "1.0.6"))
    ],
    targets: [
        .target(
            name: "PatchouliCore",
            // we need this vvv  see https://stackoverflow.com/a/71494695/348476
            dependencies: [.product(name: "JSONPatch", package: "swift-jsonpatch")]
        ),
        .testTarget(
            name: "PatchouliCoreTests",
            dependencies: ["PatchouliCore"]),
    ]
)
