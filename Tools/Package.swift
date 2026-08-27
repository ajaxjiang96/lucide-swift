// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "LucideSwiftTools",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "LucideGenerator", targets: ["LucideGenerator"]),
        .executable(name: "PreviewGenerator", targets: ["PreviewGenerator"])
    ],
    dependencies: [
        .package(name: "LucideSwift", path: ".."),
        .package(path: "PatchedDependencies/SVGPath")
    ],
    targets: [
        .executableTarget(
            name: "LucideGenerator",
            dependencies: [
                .product(name: "SVGPath", package: "SVGPath")
            ]
        ),
        .executableTarget(
            name: "PreviewGenerator",
            dependencies: [
                .product(name: "LucideSwift", package: "LucideSwift")
            ]
        ),
        .testTarget(
            name: "LucideGeneratorTests",
            dependencies: ["LucideGenerator"]
        )
    ]
)
