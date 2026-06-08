import Foundation
import LucideSwift
import LucideIcons

/// Measures memory footprint of loading all icons from each library.
enum MemoryBenchmark {

    struct Result {
        let lucideSwiftDeltaBytes: UInt64
        let lucideIconsSwiftDeltaBytes: UInt64
        let iconCount: Int
    }

    /// Measure memory delta before and after loading all icons.
    static func measure() -> Result {
        let allLucideNames = LucideIconName.allNames

        // --- LucideSwift ---
        let beforeLucide = residentMemory()
        var shapes: [LucideShape] = []
        for name in allLucideNames {
            if let shape = LucideIconName(rawValue: name)?.shape {
                shapes.append(shape)
            }
        }
        let afterLucide = residentMemory()
        let lucideDelta = afterLucide > beforeLucide ? afterLucide - beforeLucide : 0

        // Clear and drain autorelease pool to avoid contaminating the next phase
        shapes.removeAll()
        autoreleasepool { }
        Thread.sleep(forTimeInterval: 0.1)

        // --- lucide-icons-swift ---
        let beforeLucideIcons = residentMemory()
        var images: [NSImage] = []
        for name in allLucideNames {
            let kebabName = NameConversion.camelToKebab(name)
            guard let image = NSImage.image(lucideId: kebabName) else { continue }
            images.append(image)
        }
        let afterLucideIcons = residentMemory()
        let lucideIconsDelta = afterLucideIcons > beforeLucideIcons ? afterLucideIcons - beforeLucideIcons : 0

        return Result(
            lucideSwiftDeltaBytes: lucideDelta,
            lucideIconsSwiftDeltaBytes: lucideIconsDelta,
            iconCount: allLucideNames.count
        )
    }

    // MARK: - Private

    /// Returns the current resident memory size in bytes.
    /// Uses `task_info` to get the phys_footprint of the current process.
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
