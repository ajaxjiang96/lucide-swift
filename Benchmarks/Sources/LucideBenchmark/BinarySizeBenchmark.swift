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
        // Only .o files — the linked code that ships in the app binary.
        // Source text and intermediate build files are not shipped.
        return objectFileSize(at: "./.build/release/LucideSwift.build")
    }

    private static func measureLucideIconsSwiftSize() -> UInt64 {
        // .o files + compiled asset catalog — what ships in the app bundle.
        return objectFileSize(at: "./.build/release/LucideIcons.build")
            + directorySize(at: "./.build/checkouts/lucide-icons-swift/Sources/LucideIcons/icons.xcassets")
    }

    /// Sum only the .o object files in a build directory — these are what get linked.
    private static func objectFileSize(at path: String) -> UInt64 {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: path),
              let enumerator = fileManager.enumerator(atPath: path) else {
            return 0
        }

        var total: UInt64 = 0
        for case let file as String in enumerator {
            if file.hasSuffix(".o") {
                let fullPath = "\(path)/\(file)"
                total += fileSize(at: fullPath)
            }
        }
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
