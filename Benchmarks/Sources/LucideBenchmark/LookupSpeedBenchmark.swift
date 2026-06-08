import Foundation
import AppKit
import LucideSwift
import LucideIcons

/// Benchmarks icon resolution speed for both libraries.
enum LookupSpeedBenchmark {

    struct Result {
        let lucideSwiftTime: Duration
        let lucideIconsSwiftTime: Duration
        let iterations: Int
        let iconCount: Int

        var lucideSwiftAvgSeconds: Double {
            durationToSeconds(lucideSwiftTime) / Double(iterations * iconCount)
        }

        var lucideIconsSwiftAvgSeconds: Double {
            durationToSeconds(lucideIconsSwiftTime) / Double(iterations * iconCount)
        }
    }

    /// Time how long it takes to look up every icon N times.
    /// - Parameter iterations: how many times to repeat the full set of lookups.
    static func measure(iterations: Int = 10) -> Result {
        let allNames = LucideIconName.allNames
        let sampleNames = Array(allNames.prefix(200))

        // Warm up
        for name in sampleNames {
            _ = LucideIconName(rawValue: name)?.shape
            let kebabName = NameConversion.camelToKebab(name)
            _ = NSImage.image(lucideId: kebabName)
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

        // lucide-icons-swift: NSImage bundle lookup (uses kebab-case IDs)
        let lucideIconsClock = ContinuousClock()
        let lucideIconsSwiftTime = lucideIconsClock.measure {
            for _ in 0..<iterations {
                for name in sampleNames {
                    let kebabName = NameConversion.camelToKebab(name)
                    _ = NSImage.image(lucideId: kebabName)
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

    /// Convert a Duration to seconds as Double, including both the seconds
    /// and attoseconds components (not just the sub-second attoseconds part).
    private static func durationToSeconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    }
}
