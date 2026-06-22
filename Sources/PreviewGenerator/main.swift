#if os(macOS)
import AppKit
#endif
import SwiftUI
import LucideSwift

/// Renders a SwiftUI view to a PNG file at the given path.
/// The view is responsible for its own sizing (via `.frame()`).
/// `scale` controls the output pixel density (2× = Retina).
@available(macOS 13.0, *)
@MainActor
func renderToPNG<V: View>(_ view: V, scale: CGFloat, outputPath: String) {
    let renderer = ImageRenderer(content: view)
    renderer.scale = scale

    guard let image = renderer.nsImage else {
        print("❌ Failed to render image for \(outputPath)")
        return
    }

    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("❌ Failed to encode PNG for \(outputPath)")
        return
    }

    do {
        let fileURL = URL(fileURLWithPath: outputPath)
        try pngData.write(to: fileURL)
        print("✅ Generated \(outputPath) (\(Int(bitmap.size.width))×\(Int(bitmap.size.height))px @\(Int(scale))×)")
    } catch {
        print("❌ Failed to write \(outputPath): \(error)")
    }
}

#if os(macOS)
if #available(macOS 13.0, *) {
    await MainActor.run {
        // Ensure docs directory exists
        let docsURL = URL(fileURLWithPath: "docs")
        try? FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)

        // Standard preview (width constrained to 600pt, height intrinsic, 2× scale)
        let galleryView = LucideGallery()
            .frame(width: 600)
        renderToPNG(galleryView, scale: 2.0, outputPath: "docs/preview.png")

        // Social media preview (1280×640, 1× scale)
        renderToPNG(SocialPreview(width: 1280, height: 640), scale: 1.0, outputPath: "docs/social-preview.png")

        // README header banner (1280×280, 1× scale)
        renderToPNG(SocialPreview(width: 1280, height: 280), scale: 1.0, outputPath: "docs/banner.png")

        // XHS social card (1080×1440, 3:4 ratio, 1× scale)
        renderToPNG(SocialPreview(width: 1080, height: 1440), scale: 1.0, outputPath: "docs/xhs-card.png")
    }
} else {
    print("❌ ImageRenderer requires macOS 13.0 or newer")
}
#else
print("❌ PreviewGenerator is only available on macOS")
#endif
