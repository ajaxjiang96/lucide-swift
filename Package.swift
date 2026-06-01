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
        .executable(
            name: "LucideGenerator",
            targets: ["LucideGenerator"]
        ),
        .executable(
            name: "PreviewGenerator",
            targets: ["PreviewGenerator"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/nicklockwood/SVGPath.git", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "LucideSwift",
            dependencies: []
        ),
        .testTarget(
            name: "LucideSwiftTests",
            dependencies: ["LucideSwift"]
        ),
        .testTarget(
            name: "LucideGeneratorTests",
            dependencies: ["LucideGenerator"]
        ),
        .executableTarget(
            name: "LucideGenerator",
            dependencies: [
                .product(name: "SVGPath", package: "SVGPath")
            ]
        ),
        .executableTarget(
            name: "PreviewGenerator",
            dependencies: ["LucideSwift"]
        ),
    ]
)
