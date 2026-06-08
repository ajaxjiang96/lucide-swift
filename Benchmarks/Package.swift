// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LucideBenchmarks",
    platforms: [.macOS(.v13)],
    dependencies: [
        // The parent LucideSwift package (path reference — identity matches repo dir name)
        .package(path: "../"),
        // The image-asset-based comparison package
        .package(url: "https://github.com/JakubMazur/lucide-icons-swift.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "LucideBenchmark",
            dependencies: [
                .product(name: "LucideSwift", package: "lucide-swift"),
                .product(name: "LucideIcons", package: "lucide-icons-swift"),
            ],
            path: "Sources/LucideBenchmark"
        ),
    ]
)
