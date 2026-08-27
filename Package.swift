// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-decimal",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(
            name: "Decimal",
            targets: ["Decimal"]
        ),
        .library(
            name: "Decimal Standard Library Integration",
            targets: ["Decimal Standard Library Integration"]
        ),
        .library(
            name: "Decimal Apple Foundation Integration",
            targets: ["Decimal Apple Foundation Integration"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Decimal",
            dependencies: []
        ),
        .target(
            name: "Decimal Standard Library Integration",
            dependencies: ["Decimal"]
        ),
        .target(
            name: "Decimal Apple Foundation Integration",
            dependencies: [
                "Decimal",
                "Decimal Standard Library Integration",
            ]
        ),
        .testTarget(
            name: "Decimal Tests",
            dependencies: ["Decimal"],
            path: "Tests/Decimal Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
