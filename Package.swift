// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LucideSwift",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "LucideSwift",
            targets: ["LucideSwift"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "LucideSwift",
            dependencies: []
        ),
        .testTarget(
            name: "LucideSwiftTests",
            dependencies: ["LucideSwift"]
        ),
        .executableTarget(
            name: "LucideGenerator",
            dependencies: []
        ),
    ]
)
