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

/// A view that displays a Lucide icon
public struct LucideIcon: View {
    let iconShape: LucideShape
    var size: CGFloat
    var color: Color
    var strokeWidth: CGFloat
    var absoluteStrokeWidth: Bool
    
    /// Initialize with a LucideShape
    public init(
        _ icon: LucideShape,
        size: CGFloat = 24,
        color: Color = .primary,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = icon
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with an icon name enum case
    public init(
        _ iconName: LucideIconName,
        size: CGFloat = 24,
        color: Color = .primary,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        self.iconShape = LucideShape(path: iconName.path)
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    /// - Parameters:
    ///   - name: The icon name (e.g., "house", "settings", "heart")
    ///   - size: The icon size (default: 24)
    ///   - color: The icon color (default: .primary)
    ///   - strokeWidth: The stroke width (default: 2)
    ///   - absoluteStrokeWidth: When true, stroke width stays constant regardless of icon size
    public init(
        name: String,
        size: CGFloat = 24,
        color: Color = .primary,
        strokeWidth: CGFloat = 2,
        absoluteStrokeWidth: Bool = false
    ) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideShape(path: iconName.path)
        } else {
            // Fallback to house if not found
            self.iconShape = LucideShape(path: LucideIconName.house.path)
            #if DEBUG
            print("⚠️ LucideIcon: Icon '\(name)' not found, using fallback")
            #endif
        }
        self.size = size
        self.color = color
        self.strokeWidth = strokeWidth
        self.absoluteStrokeWidth = absoluteStrokeWidth
    }
    
    public var body: some View {
        // Calculate stroke width based on absoluteStrokeWidth setting
        // Lucide icons are designed for 24x24 viewBox
        let actualStrokeWidth: CGFloat
        if absoluteStrokeWidth {
            // Keep stroke width constant regardless of icon size
            actualStrokeWidth = strokeWidth
        } else {
            // Scale stroke width proportionally with icon size
            actualStrokeWidth = strokeWidth * (size / 24)
        }
        
        return iconShape
            .stroke(color, lineWidth: actualStrokeWidth)
            .frame(width: size, height: size)
    }
}

/// A view that displays a filled Lucide icon
public struct LucideIconFill: View {
    let iconShape: LucideShape
    var size: CGFloat
    var color: Color
    
    /// Initialize with a LucideShape
    public init(_ icon: LucideShape, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = icon
        self.size = size
        self.color = color
    }
    
    /// Initialize with an icon name enum case
    public init(_ iconName: LucideIconName, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = LucideShape(path: iconName.path)
        self.size = size
        self.color = color
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    public init(name: String, size: CGFloat = 24, color: Color = .primary) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideShape(path: iconName.path)
        } else {
            self.iconShape = LucideShape(path: LucideIconName.house.path)
            #if DEBUG
            print("⚠️ LucideIconFill: Icon '\(name)' not found, using fallback")
            #endif
        }
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        iconShape
            .fill(color)
            .frame(width: size, height: size)
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

// MARK: - Label Extensions

public extension Label where Title == Text, Icon == LucideIcon {
    /// Creates a label with a Lucide icon
    /// - Parameters:
    ///   - titleKey: The title key for the label
    ///   - icon: The Lucide icon name
    ///   - size: The icon size (default: 24)
    init(_ titleKey: LocalizedStringKey, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with a Lucide icon from a string name
    /// - Parameters:
    ///   - titleKey: The title key for the label
    ///   - iconName: The Lucide icon name (e.g., "settings", "house")
    ///   - size: The icon size (default: 24)
    init(_ titleKey: LocalizedStringKey, lucideName iconName: String, size: CGFloat = 24) {
        self.init(title: { Text(titleKey) }, icon: { LucideIcon(name: iconName, size: size) })
    }
    
    /// Creates a label with a Lucide icon
    /// - Parameters:
    ///   - title: The title string for the label
    ///   - icon: The Lucide icon name
    ///   - size: The icon size (default: 24)
    init<S: StringProtocol>(_ title: S, lucide icon: LucideIconName, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(icon, size: size) })
    }
    
    /// Creates a label with a Lucide icon from a string name
    /// - Parameters:
    ///   - title: The title string for the label
    ///   - iconName: The Lucide icon name (e.g., "settings", "house")
    ///   - size: The icon size (default: 24)
    init<S: StringProtocol>(_ title: S, lucideName iconName: String, size: CGFloat = 24) {
        self.init(title: { Text(title) }, icon: { LucideIcon(name: iconName, size: size) })
    }
}

#Preview {
    ScrollView {
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
                        LucideIcon(.house, size: 32, color: .indigo)
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
                    LucideIconFill(name: "circle-check", size: 32, color: .green)
                }
            }
            
            // 6. Label Integration
            VStack(spacing: 12) {
                Text("Label Integration").font(.headline)
                VStack(alignment: .leading, spacing: 10) {
                    Label("Default Label", lucide: .info)
                    Label("Large Blue Label", lucide: .cloudRain, size: 32)
                        .foregroundColor(.blue)
                    
                    Button(action: {}) {
                        Label("System Button", lucide: .trash)
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding()
    }
}
