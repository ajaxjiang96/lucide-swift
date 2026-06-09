import Foundation
import AppKit
import SwiftUI
import LucideSwift
import LucideIcons

/// Benchmarks rendering performance using each library's recommended View/Image API.
///
/// LucideSwift: `LucideIcon(.house, size: 24)` — the high-level SwiftUI View.
/// lucide-icons-swift: `Image(nsImage: ...)` — wrapping NSImage in SwiftUI.
enum RenderBenchmark {

    struct Result {
        let lucideSwiftTime: Duration
        let lucideIconsSwiftTime: Duration
        let iconCount: Int

        var lucideSwiftAvgSeconds: Double {
            durationToSeconds(lucideSwiftTime) / Double(iconCount)
        }

        var lucideIconsSwiftAvgSeconds: Double {
            durationToSeconds(lucideIconsSwiftTime) / Double(iconCount)
        }
    }

    /// Time how long it takes to create N icon Views/Images at 24pt.
    static func measure(iconCount: Int = 200) -> Result {
        let allNames = LucideIconName.allNames
        let sampleNames = Array(allNames.prefix(iconCount))

        // Warm up
        for name in sampleNames.prefix(5) {
            if let iconName = LucideIconName(rawValue: name) {
                _ = LucideIcon(iconName, size: 24)
            }
            let kebabName = NameConversion.camelToKebab(name)
            if let nsImage = NSImage.image(lucideId: kebabName) {
                _ = Image(nsImage: nsImage)
            }
        }

        // LucideSwift: create LucideIcon View (the recommended API)
        let lucideSwiftClock = ContinuousClock()
        let lucideSwiftTime = lucideSwiftClock.measure {
            for name in sampleNames {
                guard let iconName = LucideIconName(rawValue: name) else { continue }
                _ = LucideIcon(iconName, size: 24)
            }
        }

        // lucide-icons-swift: create Image(nsImage:) (the recommended API)
        let lucideIconsClock = ContinuousClock()
        let lucideIconsSwiftTime = lucideIconsClock.measure {
            for name in sampleNames {
                let kebabName = NameConversion.camelToKebab(name)
                guard let nsImage = NSImage.image(lucideId: kebabName) else { continue }
                _ = Image(nsImage: nsImage)
            }
        }

        return Result(
            lucideSwiftTime: lucideSwiftTime,
            lucideIconsSwiftTime: lucideIconsSwiftTime,
            iconCount: sampleNames.count
        )
    }

    private static func durationToSeconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    }
}
