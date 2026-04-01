# Lucide Swift

A vector-first, type-safe Swift package for [Lucide Icons](https://lucide.dev) with native SwiftUI support.

## Features

- **True Vector Rendering**: SVG paths converted to native SwiftUI `Shape` - scales infinitely to any size without pixelation
- **Type-safe API**: 1694 icons as compile-time checked enum cases with full Xcode autocomplete
- **Zero Runtime Dependencies**: Pure Swift implementation, no external dependencies at runtime
- **SwiftUI Native**: Built on SwiftUI's `Shape` protocol with full modifier support
- **Multi-Platform**: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+, visionOS 1+
- **Adjustable Stroke Width**: Control stroke width with `strokeWidth` parameter
- **Absolute Stroke Width**: Keep stroke constant regardless of icon size with `absoluteStrokeWidth`

## Requirements

- **Swift**: 5.9+
- **Platforms**: SwiftUI apps only (not UIKit/AppKit compatible)

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/ajaxjiang96/lucide-swift.git", from: "1.0.0")
]
```

Or add via Xcode: File → Add Package Dependencies → Enter the repository URL

## Usage

```swift
import LucideSwift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // Type-safe enum access (recommended)
            LucideIcon(.house)
            LucideIcon(.settings, size: 32, color: .blue)
            
            // String-based access with fallback
            LucideIcon(name: "house", size: 24)
            LucideIcon(name: "settings", size: 32, color: .blue)
            
            // Use as native SwiftUI Shape
            Lucide.house
                .stroke(Color.red, lineWidth: 2)
                .frame(width: 40, height: 40)
                .background(Color.yellow.opacity(0.2))
        }
    }
}
```

### Advanced Usage

```swift
// Filled icons
LucideIconFill(.star, size: 48, color: .yellow)

// Access the underlying Shape directly
let shape: LucideShape = Lucide.house

// Use with Label (for menus, toolbars, buttons)
Label("Settings", lucide: .settings)
Button(action: {}) {
    Label("Save", lucide: .save)
}
```

### Stroke Width

Control the stroke width with the `strokeWidth` parameter (default: 2):

```swift
// Different stroke widths
LucideIcon(.heart, size: 48, strokeWidth: 1)  // Thin
LucideIcon(.heart, size: 48, strokeWidth: 2)  // Default
LucideIcon(.heart, size: 48, strokeWidth: 3)  // Thick
```

Use `absoluteStrokeWidth` to keep stroke width constant regardless of icon size:

```swift
// Default behavior: stroke scales with icon size
LucideIcon(.heart, size: 24)  // 2px stroke
LucideIcon(.heart, size: 48)  // 4px stroke (scaled)

// With absoluteStrokeWidth: constant stroke width
LucideIcon(.heart, size: 24, absoluteStrokeWidth: true)  // 2px stroke
LucideIcon(.heart, size: 48, absoluteStrokeWidth: true)  // 2px stroke (same!)
```

### API Reference

**LucideIcon** - SwiftUI View wrapper
- `init(_ iconName: LucideIconName, size: CGFloat = 24, color: Color? = nil, strokeWidth: CGFloat = 2, absoluteStrokeWidth: Bool = false)` - Type-safe enum
- `init(name: String, size: CGFloat = 24, color: Color? = nil, strokeWidth: CGFloat = 2, absoluteStrokeWidth: Bool = false)` - String lookup with fallback
- `init(_ icon: LucideShape, size: CGFloat = 24, color: Color? = nil, strokeWidth: CGFloat = 2, absoluteStrokeWidth: Bool = false)` - From Shape

**Parameters:**
- `size`: Icon size in points (default: 24)
- `color`: Icon color (default: `nil`, inherits from environment foreground color)
- `strokeWidth`: Stroke width multiplier (default: 2)
- `absoluteStrokeWidth`: When true, stroke width stays constant regardless of icon size (default: false)

**LucideShape** - Native SwiftUI Shape
- Conforms to SwiftUI's `Shape` protocol
- Supports all Shape modifiers: `.stroke()`, `.fill()`, `.frame()`, etc.
- Access via `Lucide.house`, `Lucide.settings`, etc.

**LucideIconName** - Type-safe enum
- 1694 enum cases (e.g., `.house`, `.settings`, `.heart`)
- `allCases` array for iteration
- `rawValue` for string access

## Versioning

LucideSwift uses **dual versioning** to track both the library and the upstream Lucide icons:

- **Library Version** (git tags): Independent semantic versioning for the Swift library itself (e.g., `1.0.0`, `1.1.0`)
- **Upstream Version** (`.lucide-version`): Version of the Lucide icons bundled with each release (e.g., `1.7.0`, `1.8.0`)

This allows independent bug fixes and features in the Swift library while still tracking which icon set is included.

### Checking Versions

Access version information programmatically:

```swift
import LucideSwift

print("Library: \(LucideVersions.libraryVersion)")  // e.g., "1.0.0"
print("Icons: \(LucideVersions.lucideVersion)")     // e.g., "1.7.0"
```

### Version Compatibility

- Library versions follow [Semantic Versioning](https://semver.org/)
- Major version bumps indicate breaking API changes
- Minor/patch versions add features or fix bugs without breaking changes
- Icon updates are tracked separately and noted in release notes

## Why This Package?

Other Lucide packages for Swift use image assets (PDFs/PNGs) which can:
- Blur if not configured properly
- Require asset catalog management
- Have larger binary sizes due to multiple resolutions

This package generates pure Swift code from SVG paths:
- **Smaller binary**: Code compresses better than image assets
- **True vectors**: Native SwiftUI rendering at any resolution
- **Type safety**: Compile-time verification prevents runtime icon-not-found errors
- **Better tooling**: Xcode autocomplete shows all 1694 available icons

## Technical Details

- **Library Version**: 1.0.0
- **Lucide Icons**: 1694 icons (v1.7.0)
- **Generated Code**: ~3.3MB of Swift path data
- **Build Time**: Zero impact (generated at package build time)
- **Runtime Memory**: Cached `static let` paths executed exactly once, negligible overhead during view diffing
- **Stroke Scaling**: Configurable via `strokeWidth` and `absoluteStrokeWidth` parameters

## Icon Gallery

Browse all 1694 icons at [lucide.dev/icons](https://lucide.dev/icons)

Names are converted from kebab-case to camelCase:
- `arrow-right` → `.arrowRight`
- `circle-x` → `.circleX`
- `a-arrow-down` → `.aArrowDown`

## License

ISC License (same as Lucide Icons)
