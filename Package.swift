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
    targets: [
        .target(
            name: "PatchouliCore"
        ),
        .testTarget(
            name: "PatchouliCoreTests",
            dependencies: ["PatchouliCore"]),
    ]
)
