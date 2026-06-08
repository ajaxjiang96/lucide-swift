import Foundation

// MARK: - Lucide Benchmark

/// Entry point for the LucideSwift vs lucide-icons-swift benchmark suite.
///
/// Run from the Benchmarks/ directory:
/// ```bash
/// swift run -c release LucideBenchmark
/// ```
///
/// The benchmark measures four dimensions:
/// 1. Binary size
/// 2. Icon lookup speed
/// 3. Render performance
/// 4. Memory usage
///
/// Results are printed as a markdown report to stdout and saved to `benchmark-report.md`.

@main
struct LucideBenchmarkMain {
    static func main() {
        print("🔬 LucideSwift Benchmark")
        print("========================")
        print("Comparing: LucideSwift (Shape) vs lucide-icons-swift (Assets)")
        print("")

        var rows: [BenchmarkRow] = []

        // 1. Binary Size
        print("📦 Measuring binary size...")
        let binaryResult = BinarySizeBenchmark.measure()
        rows.append(BenchmarkRow(
            dimension: "Binary Size",
            lucideSwift: ReportFormatter.formatBytes(binaryResult.lucideSwiftBytes),
            lucideIconsSwift: ReportFormatter.formatBytes(binaryResult.lucideIconsSwiftBytes),
            note: "LucideSwift size includes generated source + compiled objects. lucide-icons-swift includes PDF asset catalog."
        ))

        // 2. Lookup Speed
        print("🔍 Measuring lookup speed...")
        let lookupResult = LookupSpeedBenchmark.measure(iterations: 10)
        rows.append(BenchmarkRow(
            dimension: "Lookup Speed (avg)",
            lucideSwift: ReportFormatter.formatTime(lookupResult.lucideSwiftAvgSeconds),
            lucideIconsSwift: ReportFormatter.formatTime(lookupResult.lucideIconsSwiftAvgSeconds),
            note: "Enum raw-value lookup vs NSImage bundle lookup. \(lookupResult.iterations) iterations × \(lookupResult.iconCount) icons."
        ))

        // 3. Render Performance
        print("🎨 Measuring render performance...")
        let renderResult = RenderBenchmark.measure(iconCount: 200)
        rows.append(BenchmarkRow(
            dimension: "Render (per icon)",
            lucideSwift: ReportFormatter.formatTime(renderResult.lucideSwiftAvgSeconds),
            lucideIconsSwift: ReportFormatter.formatTime(renderResult.lucideIconsSwiftAvgSeconds),
            note: "Time to rasterize to 24×24 CGImage. \(renderResult.iconCount) icons."
        ))

        // 4. Memory Usage
        print("💾 Measuring memory usage...")
        let memoryResult = MemoryBenchmark.measure()
        rows.append(BenchmarkRow(
            dimension: "Memory (all icons)",
            lucideSwift: ReportFormatter.formatBytes(memoryResult.lucideSwiftDeltaBytes),
            lucideIconsSwift: ReportFormatter.formatBytes(memoryResult.lucideIconsSwiftDeltaBytes),
            note: "Resident memory delta after loading all \(memoryResult.iconCount) icons."
        ))

        // Generate and output report
        print("")
        print("📝 Generating report...")
        let report = ReportFormatter.generate(rows: rows)

        // Print to stdout
        print(report)

        // Save to file
        let outputPath = "benchmark-report.md"
        do {
            try report.write(toFile: outputPath, atomically: true, encoding: .utf8)
            print("")
            print("✅ Report saved to \(outputPath)")
        } catch {
            print("⚠️  Could not save report: \(error)")
            Foundation.exit(1)
        }
    }
}
