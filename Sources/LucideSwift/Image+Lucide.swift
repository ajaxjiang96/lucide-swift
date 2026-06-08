//
//  Image+Lucide.swift
//  LucideSwift
//
//  Extension for creating SwiftUI Image directly from Lucide icons
//

import SwiftUI
import CoreGraphics

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public extension Image {

    /// Creates a SwiftUI Image from a LucideShape.
    ///
    /// The resulting image is generated in template rendering mode, meaning it
    /// will automatically adapt to standard SwiftUI `.foregroundColor()` modifiers.
    ///
    /// - Note: The image is rasterized from a vector path during initialization.
    /// Scaling it up significantly using `.resizable()` may result in pixelation.
    /// For best results, specify the target point size during initialization.
    ///
    /// - Parameters:
    ///   - shape: The LucideShape to render
    ///   - size: The target point size of the image (default 24x24)
    ///   - strokeWidth: The stroke width to use (default 2)
    ///   - style: The rendering style — `.stroked` (default) or `.filled`
    init(lucide shape: LucideShape, size: CGSize = CGSize(width: 24, height: 24), strokeWidth: CGFloat = 2, style: LucideIconStyle = .stroked) {
        let cgImage = Self.renderTemplate(shape: shape, size: size, strokeWidth: strokeWidth, style: style)
        self = Image(cgImage, scale: 3.0, label: Text("Lucide Icon")).renderingMode(.template)
    }

    /// Creates a SwiftUI Image from a ``LucideIconName``.
    init(lucide iconName: LucideIconName, size: CGSize = CGSize(width: 24, height: 24), strokeWidth: CGFloat = 2, style: LucideIconStyle = .stroked) {
        self.init(lucide: iconName.shape, size: size, strokeWidth: strokeWidth, style: style)
    }

    /// Creates a SwiftUI Image from a ``LucideLabIconName``.
    init(lucideLab iconName: LucideLabIconName, size: CGSize = CGSize(width: 24, height: 24), strokeWidth: CGFloat = 2, style: LucideIconStyle = .stroked) {
        self.init(lucide: iconName.shape, size: size, strokeWidth: strokeWidth, style: style)
    }

    // MARK: - Private Renderer

    private static func renderTemplate(shape: LucideShape, size: CGSize, strokeWidth: CGFloat, style: LucideIconStyle) -> CGImage {
        let scale: CGFloat = 3.0 // Render at @3x scale for retina sharpness
        let pixelWidth = max(1, Int(size.width * scale))
        let pixelHeight = max(1, Int(size.height * scale))

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: pixelWidth,
            height: pixelHeight,
            bitsPerComponent: 8,
            bytesPerRow: pixelWidth * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            return createEmptyCGImage()
        }

        context.setAllowsAntialiasing(true)
        context.setShouldAntialias(true)

        // Flip coordinate system to match SwiftUI (Top-left origin)
        context.translateBy(x: 0, y: CGFloat(pixelHeight))
        context.scaleBy(x: scale, y: -scale)

        let rect = CGRect(origin: .zero, size: size)

        if style == .filled {
            // Draw filled portions
            let closedPath = shape.closedPath(in: rect)
            if !closedPath.isEmpty {
                context.addPath(closedPath.cgPath)
                context.setFillColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                // EO fill rule matches how Lucide shapes are generated
                context.drawPath(using: .eoFill)
            }

            // Draw stroked portions
            let openPath = shape.openPath(in: rect)
            if !openPath.isEmpty {
                context.addPath(openPath.cgPath)
                context.setStrokeColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                context.setLineWidth(strokeWidth)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.strokePath()
            }
        } else {
            // Draw regular stroked icon
            let scaledPath = shape.path(in: rect)
            if !scaledPath.isEmpty {
                context.addPath(scaledPath.cgPath)
                context.setStrokeColor(CGColor(red: 0, green: 0, blue: 0, alpha: 1))
                context.setLineWidth(strokeWidth)
                context.setLineCap(.round)
                context.setLineJoin(.round)
                context.strokePath()
            }
        }

        return context.makeImage() ?? createEmptyCGImage()
    }

    private static func createEmptyCGImage() -> CGImage {
        let context = CGContext(
            data: nil, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4,
            space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )!
        return context.makeImage()!
    }
}
