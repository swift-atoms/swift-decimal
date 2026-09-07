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
        .library(name: "Decimal", targets: ["Decimal"]),
        .library(name: "Decimal Standard Library Integration", targets: ["Decimal Standard Library Integration"]),
        .library(name: "Decimal Foundation Library Integration", targets: ["Decimal Foundation Library Integration"]),
        .library(name: "Decimal Test Support", targets: ["Decimal Test Support"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Decimal",
            dependencies: [
            ],
            path: "Sources/Decimal"
        ),
        .target(
            name: "Decimal Standard Library Integration",
            dependencies: [
                .target(name: "Decimal"),
            ],
            path: "Sources/Decimal Standard Library Integration"
        ),
        .target(
            name: "Decimal Foundation Library Integration",
            dependencies: [
                .target(name: "Decimal"),
                .target(name: "Decimal Standard Library Integration"),
            ],
            path: "Sources/Decimal Foundation Library Integration"
        ),
        .target(
            name: "Decimal Test Support",
            dependencies: [
                .target(name: "Decimal"),
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Decimal Tests",
            dependencies: [
                .target(name: "Decimal"),
                .target(name: "Decimal Test Support"),
                .target(name: "Decimal Standard Library Integration"),
                .target(name: "Decimal Foundation Library Integration"),
            ],
            path: "Tests/Decimal Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets {
    target.swiftSettings = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .strictMemorySafety(),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
}
