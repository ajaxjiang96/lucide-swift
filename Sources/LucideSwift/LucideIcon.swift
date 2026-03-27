//
//  LucideIcon.swift
//  LucideSwift
//
//  Main SwiftUI component for displaying Lucide icons
//

import SwiftUI

/// A view that displays a Lucide icon
public struct LucideIcon: View {
    let iconShape: LucideIconShape
    var size: CGFloat
    var color: Color
    
    public init(_ icon: LucideIconShape, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = icon
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
    
    public init(_ icon: LucideIconShape, size: CGFloat = 24, color: Color = .primary) {
        self.iconShape = icon
        self.size = size
        self.color = color
    }
    
    public var body: some View {
        iconShape
            .fill(color)
            .frame(width: size, height: size)
    }
}

#Preview {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            LucideIcon(Lucide.home, size: 24)
            LucideIcon(Lucide.settings, size: 32, color: .blue)
            LucideIcon(Lucide.heart, size: 40, color: .red)
        }
        
        HStack(spacing: 20) {
            LucideIconFill(Lucide.star, size: 24, color: .yellow)
            LucideIconFill(Lucide.circle, size: 32, color: .green)
        }
    }
    .padding()
}
