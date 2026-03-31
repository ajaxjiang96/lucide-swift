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
    VStack(spacing: 30) {
        // Show stroke width scaling with different sizes
        VStack(spacing: 10) {
            Text("Stroke width scales with size (default)").font(.caption)
            HStack(spacing: 20) {
                LucideIcon(.heart, size: 16, color: .red)
                LucideIcon(.heart, size: 24, color: .red)
                LucideIcon(.heart, size: 32, color: .red)
                LucideIcon(.heart, size: 48, color: .red)
                LucideIcon(.heart, size: 64, color: .red)
            }
        }
        
        // Show absolute stroke width
        VStack(spacing: 10) {
            Text("Absolute stroke width (2px at all sizes)").font(.caption)
            HStack(spacing: 20) {
                LucideIcon(.heart, size: 16, color: .blue, absoluteStrokeWidth: true)
                LucideIcon(.heart, size: 24, color: .blue, absoluteStrokeWidth: true)
                LucideIcon(.heart, size: 32, color: .blue, absoluteStrokeWidth: true)
                LucideIcon(.heart, size: 48, color: .blue, absoluteStrokeWidth: true)
                LucideIcon(.heart, size: 64, color: .blue, absoluteStrokeWidth: true)
            }
        }
        
        // Show different stroke widths
        VStack(spacing: 10) {
            Text("Different stroke widths").font(.caption)
            HStack(spacing: 20) {
                LucideIcon(.heart, size: 48, color: .green, strokeWidth: 1)
                LucideIcon(.heart, size: 48, color: .green, strokeWidth: 2)
                LucideIcon(.heart, size: 48, color: .green, strokeWidth: 3)
            }
        }
        
        // Different initialization methods
        HStack(spacing: 20) {
            // Old way (still works)
            LucideIcon(Lucide.house, size: 24)
            
            // Enum case directly
            LucideIcon(.settings, size: 32, color: .blue)
            
            // String name
            LucideIcon(name: "star", size: 40, color: .orange)
        }
        
        HStack(spacing: 20) {
            LucideIconFill(.star, size: 24, color: .yellow)
            LucideIconFill(name: "circle-x", size: 32, color: .green)
        }
        
        // Label usage for buttons/toolbar items
        VStack(spacing: 10) {
            Text("Label usage (for Buttons, Toolbar)").font(.caption)
            
            // Using enum
            Label("Settings", lucide: .settings)
            
            // Using string name
            Label("Home", lucideName: "house")
            
            // In a Button
            Button(action: {}) {
                Label("Save", lucide: .save)
            }
        }
    }
    .padding()
}
