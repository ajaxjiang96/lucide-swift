import Foundation

/// Measures the compiled binary size of each library.
enum BinarySizeBenchmark {

    struct Result {
        let lucideSwiftBytes: UInt64
        let lucideIconsSwiftBytes: UInt64
    }

    /// Measures binary size by compiling both packages and inspecting the built products.
    ///
    /// LucideSwift is a library target; we measure the object files and the generated source.
    /// lucide-icons-swift bundles an asset catalog; we measure the entire package checkout.
    static func measure() -> Result {
        // LucideSwift: measure the compiled .o files from the release build
        // We build both packages via a single benchmark build, so LucideSwift
        // is already compiled as a dependency. We can measure its object files
        // and the Lucide+Generated.swift source as a proxy for code size.
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

        // Measure the generated code file (the bulk of the library)
        let generatedPath = "../Sources/LucideSwift/Lucide+Generated.swift"
        total += fileSize(at: generatedPath)

        // Measure the compiled object files
        let buildDir = "../.build"
        total += directorySize(at: "\(buildDir)/debug/LucideSwift.build")

        return total
    }

    private static func measureLucideIconsSwiftSize() -> UInt64 {
        var total: UInt64 = 0

        // Measure the checkout directory (includes asset catalog and generated Swift)
        let checkoutPath = "../.build/checkouts/lucide-icons-swift"
        total += directorySize(at: checkoutPath)

        // Measure compiled object files for LucideIcons target
        let buildDir = "../.build"
        total += directorySize(at: "\(buildDir)/debug/LucideIcons.build")

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
