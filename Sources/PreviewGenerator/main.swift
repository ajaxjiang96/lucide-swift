#if os(macOS)
import AppKit
#endif
import SwiftUI
import LucideSwift

/// Renders a SwiftUI view to a PNG file at the given path.
@available(macOS 13.0, *)
@MainActor
func renderToPNG<V: View>(_ view: V, size: CGSize, scale: CGFloat, outputPath: String) {
    let renderer = ImageRenderer(content: view.frame(width: size.width, height: size.height))
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

        // Standard preview (600px wide, 2× scale)
        let galleryView = LucideGallery()
            .frame(width: 600)
        renderToPNG(galleryView, size: CGSize(width: 600, height: 800), scale: 2.0, outputPath: "docs/preview.png")

        // Social media preview (1280×640, 1× scale for exact dimensions)
        let socialView = SocialPreview()
        renderToPNG(socialView, size: CGSize(width: 1280, height: 640), scale: 1.0, outputPath: "docs/social-preview.png")
    }
} else {
    print("❌ ImageRenderer requires macOS 13.0 or newer")
}
#else
print("❌ PreviewGenerator is only available on macOS")
#endif
