// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SVGPath",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "SVGPath",
            targets: ["SVGPath"]
        )
    ],
    targets: [
        .target(
            name: "SVGPath",
            path: "Sources/SVGPath"
        )
    ]
)
