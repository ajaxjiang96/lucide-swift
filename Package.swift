// swift-tools-version:5.9
//
//  LucideSwift — Vector-first, type-safe Swift package for Lucide Icons
//
//  Package URL: https://github.com/ajaxjiang96/lucide-swift.git
//  Keywords: swiftui, icons, lucide, svg, vector-graphics, shapes,
//            icon-library, swift, ios, macos
//  Platforms: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+, visionOS 1+
//  License: ISC
//  Upstream: https://lucide.dev | https://github.com/lucide-icons/lucide
//
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
        // Using local patched copy with fix for relative move (m) command
        // See PatchedDependencies/SVGPath for details
        .package(path: "PatchedDependencies/SVGPath")
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
