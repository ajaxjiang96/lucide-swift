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
swift run --package-path Tools LucideGenerator

# Build release
swift build -c release

# Clean build artifacts
swift package clean
```

## Code Style Guidelines

### General
- **Language**: Swift 5.9+
- **Platforms**: iOS 14+, macOS 11+, tvOS 14+, watchOS 7+, visionOS 1+
- **Zero runtime dependencies** - pure Swift implementation (generator tool uses SVGPath)

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
- **Icon names**: camelCase converted from kebab-case (e.g., `arrow-right` → `arrowRight`) to align with Swift API Design Guidelines.
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
- Run `swift run --package-path Tools LucideGenerator` to regenerate

### Testing
- Tests in `Tests/LucideSwiftTests/`
- Use `@testable import LucideSwift` for internal access
- Test all public API surface
- Include edge cases for parser logic

### Git & Versioning
- Track library version in `.library-version` (auto-increments patch on icon sync)
- Track upstream Lucide version in `.lucide-version`
- Commit messages: concise, imperative mood
- Generated code updates go in separate commits
- **IMPORTANT: You are not allowed to commit until explicitly instructed to do so. If you find the current working directory worth committing before proceeding, let the user know and wait for a decision.**

## Architecture

### Key Components
1. **LucideShape**: Shape protocol implementation for SVG rendering.
2. **LucideIcon**: SwiftUI View wrapper for all icons — supports `.stroked` and `.filled` styles via `LucideIconStyle`, and handles both regular and Lab icons through a unified interface.
3. **LucideGenerator**: Fetches icons from both `lucide` and `lucide-lab` repositories and generates Swift code.

### SVG Path Commands Supported
- `M/m`: Move to
- `L/l`: Line to
- `H/h`: Horizontal line
- `V/v`: Vertical line
- `C/c`: Cubic bezier curve
- `Z/z`: Close path
- `Q/q`: Quadratic bezier curve (supported via conversion)
- `T/t`: Smooth quadratic curve (supported via conversion)
- `S/s`: Smooth cubic curve (supported via conversion)
- `A/a`: Elliptical arc (supported via conversion)

### File Structure
```
Sources/
├── LucideSwift/
│   ├── LucideIcon.swift        # Unified icon View + Label extensions
│   ├── Lucide.swift             # LucideShape definition
│   ├── Image+Lucide.swift       # Image extensions for rasterized icons
│   ├── Lucide+Generated.swift   # Auto-generated icons (DO NOT EDIT)
└── LucideGenerator/
    ├── main.swift               # Code generation tool
    └── SVGPathParser.swift      # SVG parsing logic
```

## Workflow

### Versioning Strategy
- **Dual versioning**: Library version is independent from upstream Lucide version
- **Library Version**: Tracked in `.library-version` file (e.g., `0.1.0`), auto-increments patch on icon updates
- **Upstream Version**: Tracked in `.lucide-version` (e.g., `1.7.0`)
- **Lab Version**: Tracked in `.lucide-lab-version`
- Access programmatically via `LucideVersions`


### Auto Sync and Release
The `.github/workflows/sync-and-release.yml` runs daily to:
1. Check upstream Lucide releases
2. If new version available:
   - Run `swift run --package-path Tools LucideGenerator`
   - Auto-increment patch version in `.library-version` (e.g., 0.1.0 → 0.1.1)
   - Commit generated files
   - Create git tag and GitHub release
3. If no update: skip silently

### Manual Major/Minor Releases
For breaking changes or new features:
1. Manually update `.library-version` (e.g., 0.1.5 → 0.2.0)
2. Commit the change
3. Create tag manually: `git tag -a 0.2.0 -m "Release 0.2.0"`
4. Push tag: `git push origin 0.2.0`
5. GitHub release is created automatically by the workflow

## Resources
- Lucide Icons: https://lucide.dev
- Upstream repo: https://github.com/lucide-icons/lucide
b.com/lucide-icons/lucide
