import Foundation
import AppKit
import SwiftUI
import LucideSwift
import LucideIcons

/// Measures memory footprint using each library's recommended access pattern.
///
/// LucideSwift: loading all `LucideIcon` Views (one per icon).
/// lucide-icons-swift: loading all `NSImage`s via `image(lucideId:)`.
enum MemoryBenchmark {

    struct Result {
        let lucideSwiftDeltaBytes: UInt64
        let lucideIconsSwiftDeltaBytes: UInt64
        let iconCount: Int
    }

    /// Measure resident memory delta after loading all icons through each library's recommended API.
    static func measure() -> Result {
        let allNames = LucideIconName.allNames

        // --- LucideSwift ---
        let beforeLucide = residentMemory()
        var icons: [LucideIcon] = []
        icons.reserveCapacity(allNames.count)
        for name in allNames {
            guard let iconName = LucideIconName(rawValue: name) else { continue }
            icons.append(LucideIcon(iconName, size: 24))
        }
        let afterLucide = residentMemory()
        let lucideDelta = afterLucide > beforeLucide ? afterLucide - beforeLucide : 0

        // Clear
        icons.removeAll()
        autoreleasepool { }
        Thread.sleep(forTimeInterval: 0.1)

        // --- lucide-icons-swift ---
        let beforeLucideIcons = residentMemory()
        var images: [NSImage] = []
        images.reserveCapacity(allNames.count)
        for name in allNames {
            let kebabName = NameConversion.camelToKebab(name)
            guard let image = NSImage.image(lucideId: kebabName) else { continue }
            images.append(image)
        }
        let afterLucideIcons = residentMemory()
        let lucideIconsDelta = afterLucideIcons > beforeLucideIcons ? afterLucideIcons - beforeLucideIcons : 0

        return Result(
            lucideSwiftDeltaBytes: lucideDelta,
            lucideIconsSwiftDeltaBytes: lucideIconsDelta,
            iconCount: allNames.count
        )
    }

    // MARK: - Private

    private static func residentMemory() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { reboundPtr in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), reboundPtr, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }
        // resident_size includes shared pages, but the delta between phases
        // cancels out shared overhead since both libraries share the same runtime deps
        return info.resident_size
    }
}
