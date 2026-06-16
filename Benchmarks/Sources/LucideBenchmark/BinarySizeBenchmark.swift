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
    /// SPM 5.9+ places intermediates under `.build/out/Intermediates.noindex/<Module>.build/`;
    /// older versions or custom configurations may use `.build/<triple>/release/<Module>.build/`.
    /// We try the modern path first, then fall back.
    private static func moduleObjectFileSize(moduleName: String) -> UInt64 {
        // Primary: SPM 5.9+ intermediates directory
        let intermediatesPath = "./.build/out/Intermediates.noindex/\(moduleName).build"
        if let size = objectFilesSize(in: intermediatesPath), size > 0 {
            return size
        }

        // Fallback 1: toolchain-triple-scoped release directory (older SPM, custom scratch paths)
        if let releaseDir = findReleaseBuildDir() {
            let legacyPath = "\(releaseDir)/\(moduleName).build"
            if let size = objectFilesSize(in: legacyPath), size > 0 {
                return size
            }
        }

        // Last resort: sum the top-level .o products
        return fileSize(at: "./.build/release/\(moduleName).o")
            + fileSize(at: "./.build/out/Products/Release/\(moduleName).o")
    }

    /// Sum .o file sizes in a directory, returning nil if the path doesn't exist or has no .o files.
    private static func objectFilesSize(in directory: String) -> UInt64? {
        let fileManager = FileManager.default
        guard fileManager.fileExists(atPath: directory),
              let enumerator = fileManager.enumerator(atPath: directory) else {
            return nil
        }

        var total: UInt64 = 0
        for case let file as String in enumerator {
            if file.hasSuffix(".o") {
                total += fileSize(at: "\(directory)/\(file)")
            }
        }
        return total
    }

    /// Find a release build directory that contains compiled products.
    /// Returns a path like `.build/arm64-apple-macosx/release` if one exists.
    private static func findReleaseBuildDir() -> String? {
        let buildDir = "./.build"
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(atPath: buildDir) else { return nil }

        for entry in contents {
            guard entry != "out",
                  entry != "artifacts",
                  entry != "checkouts",
                  entry != "repositories",
                  let subContents = try? fileManager.contentsOfDirectory(atPath: "\(buildDir)/\(entry)") else {
                continue
            }
            if subContents.contains("release") {
                return "\(buildDir)/\(entry)/release"
            }
        }
        return nil
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
