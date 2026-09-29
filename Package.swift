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

        .library(name: "Decimal Foundation Integration", targets: ["Decimal Foundation Integration"]),
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
            name: "Decimal Foundation Integration",
            dependencies: [
                .target(name: "Decimal"),
            ],
            path: "Sources/Decimal Foundation Integration"
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
                .target(name: "Decimal Foundation Integration"),
            ],
            path: "Tests/Decimal Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    target.swiftSettings = (target.swiftSettings ?? []) + [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableExperimentalFeature("Lifetimes"),
        .treatAllWarnings(as: .error),
    ]
}
