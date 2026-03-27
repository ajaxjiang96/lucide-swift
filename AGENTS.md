# AGENTS.md - Lucide Swift

Guide for agentic coding assistants working in this repository.

## Build & Test Commands

```bash
# Build the project
swift build

# Run all tests
swift test

# Run a single test (replace TestName with actual test name)
swift test --filter LucideSwiftTests/TestName

# Generate/update all icons from upstream Lucide
swift run LucideGenerator

# Build release
swift build -c release

# Clean build artifacts
swift package clean
```

## Code Style Guidelines

### General
- **Language**: Swift 5.9+
- **Platforms**: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+, visionOS 1+
- **No external dependencies** - pure Swift implementation

### File Headers
Every file must include a standard header:
```swift
//
//  Filename.swift
//  LucideSwift
//
//  Brief description of purpose
//
```

### Imports
```swift
import SwiftUI   // For UI components
import Foundation // For non-UI logic
import XCTest     // For tests only
```

### Naming Conventions
- **Types**: PascalCase (e.g., `LucideIcon`, `SVGPathParser`)
- **Methods/Properties**: camelCase (e.g., `pathData`, `normalizedPoint`)
- **Icon names**: camelCase converted from kebab-case (e.g., `arrow-right` → `arrowRight`)
- **Enums**: PascalCase with lowerCamelCase cases
- **Constants**: Static constants in Config structs

### Types & Access Control
- Use `public` for all public API
- Use `internal` (default) for implementation details
- Use `private` for truly internal helpers
- Prefer `struct` over `class` for value semantics
- Use `enum` for command types and error handling

### Error Handling
- Define custom errors in `enum` conforming to `Error`
- Use `throws` for functions that can fail
- Handle errors with `do-catch` blocks
- Print errors with descriptive messages:
  ```swift
  print("❌ Error: \(error)")
  ```

### Documentation
- Use triple-slash (`///`) for public API documentation
- Document parameters and return values
- Include usage examples in doc comments for complex types

### Generated Code
- Files in `Sources/LucideSwift/Lucide+Generated.swift` are AUTO-GENERATED
- Do not edit generated files manually
- Run `swift run LucideGenerator` to regenerate

### Testing
- Tests in `Tests/LucideSwiftTests/`
- Use `@testable import LucideSwift` for internal access
- Test all public API surface
- Include edge cases for parser logic

### Git & Versioning
- Track upstream Lucide version in `.lucide-version`
- Commit messages: concise, imperative mood
- Generated code updates go in separate commits

## Architecture

### Key Components
1. **LucideIconShape**: Shape protocol implementation for SVG rendering
2. **LucideIcon/LucideIconFill**: SwiftUI View wrappers
3. **SVGPathParser**: Converts SVG path strings to Swift Path commands
4. **LucideGenerator**: Fetches icons from upstream and generates Swift code

### SVG Path Commands Supported
- `M/m`: Move to
- `L/l`: Line to
- `H/h`: Horizontal line
- `V/v`: Vertical line
- `C/c`: Cubic bezier curve
- `Z/z`: Close path
- TODO: `Q/q`, `T/t`, `S/s`, `A/a`

### File Structure
```
Sources/
├── LucideSwift/
│   ├── LucideIcon.swift        # SwiftUI components
│   ├── Lucide.swift             # Type-safe icon definitions
│   ├── Lucide+Generated.swift   # Auto-generated icons (DO NOT EDIT)
│   └── SVGPathParser.swift      # SVG parsing logic
└── LucideGenerator/
    └── main.swift               # Code generation tool
```

## Workflow

### Adding New SVG Path Commands
1. Update `SVGPathParser.swift` to handle new command
2. Update `LucideIconShape.path(in:)` to render it
3. Add tests in `LucideSwiftTests.swift`
4. Regenerate icons: `swift run LucideGenerator`

### Syncing with Upstream
The `.github/workflows/sync.yml` runs daily to:
1. Check upstream Lucide releases
2. Run `swift run LucideGenerator`
3. Create PR with updated icons

## Resources
- Lucide Icons: https://lucide.dev
- Upstream repo: https://github.com/lucide-icons/lucide
