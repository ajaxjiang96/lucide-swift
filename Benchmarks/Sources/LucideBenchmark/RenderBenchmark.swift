import Foundation
import AppKit
import SwiftUI
import CoreGraphics
import LucideSwift
import LucideIcons

/// Benchmarks rendering performance for both libraries.
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

    /// Time how long it takes to render N icons to a 24x24 CGImage.
    static func measure(iconCount: Int = 200) -> Result {
        let allNames = LucideIconName.allNames
        let sampleNames = Array(allNames.prefix(iconCount))
        let size = CGSize(width: 24, height: 24)

        // Warm up
        for name in sampleNames.prefix(5) {
            if let shape = LucideIconName(rawValue: name)?.shape {
                _ = renderLucideShape(shape, size: size)
            }
            let kebabName = NameConversion.camelToKebab(name)
            _ = renderLucideIconsImage(named: kebabName, size: size)
        }

        // LucideSwift: render via CoreGraphics rasterization of Shape
        let lucideSwiftClock = ContinuousClock()
        let lucideSwiftTime = lucideSwiftClock.measure {
            for name in sampleNames {
                guard let shape = LucideIconName(rawValue: name)?.shape else { continue }
                _ = renderLucideShape(shape, size: size)
            }
        }

        // lucide-icons-swift: extract CGImage from NSImage (uses kebab-case IDs)
        let lucideIconsClock = ContinuousClock()
        let lucideIconsSwiftTime = lucideIconsClock.measure {
            for name in sampleNames {
                let kebabName = NameConversion.camelToKebab(name)
                _ = renderLucideIconsImage(named: kebabName, size: size)
            }
        }

        return Result(
            lucideSwiftTime: lucideSwiftTime,
            lucideIconsSwiftTime: lucideIconsSwiftTime,
            iconCount: sampleNames.count
        )
    }

    // MARK: - Private

    private static func renderLucideShape(_ shape: LucideShape, size: CGSize) -> CGImage? {
        let scale: CGFloat = 2.0
        let pixelWidth = max(1, Int(size.width * scale))
        let pixelHeight = max(1, Int(size.height * scale))

        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return nil }

        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)
        context.translateBy(x: 0, y: CGFloat(pixelHeight))
        context.scaleBy(x: scale, y: -scale)

        let rect = CGRect(origin: .zero, size: size)
        let path = shape.path(in: rect)
        context.addPath(path.cgPath)
        context.setStrokeColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
        context.setLineWidth(2)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        context.strokePath()

        return context.makeImage()
    }

    private static func renderLucideIconsImage(named name: String, size: CGSize) -> CGImage? {
        guard let nsImage = NSImage.image(lucideId: name) else { return nil }
        guard let tiffData = nsImage.tiffRepresentation,
              let _ = NSBitmapImageRep(data: tiffData) else {
            return nil
        }

        // Resize to target size
        let resizedImage = NSImage(size: size)
        resizedImage.lockFocus()
        nsImage.draw(in: CGRect(origin: .zero, size: size),
                     from: .zero,
                     operation: .copy,
                     fraction: 1.0)
        resizedImage.unlockFocus()

        // Extract CGImage from the resized image
        guard let resizedTIFF = resizedImage.tiffRepresentation,
              let resizedBitmap = NSBitmapImageRep(data: resizedTIFF),
              let cgImage = resizedBitmap.cgImage else {
            return nil
        }

        return cgImage
    }

    /// Convert a Duration to seconds as Double, including both the seconds
    /// and attoseconds components (not just the sub-second attoseconds part).
    private static func durationToSeconds(_ duration: Duration) -> Double {
        Double(duration.components.seconds) + Double(duration.components.attoseconds) / 1_000_000_000_000_000_000
    }
}
