#if os(macOS)
import AppKit
#endif
import SwiftUI
import LucideSwift

#if os(macOS)
if #available(macOS 13.0, *) {
    await MainActor.run {
        // Ensure docs directory exists
        let docsURL = URL(fileURLWithPath: "docs")
        try? FileManager.default.createDirectory(at: docsURL, withIntermediateDirectories: true)
        
        let view = LucideGallery()
            .frame(width: 600)
        
        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        
        if let image = renderer.nsImage {
            if let tiffData = image.tiffRepresentation,
               let bitmap = NSBitmapImageRep(data: tiffData),
               let pngData = bitmap.representation(using: .png, properties: [:]) {
                let fileURL = docsURL.appendingPathComponent("preview.png")
                do {
                    try pngData.write(to: fileURL)
                    print("✅ Preview generated at \(fileURL.path)")
                } catch {
                    print("❌ Failed to write preview: \(error)")
                }
            }
        } else {
            print("❌ Failed to render image")
        }
    }
} else {
    print("❌ ImageRenderer requires macOS 13.0 or newer")
}
#else
print("❌ PreviewGenerator is only available on macOS")
#endif
