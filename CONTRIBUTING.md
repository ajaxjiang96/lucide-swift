# Contributing to LucideSwift

Thanks for contributing! Here's how to get started.

## Development Setup

```bash
git clone https://github.com/ajaxjiang96/lucide-swift.git
cd lucide-swift
swift build
swift test
```

## Pull Request Process

1. Fork the repository and create a feature branch.
2. Ensure your change builds: `swift build`
3. Run tests: `swift test`
4. If you're adding or modifying SVG parsing, add tests in `Tools/Tests/LucideGeneratorTests/`.
5. If you're adding new icon-related features, add tests in `Tests/LucideSwiftTests/`.
6. Update documentation if the public API changes.

## Code Style

- Follow the existing style in the repository (see [AGENTS.md](AGENTS.md)).
- Every file must include a standard header comment.
- Use `public` for public API, `internal` for implementation details, `private` for helpers.
- Prefer `struct` over `class` for value semantics.
- Define custom errors in `enum` conforming to `Error`.
- Use triple-slash (`///`) for public API documentation.

## Generated Code

**Do not edit** files under `Sources/LucideSwift/Icons/` or `Sources/LucideSwift/Lucide+Generated.swift`. These are auto-generated. Run `swift run --package-path Tools LucideGenerator` to regenerate.

## Reporting Issues

- Search existing issues first.
- Include your Swift version, platform, and a minimal reproduction case.
- For icon-specific issues, check if the issue exists upstream at [lucide-icons/lucide](https://github.com/lucide-icons/lucide) first.

## License

By contributing, you agree that your contributions will be licensed under the ISC License.
