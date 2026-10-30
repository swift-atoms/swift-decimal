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
        .library(name: "Decimals", targets: ["Decimals"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-ascii.git", branch: "main", traits: ["Serializer"]),
        .package(url: "https://github.com/swift-atoms/swift-rounding.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-division.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "Decimal",
            dependencies: [],
            path: "Sources/Decimal"
        ),

        .target(
            name: "Decimal Foundation Integration",
            dependencies: [
                .target(name: "Decimal")
            ],
            path: "Sources/Decimal Foundation Integration"
        ),
        .target(
            name: "Decimal Test Support",
            dependencies: [
                .target(name: "Decimal")
            ],
            path: "Tests/Support"
        ),
        .testTarget(
            name: "Decimal Tests",
            dependencies: [
                .target(name: "Decimal"),
                .target(name: "Decimal Test Support"),
            ],
            path: "Tests/Decimal Tests"
        ),
        .target(
            name: "Decimals",
            dependencies: [
                .target(name: "Decimal"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Rounding", package: "swift-rounding"),
                .product(name: "Division", package: "swift-division"),
            ]
        ),
        .testTarget(
            name: "Decimals Tests",
            dependencies: [
                .target(name: "Decimals"),
                .product(name: "Rounding", package: "swift-rounding"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    target.swiftSettings =
        (target.swiftSettings ?? []) + [
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
