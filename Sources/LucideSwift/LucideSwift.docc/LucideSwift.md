# ``LucideSwift``

Beautiful & consistent icons, made for SwiftUI.

## Overview

LucideSwift is a collection of 2,112+ high-quality, open-source icons for SwiftUI (1,738 regular + 374 Lab). It is a Swift implementation of the [Lucide](https://lucide.dev) icon set, providing type-safe, performant, and flexible icon components.

### Key Features

- **Type-safe:** Every icon is an enum case, preventing typos and ensuring they exist at compile time.
- **Pure SwiftUI:** Icons are implemented as native `Shape` and `View` components.
- **Zero Runtime Dependencies:** Icons are pre-generated into Swift code for maximum performance.
- **Customizable:** Easily adjust size, color, stroke width, and scaling behavior.
- **Filled Icons:** Experimental support for filled rendering via a `style:` parameter. See ``LucideIconStyle/filled`` for caveats.

## Getting Started

To display an icon, use the `LucideIcon` view:

```swift
import SwiftUI
import LucideSwift

struct ContentView: View {
    var body: some View {
        LucideIcon(.house, size: 24, color: .blue)
    }
}
```

## Topics

### Core Components

- ``LucideIcon``
- ``LucideShape``

### Icon Sets

- ``LucideIconName``
- ``LucideLabIconName``

### Extensions

- ``SwiftUI/Label``
