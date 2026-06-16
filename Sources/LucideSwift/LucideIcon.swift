//
//  LucideIcon.swift
//  LucideSwift
//
//  Main SwiftUI component for displaying Lucide icons
//

import SwiftUI

/// The rendering style for a Lucide icon.
public enum LucideIconStyle: Sendable {
    /// Stroke-only rendering — the standard Lucide look.
    case stroked
    /// **Experimental.** Filled rendering: closed paths are filled, open paths are stroked.
    ///
    /// > Important: Lucide icons are designed as stroke-based line art. Fills are
    /// > [not officially supported](https://lucide.dev/guide/design/icon-properties)
    /// > by Lucide. Filled rendering may produce visual artifacts on icons with
    /// > complex or open paths. Use with caution.
    case filled
}

// MARK: - Icon Resolution

private func resolveShape(named name: String, caller: String = "LucideIcon") -> LucideShape {
    if let iconName = LucideIconName(rawValue: name) {
        return iconName.shape
    } else if let labIconName = LucideLabIconName(rawValue: name) {
        return labIconName.shape
    }
    #if DEBUG
    print("⚠️ \(caller): Icon '\(name)' not found in regular or lab sets, using fallback")
    #endif
    return LucideIconName.house.shape
}

// MARK: - LucideIcon

/// A SwiftUI view that displays a Lucide icon.
///
/// `LucideIcon` is the primary way to display icons in your app. It provides
/// high-level controls for sizing, coloring, and stroke width, and supports
/// both regular and experimental (Lab) icons through a unified interface.
///
/// ### Example
/// ```swift
/// // Stroked (default)
/// LucideIcon(.house, size: 32, color: .blue, strokeWidth: 1.5)
///
/// // Filled
/// LucideIcon(.star, style: .filled, color: .yellow)
///
/// // Lab icons — explicit lab: label
/// LucideIcon(lab: .broom, color: .purple)
///
/// // From a Shape
/// LucideIcon(Lucide.settings)
///
/// // From a string
/// LucideIcon(name: "house")
/// ```
public struct LucideIcon: View {
    let iconShape: LucideShape
    @ScaledMetric var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    var style: LucideIconStyle

    /// Initialize with a ``LucideShape``.
    /// - Parameters:
    ///   - shape: The icon shape to display.
    ///   - style: The rendering style — `.stroked` (default) or `.filled`.
    ///   - size: The base size of the icon in points (default 24).
    ///   - color: The color of the icon (default nil, inherits from environment).
    ///   - strokeWidth: The stroke width in points (default 2).
    ///   - absoluteStrokeWidth: If true, stroke width remains constant regardless of size.
    public init(
        shape: LucideShape,
        style: LucideIconStyle = .stroked,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = shape
        self.style = style
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }

    /// Initialize with a ``LucideIconName`` enum case.
    public init(
        _ iconName: LucideIconName,
        style: LucideIconStyle = .stroked,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.init(shape: iconName.shape, style: style, size: size, color: color, strokeWidth: strokeWidth, absoluteStrokeWidth: absoluteStrokeWidth)
    }

    /// Initialize with a ``LucideLabIconName`` enum case.
    /// Use this to explicitly render a lab (experimental) icon.
    public init(
        lab iconName: LucideLabIconName,
        style: LucideIconStyle = .stroked,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.init(shape: iconName.shape, style: style, size: size, color: color, strokeWidth: strokeWidth, absoluteStrokeWidth: absoluteStrokeWidth)
    }

    /// Initialize with a string icon name (looks up across regular and lab sets).
    /// - Parameters:
    ///   - name: The icon name (e.g., "house", "settings", "broom").
    ///   - style: The rendering style — `.stroked` (default) or `.filled`.
    ///   - size: The icon size (default: 24).
    ///   - color: The icon color (default: nil, inherits from environment).
    ///   - strokeWidth: The stroke width (default: 2).
    ///   - absoluteStrokeWidth: When true, stroke width stays constant regardless of icon size.
    public init(
        name: String,
        style: LucideIconStyle = .stroked,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.init(shape: resolveShape(named: name), style: style, size: size, color: color, strokeWidth: strokeWidth, absoluteStrokeWidth: absoluteStrokeWidth)
    }

    public var body: some View {
        let actualStrokeWidth: CGFloat = absoluteStrokeWidth ? strokeWidth : strokeWidth * (size / 24)
        let strokeStyle = StrokeStyle(lineWidth: actualStrokeWidth, lineCap: .round, lineJoin: .round)
        let fillStyle = FillStyle(eoFill: true)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)

        // For filled style, stroke only the open subpaths; for stroked style, stroke the full path.
        let strokePath = style == .filled ? iconShape.openPath(in: rect) : iconShape.path(in: rect)

        return ZStack {
            if style == .filled {
                if let color = color {
                    iconShape.closedPath(in: rect).fill(color, style: fillStyle)
                } else {
                    iconShape.closedPath(in: rect).fill(style: fillStyle)
                }
            }
            if let color = color {
                strokePath.stroke(color, style: strokeStyle)
            } else {
                strokePath.stroke(style: strokeStyle)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Icon Lookup Helpers

extension LucideIconName {
    /// Returns the ``LucideShape`` for the given icon name.
    /// - Parameter name: The raw name of the icon.
    /// - Returns: A ``LucideShape`` if found, otherwise `nil`.
    public static func shape(named name: String) -> LucideShape? {
        guard let iconName = LucideIconName(rawValue: name) else { return nil }
        return iconName.shape
    }

    /// A list of all available icon names in the regular set.
    public static var allNames: [String] {
        LucideIconName.allCases.map { $0.rawValue }
    }
}

extension LucideLabIconName {
    /// Returns the ``LucideShape`` for the given experimental lab icon name.
    public static func shape(named name: String) -> LucideShape? {
        guard let iconName = LucideLabIconName(rawValue: name) else { return nil }
        return iconName.shape
    }

    /// A list of all available icon names in the experimental lab set.
    public static var allNames: [String] {
        LucideLabIconName.allCases.map { $0.rawValue }
    }
}

// MARK: - Label Extensions

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public extension Label where Title == Text, Icon == LucideIcon {
    /// Creates a label with a Lucide icon from a shape.
    init(_ titleKey: LocalizedStringKey, lucide shape: LucideShape, style: LucideIconStyle = .stroked, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(shape: shape, style: style, size: size) })
    }

    /// Creates a label with a Lucide icon from a shape using a title string.
    init<S: StringProtocol>(_ title: S, lucide shape: LucideShape, style: LucideIconStyle = .stroked, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(shape: shape, style: style, size: size) })
    }

    /// Creates a label with a Lucide icon from a ``LucideIconName`` case (shorthand convenience).
    init(_ titleKey: LocalizedStringKey, lucide iconName: LucideIconName, style: LucideIconStyle = .stroked, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(iconName, style: style, size: size) })
    }

    /// Creates a label with a Lucide icon from a ``LucideIconName`` case using a title string.
    init<S: StringProtocol>(_ title: S, lucide iconName: LucideIconName, style: LucideIconStyle = .stroked, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(iconName, style: style, size: size) })
    }
}
