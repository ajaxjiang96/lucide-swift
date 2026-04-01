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

/// A view that displays a Lucide icon
public struct LucideIcon: View {
    let iconShape: LucideShape
    @ScaledMetric var size: CGFloat
    var color: Color?
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a LucideShape
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
    
    /// Initialize with an icon name enum case
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
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    /// - Parameters:
    ///   - name: The icon name (e.g., "house", "settings", "heart")
    ///   - size: The icon size (default: 24)
    ///   - color: The icon color (default: nil, inherits from environment)
    ///   - strokeWidth: The stroke width (default: 2)
    ///   - absoluteStrokeWidth: When true, stroke width stays constant regardless of icon size
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
        
        return Group {
            if let color = color {
                iconShape.stroke(color, lineWidth: actualStrokeWidth)
            } else {
                iconShape.stroke(lineWidth: actualStrokeWidth)
            }
        }
        .frame(width: size, height: size)
    }
}

/// A view that displays a filled Lucide icon
public struct LucideIconFill: View {
    let iconShape: LucideShape
    @ScaledMetric var size: CGFloat
    var color: Color?
    
    /// Initialize with a LucideShape
    public init(_ icon: LucideShape, size: CGFloat = 24, color: Color? = nil) {
        self.iconShape = icon
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
    }
    
    /// Initialize with an icon name enum case
    public init(_ iconName: LucideIconName, size: CGFloat = 24, color: Color? = nil) {
        self.iconShape = LucideShape(path: iconName.path)
        self._size = ScaledMetric(wrappedValue: size)
        self.color = color
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    public init(name: String, size: CGFloat = 24, color: Color? = nil) {
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
    }
    
    public var body: some View {
        Group {
            if let color = color {
                iconShape.fill(color)
            } else {
                iconShape.fill()
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
    
    /// Initialize with a LucideLabIconName enum case
    public init(_ iconName: LucideLabIconName, size: CGFloat = 24, color: Color? = nil) {
        self.iconShape = LucideShape(path: iconName.path)
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        LucideIconFill(iconShape, size: size, color: color)
    }
}

// MARK: - Icon Lookup Helpers

extension LucideIconName {
    /// Get an icon shape by name, returns nil if not found
    public static func shape(named name: String) -> LucideShape? {
        guard let iconName = LucideIconName(rawValue: name) else { return nil }
        return LucideShape(path: iconName.path)
    }
    
    /// All available icon names
    public static var allNames: [String] {
        LucideIconName.allCases.map { $0.rawValue }
    }
}

extension LucideLabIconName {
    /// Get a lab icon shape by name, returns nil if not found
    public static func shape(named name: String) -> LucideShape? {
        guard let iconName = LucideLabIconName(rawValue: name) else { return nil }
        return LucideShape(path: iconName.path)
    }
    
    /// All available lab icon names
    public static var allNames: [String] {
        LucideLabIconName.allCases.map { $0.rawValue }
    }
}

// MARK: - Label Extensions

public extension Label where Title == Text, Icon == LucideIcon {
    /// Creates a label with a Lucide icon
    init(_ titleKey: LocalizedStringKey, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with a Lucide Lab icon
    init(_ titleKey: LocalizedStringKey, lucideLab icon: LucideLabIconName, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(LucideShape(path: icon.path), size: size) })
    }
    
    /// Creates a label with a Lucide icon from a string name
    init(_ titleKey: LocalizedStringKey, lucideName iconName: String, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(name: iconName, size: size) })
    }
    
    /// Creates a label with a Lucide icon
    init<S: StringProtocol>(_ title: S, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with a Lucide Lab icon
    init<S: StringProtocol>(_ title: S, lucideLab icon: LucideLabIconName, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(LucideShape(path: icon.path), size: size) })
    }
    
    /// Creates a label with a Lucide icon from a string name
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
                            Label("System Button", lucide: .trash)
                        }
                        .buttonStyle(.borderless)
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
            }
            .padding()
            .frame(width: 600) // Fixed width for screenshot
            .background(Color.white)
    }
}

#Preview {
    LucideGallery()
}
