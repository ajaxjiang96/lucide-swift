import Foundation
import AppKit
import LucideSwift
import LucideIcons

/// Benchmarks icon resolution speed using each library's recommended accessor.
///
/// LucideSwift: `LucideIconName(rawValue:)` — type-safe enum lookup.
/// lucide-icons-swift: `NSImage.image(lucideId:)` — string-based bundle lookup.
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

    static func measure(iterations: Int = 10) -> Result {
        let allNames = LucideIconName.allNames
        let sampleNames = Array(allNames.prefix(200))

        // Warm up
        for name in sampleNames {
            _ = LucideIconName(rawValue: name)
            let kebabName = NameConversion.camelToKebab(name)
            _ = NSImage.image(lucideId: kebabName)
        }

        // LucideSwift: enum raw-value lookup (the recommended API)
        let lucideSwiftClock = ContinuousClock()
        let lucideSwiftTime = lucideSwiftClock.measure {
            for _ in 0..<iterations {
                for name in sampleNames {
                    _ = LucideIconName(rawValue: name)
                }
            }
        }

        // lucide-icons-swift: NSImage bundle lookup (the recommended API)
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

    private static func durationToSeconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    }
}
