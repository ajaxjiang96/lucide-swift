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
        // Sum all .o files from the LucideSwift module — the linked code that ships
        // in the app binary. SPM places these under out/Intermediates.noindex/.
        return moduleObjectFileSize(moduleName: "LucideSwift")
    }

    private static func measureLucideIconsSwiftSize() -> UInt64 {
        // .o files + compiled asset catalog — what ships in the app bundle.
        return moduleObjectFileSize(moduleName: "LucideIcons")
            + directorySize(at: "./.build/checkouts/lucide-icons-swift/Sources/LucideIcons/icons.xcassets")
    }

    /// Sum all .o object files for a given module inside the SPM build output directory.
    /// Searches under `.build/out/Intermediates.noindex/<Module>.build/` which is
    /// the standard layout for Swift 5.9+ SPM release and debug builds.
    private static func moduleObjectFileSize(moduleName: String) -> UInt64 {
        let intermediatesPath = "./.build/out/Intermediates.noindex/\(moduleName).build"
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: intermediatesPath),
              let enumerator = fileManager.enumerator(atPath: intermediatesPath) else {
            // Fallback: try the top-level product .o file
            return directorySize(at: "./.build/out/Products/Release")
        }

        var total: UInt64 = 0
        for case let file as String in enumerator {
            if file.hasSuffix(".o") {
                let fullPath = "\(intermediatesPath)/\(file)"
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
