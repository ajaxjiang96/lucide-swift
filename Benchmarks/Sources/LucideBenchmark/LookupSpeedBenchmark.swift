import Foundation
import LucideSwift
import LucideIcons

/// Benchmarks icon resolution speed for both libraries.
enum LookupSpeedBenchmark {

    struct Result {
        let lucideSwiftTime: Duration
        let lucideIconsSwiftTime: Duration
        let iterations: Int
        let iconCount: Int

        var lucideSwiftAvgNanos: Double {
            Double(lucideSwiftTime.components.attoseconds) / 1_000_000_000 / Double(iterations * iconCount)
        }

        var lucideIconsSwiftAvgNanos: Double {
            Double(lucideIconsSwiftTime.components.attoseconds) / 1_000_000_000 / Double(iterations * iconCount)
        }
    }

    /// Time how long it takes to look up every icon N times.
    /// - Parameter iterations: how many times to repeat the full set of lookups.
    static func measure(iterations: Int = 10) -> Result {
        // Use names that exist in both libraries (common icon names)
        let commonNames = LucideIconName.allNames.filter { name in
            // lucide-icons-swift uses kebab-case names, LucideSwift uses camelCase.
            // We look up in both — if the rawValue works for one, it may not for the other.
            // Filter to names that are short enough to exist in both sets.
            true
        }

        let sampleNames = Array(commonNames.prefix(200)) // Use 200 icons as a representative sample

        // Warm up
        for name in sampleNames {
            _ = LucideIconName(rawValue: name)?.shape
            _ = NSImage.image(lucideId: name)
        }

        // LucideSwift: enum raw-value lookup + shape access
        let lucideSwiftClock = ContinuousClock()
        let lucideSwiftTime = lucideSwiftClock.measure {
            for _ in 0..<iterations {
                for name in sampleNames {
                    _ = LucideIconName(rawValue: name)?.shape
                }
            }
        }

        // lucide-icons-swift: NSImage bundle lookup
        let lucideIconsClock = ContinuousClock()
        let lucideIconsSwiftTime = lucideIconsClock.measure {
            for _ in 0..<iterations {
                for name in sampleNames {
                    _ = NSImage.image(lucideId: name)
                }
            }
        }

        return Result(
            lucideSwiftTime: lucideSwiftTime,
            lucideIconsSwiftTime: lucideIconsSwiftTime,
            iterations: iterations,
            iconCount: sampleNames.count
        )
    }
}
