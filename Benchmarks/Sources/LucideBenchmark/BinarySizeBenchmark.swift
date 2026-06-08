import Foundation

/// Measures the compiled binary size of each library.
enum BinarySizeBenchmark {

    struct Result {
        let lucideSwiftBytes: UInt64
        let lucideIconsSwiftBytes: UInt64
    }

    /// Measures binary size by inspecting source files and compiled products.
    ///
    /// When the benchmark runs from the `Benchmarks/` directory (`swift run -c release LucideBenchmark`),
    /// SPM writes all build artifacts under `Benchmarks/.build/`, including the parent package
    /// (referenced by `path: "../"`) and the comparison package checkouts.
    static func measure() -> Result {
        let lucideSwiftSize = measureLucideSwiftSize()
        let lucideIconsSize  = measureLucideIconsSwiftSize()

        return Result(
            lucideSwiftBytes: lucideSwiftSize,
            lucideIconsSwiftBytes: lucideIconsSize
        )
    }

    // MARK: - Private

    private static func measureLucideSwiftSize() -> UInt64 {
        var total: UInt64 = 0

        // Measure the generated code file (the bulk of the library) — relative to Benchmarks/
        let generatedPath = "../Sources/LucideSwift/Lucide+Generated.swift"
        total += fileSize(at: generatedPath)

        // Measure compiled objects for LucideSwift (built as dependency under Benchmarks/.build)
        // With -c release, SPM uses the release configuration subdirectory
        total += directorySize(at: "./.build/release/LucideSwift.build")

        return total
    }

    private static func measureLucideIconsSwiftSize() -> UInt64 {
        var total: UInt64 = 0

        // Measure the asset catalog (the shipped product) + compiled objects, not the full checkout
        total += directorySize(at: "./.build/checkouts/lucide-icons-swift/Sources/LucideIcons/icons.xcassets")
        total += directorySize(at: "./.build/release/LucideIcons.build")

        return total
    }

    private static func fileSize(at path: String) -> UInt64 {
        guard let attrs = try? FileManager.default.attributesOfItem(atPath: path),
              let size = attrs[.size] as? UInt64 else {
            return 0
        }
        return size
    }

    private static func directorySize(at path: String) -> UInt64 {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path),
              let enumerator = fileManager.enumerator(atPath: path) else {
            return 0
        }

        var total: UInt64 = 0
        for case let file as String in enumerator {
            let fullPath = "\(path)/\(file)"
            total += fileSize(at: fullPath)
        }
        return total
    }
}
