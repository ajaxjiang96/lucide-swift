//
//  LucideIcon.swift
//  LucideSwift
//
//  Main SwiftUI component for displaying Lucide icons
//

import SwiftUI

/// Error thrown when an invalid icon name is provided
public enum LucideIconError: Error {
    case iconNotFound(String)
}

// MARK: - Regular Icons

/// A SwiftUI view that displays a Lucide icon.
///
/// `LucideIcon` is the primary way to display icons in your app. It provides
/// high-level controls for sizing, coloring, and stroke width.
///
/// ### Example
/// ```swift
/// LucideIcon(.house, size: 32, color: .blue, strokeWidth: 1.5)
/// ```
public struct LucideIcon: View {
    let iconShape: LucideShape
    @ScaledMetric var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a ``LucideShape``.
    /// - Parameters:
    ///   - icon: The icon shape to display.
    ///   - size: The base size of the icon in points (default 24).
    ///   - color: The color of the icon (default nil, inherits from environment).
    ///   - strokeWidth: The stroke width in points (default 2).
    ///   - absoluteStrokeWidth: If true, stroke width remains constant regardless of size.
    public init(
        _ icon: LucideShape,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = icon
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with a ``LucideIconName`` enum case.
    public init(
        _ iconName: LucideIconName,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = LucideShape(path: iconName.path)
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback).
    /// - Parameters:
    ///   - name: The icon name (e.g., "house", "settings", "heart").
    ///   - size: The icon size (default: 24).
    ///   - color: The icon color (default: nil, inherits from environment).
    ///   - strokeWidth: The stroke width (default: 2).
    ///   - absoluteStrokeWidth: When true, stroke width stays constant regardless of icon size.
    public init(
        name: String,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideShape(path: iconName.path)
        } else if let labIconName = LucideLabIconName(rawValue: name) {
            self.iconShape = LucideShape(path: labIconName.path)
        } else {
            // Fallback to house if not found
            self.iconShape = LucideShape(path: LucideIconName.house.path)
            #if DEBUG
            print("⚠️ LucideIcon: Icon '\(name)' not found in regular or lab sets, using fallback")
            #endif
        }
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    public var body: some View {
        let actualStrokeWidth: CGFloat = absoluteStrokeWidth ? strokeWidth : strokeWidth * (size / 24)
        let style = StrokeStyle(lineWidth: actualStrokeWidth, lineCap: .round, lineJoin: .round)
        
        return Group {
            if let color = color {
                iconShape.stroke(color, style: style)
            } else {
                iconShape.stroke(style: style)
            }
        }
        .frame(width: size, height: size)
    }
}

/// A SwiftUI view that displays a filled Lucide icon.
///
/// `LucideIconFill` renders closed areas of the icon with a solid fill,
/// while keeping decorative lines as strokes.
///
/// ### Example
/// ```swift
/// LucideIconFill(.star, color: .yellow)
/// ```
public struct LucideIconFill: View {
    let iconShape: LucideShape
    @ScaledMetric var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a ``LucideShape``.
    public init(
        _ icon: LucideShape,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = icon
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with a ``LucideIconName`` enum case.
    public init(
        _ iconName: LucideIconName,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = LucideShape(path: iconName.path)
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback).
    public init(
        name: String,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideShape(path: iconName.path)
        } else if let labIconName = LucideLabIconName(rawValue: name) {
            self.iconShape = LucideShape(path: labIconName.path)
        } else {
            self.iconShape = LucideShape(path: LucideIconName.house.path)
            #if DEBUG
            print("⚠️ LucideIconFill: Icon '\(name)' not found in regular or lab sets, using fallback")
            #endif
        }
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    public var body: some View {
        let actualStrokeWidth: CGFloat = absoluteStrokeWidth ? strokeWidth : strokeWidth * (size / 24)
        let strokeStyle = StrokeStyle(lineWidth: actualStrokeWidth, lineCap: .round, lineJoin: .round)
        let fillStyle = FillStyle(eoFill: true)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        return ZStack {
            if let color = color {
                iconShape.closedPath(in: rect).fill(color, style: fillStyle)
                iconShape.openPath(in: rect).stroke(color, style: strokeStyle)
            } else {
                iconShape.closedPath(in: rect).fill(style: fillStyle)
                iconShape.openPath(in: rect).stroke(style: strokeStyle)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Lab Icons

/// A view that displays an experimental Lucide Lab icon
public struct LucideLabIcon: View {
    let iconShape: LucideShape
    var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a LucideLabIconName enum case
    public init(
        _ iconName: LucideLabIconName,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = LucideShape(path: iconName.path)
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    public var body: some View {
        LucideIcon(iconShape, size: size, color: color, strokeWidth: strokeWidth, absoluteStrokeWidth: absoluteStrokeWidth)
    }
}

/// A view that displays a filled experimental Lucide Lab icon
public struct LucideLabIconFill: View {
    let iconShape: LucideShape
    var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a LucideLabIconName enum case
    public init(
        _ iconName: LucideLabIconName,
        size: CGFloat = 24,
        color: Color? = nil,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = LucideShape(path: iconName.path)
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    public var body: some View {
        LucideIconFill(iconShape, size: size, color: color, strokeWidth: strokeWidth, absoluteStrokeWidth: absoluteStrokeWidth)
    }
}

// MARK: - Icon Lookup Helpers

extension LucideIconName {
    /// Returns the ``LucideShape`` for the given icon name.
    /// - Parameter name: The raw name of the icon.
    /// - Returns: A ``LucideShape`` if found, otherwise `nil`.
    public static func shape(named name: String) -> LucideShape? {
        guard let iconName = LucideIconName(rawValue: name) else { return nil }
        return LucideShape(path: iconName.path)
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
        return LucideShape(path: iconName.path)
    }
    
    /// A list of all available icon names in the experimental lab set.
    public static var allNames: [String] {
        LucideLabIconName.allCases.map { $0.rawValue }
    }
}

// MARK: - Label Extensions

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, visionOS 1.0, *)
public extension Label where Title == Text, Icon == LucideIcon {
    /// Creates a label with a Lucide icon.
    /// - Parameters:
    ///   - titleKey: A key for the localized title.
    ///   - icon: The Lucide icon to display.
    ///   - size: The size of the icon (default 24).
    init(_ titleKey: LocalizedStringKey, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with an experimental Lucide Lab icon.
    init(_ titleKey: LocalizedStringKey, lucideLab icon: LucideLabIconName, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(LucideShape(path: icon.path), size: size) })
    }
    
    /// Creates a label with a Lucide icon from its string name.
    init(_ titleKey: LocalizedStringKey, lucideName iconName: String, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(name: iconName, size: size) })
    }
    
    /// Creates a label with a Lucide icon using a title string.
    init<S: StringProtocol>(_ title: S, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with an experimental Lucide Lab icon using a title string.
    init<S: StringProtocol>(_ title: S, lucideLab icon: LucideLabIconName, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(LucideShape(path: icon.path), size: size) })
    }
    
    /// Creates a label with a Lucide icon from its string name using a title string.
    init<S: StringProtocol>(_ title: S, lucideName iconName: String, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(name: iconName, size: size) })
    }
}

public struct LucideGallery: View {
    public init() {}
    public var body: some View {
        VStack(spacing: 40) {
            // 1. Stroke Width Scaling (Default)
                VStack(spacing: 12) {
                    Text("Proportional Stroke (Default)").font(.headline)
                    Text("Stroke width scales with icon size (2px at 24pt)").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        ForEach([16, 24, 32, 48, 64], id: \.self) { size in
                            VStack {
                                LucideIcon(.heart, size: CGFloat(size), color: .red)
                                Text("\(size)pt").font(.system(size: 8, design: .monospaced))
                            }
                        }
                    }
                }
                
                // 2. Absolute Stroke Width
                VStack(spacing: 12) {
                    Text("Absolute Stroke Width").font(.headline)
                    Text("Stroke width stays constant at 2px regardless of size").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        ForEach([16, 24, 32, 48, 64], id: \.self) { size in
                            VStack {
                                LucideIcon(.heart, size: CGFloat(size), color: .blue, absoluteStrokeWidth: true)
                                Text("\(size)pt").font(.system(size: 8, design: .monospaced))
                            }
                        }
                    }
                }
                
                // 3. Custom Stroke Widths
                VStack(spacing: 12) {
                    Text("Custom Stroke Widths").font(.headline)
                    Text("Adjusting the strokeWidth parameter (at 48pt size)").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 30) {
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 0.5)
                            Text("0.5").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 1.0)
                            Text("1.0").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 2.0)
                            Text("2.0 (Def)").font(.caption2)
                        }
                        VStack {
                            LucideIcon(.heart, size: 48, color: .green, strokeWidth: 3.0)
                            Text("3.0").font(.caption2)
                        }
                    }
                }
                
                // 4. Initialization Methods & Colors
                VStack(spacing: 12) {
                    Text("Initialization & Colors").font(.headline)
                    HStack(spacing: 25) {
                        VStack {
                            LucideIcon(.house, size: 32, color: .blue)
                            Text("Enum").font(.caption2)
                        }
                        VStack {
                            LucideIcon(name: "settings", size: 32, color: .orange)
                            Text("String").font(.caption2)
                        }
                        VStack {
                            LucideIcon(Lucide.star, size: 32, color: .yellow)
                            Text("Shape").font(.caption2)
                        }
                    }
                }
                
                // 5. Filled Icons
                VStack(spacing: 12) {
                    Text("Filled Icons").font(.headline)
                    HStack(spacing: 25) {
                        LucideIconFill(.star, size: 32, color: .yellow)
                        LucideIconFill(.heart, size: 32, color: .red)
                        LucideIconFill(.bell, size: 32, color: .blue)
                        LucideIconFill(name: "circleCheck", size: 32, color: .green)
                    }
                }
                
                // 6. Label Integration
                VStack(spacing: 12) {
                    Text("Label Integration").font(.headline)
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Default Label", lucide: .info)
                        Label("Lab Label", lucideLab: .broom)
                            .foregroundColor(.purple)
                        
                        Button(action: {}) {
                            HStack {
                                LucideIcon(.trash)
                                Text("System Button")
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }

                // 7. Lab Icons Integration (Experimental)
                VStack(spacing: 12) {
                    Text("Lucide Lab (Experimental)").font(.headline)
                    Text("Experimental icons from the lab repository").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        VStack {
                            LucideLabIcon(.broom, size: 32, color: .purple)
                            Text("broom").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.avocado, size: 32, color: .green)
                            Text("avocado").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.cactus, size: 32, color: .green)
                            Text("cactus").font(.caption2)
                        }
                        VStack {
                            LucideLabIcon(.burger, size: 32, color: .orange)
                            Text("burger").font(.caption2)
                        }
                    }
                }
                
                // 8. SwiftUI Image Extension
                VStack(spacing: 12) {
                    Text("SwiftUI Image Extension").font(.headline)
                    Text("Directly use as Image for modifiers like .resizable()").font(.caption).foregroundColor(.secondary)
                    HStack(spacing: 20) {
                        Image(lucide: .house, size: CGSize(width: 32, height: 32))
                            .foregroundColor(.blue)
                        
                        Image(lucideFill: .heart, size: CGSize(width: 32, height: 32))
                            .foregroundColor(.red)
                        
                        Image(lucide: .settings, size: CGSize(width: 32, height: 32))
                            .resizable()
                            .frame(width: 48, height: 48)
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding()
            .frame(width: 600) // Fixed width for screenshot
            .background(Color.white)
    }
}

#if DEBUG
#Preview {
    LucideGallery()
}
#endif
