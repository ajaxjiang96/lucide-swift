import SwiftUI
import AppKit
import LucideSwift

@main
struct PreviewGenerator {
    @MainActor
    static func main() async {
        if #available(macOS 13.0, *) {
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
        } else {
            print("❌ ImageRenderer requires macOS 13.0 or newer")
            exit(1)
        }
    }
}
