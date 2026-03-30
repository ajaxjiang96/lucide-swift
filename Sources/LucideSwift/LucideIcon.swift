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
    let iconShape: LucideIconShape
    var size: CGFloat
    var color: Color
    
    /// Initialize with a LucideIconShape
    public init(_ icon: LucideIconShape, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = icon
        self.size = size
        self.color = color
    }
    
    /// Initialize with an icon name enum case
    public init(_ iconName: LucideIconName, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = LucideIconShape(path: iconName.path)
        self.size = size
        self.color = color
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    /// - Parameters:
    ///   - name: The icon name (e.g., "house", "settings", "heart")
    ///   - size: The icon size (default: 24)
    ///   - color: The icon color (default: .primary)
    public init(name: String, size: CGFloat = 24, color: Color = .primary) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideIconShape(path: iconName.path)
        } else {
            // Fallback to house if not found
            self.iconShape = LucideIconShape(path: LucideIconName.house.path)
            #if DEBUG
            print("⚠️ LucideIcon: Icon '\(name)' not found, using fallback")
            #endif
        }
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        iconShape
            .stroke(color, lineWidth: 2)
            .frame(width: size, height: size)
    }
}

/// A view that displays a filled Lucide icon
public struct LucideIconFill: View {
    let iconShape: LucideIconShape
    var size: CGFloat
    var color: Color
    
    /// Initialize with a LucideIconShape
    public init(_ icon: LucideIconShape, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = icon
        self.size = size
        self.color = color
    }
    
    /// Initialize with an icon name enum case
    public init(_ iconName: LucideIconName, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = LucideIconShape(path: iconName.path)
        self.size = size
        self.color = color
    }
    
    /// Initialize with a string icon name (type-safe lookup with fallback)
    public init(name: String, size: CGFloat = 24, color: Color = .primary) {
        if let iconName = LucideIconName(rawValue: name) {
            self.iconShape = LucideIconShape(path: iconName.path)
        } else {
            self.iconShape = LucideIconShape(path: LucideIconName.house.path)
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
    public static func shape(named name: String) -> LucideIconShape? {
        guard let iconName = LucideIconName(rawValue: name) else { return nil }
        return LucideIconShape(path: iconName.path)
    }
    
    /// All available icon names
    public static var allNames: [String] {
        LucideIconName.allCases.map { $0.rawValue }
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            // Old way (still works)
            LucideIcon(Lucide.house, size: 24)
            
            // New ways:
            // Enum case directly
            LucideIcon(.settings, size: 32, color: .blue)
            
            // String name
            LucideIcon(name: "heart", size: 40, color: .red)
            
            // String name with explicit parameter
            LucideIcon(name: "star", size: 28, color: .orange)
        }
        
        HStack(spacing: 20) {
            LucideIconFill(.star, size: 24, color: .yellow)
            LucideIconFill(name: "circle-x", size: 32, color: .green)
        }
    }
    .padding()
}
