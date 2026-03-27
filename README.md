# Lucide Swift

A vector-first, type-safe Swift package for [Lucide Icons](https://lucide.dev).

## Features

- **Vector-first**: SVG paths rendered as Swift Shapes - scales infinitely without pixelation
- **Type-safe**: Compile-time checked icon names with full Xcode autocomplete support
- **Zero dependencies**: Pure Swift implementation
- **Multi-platform**: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+, visionOS 1+
- **Automated sync**: Aligned versioning with upstream Lucide releases

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/lucide-swift.git", from: "1.0.0")
]
```

## Usage

```swift
import LucideSwift
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            // Type-safe icon selection
            LucideIcon(.home)
            LucideIcon(.settings, size: 32, color: .blue)
            
            // As SwiftUI Shape
            Lucide.home
                .stroke(Color.red, lineWidth: 2)
                .frame(width: 40, height: 40)
        }
    }
}
```

## Why Another Lucide Package?

Existing Swift Lucide packages use rasterized PNGs and string-based APIs:
- **Blurriness**: PNGs pixelate at larger sizes
- **No autocomplete**: String-based APIs are error-prone
- **Runtime errors**: Invalid icon names crash at runtime

This package solves both issues by:
1. Converting SVG paths to Swift Shape structs
2. Generating a type-safe enum at build time

## Icon Gallery

Browse all icons at [lucide.dev/icons](https://lucide.dev/icons)

## License

ISC License (same as Lucide Icons)
