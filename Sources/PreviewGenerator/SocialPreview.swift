//
//  SocialPreview.swift
//  PreviewGenerator
//
//  Social media preview and README header banner generator.
//  Renders a tilted grid of icon tiles.
//

import SwiftUI
import LucideSwift

/// Configurable icon-grid preview — grid, tilted, with centered branding.
public struct SocialPreview: View {
    private let icons: [LucideIconName]
    private let columns: Int
    private let rows: Int
    private let tiltDegrees: Double = 6
    private let iconSize: CGFloat = 48
    private let cellSize: CGFloat = 56

    private let canvasWidth: CGFloat
    private let canvasHeight: CGFloat
    private let showText: Bool

    public init(width: CGFloat, height: CGFloat, showText: Bool = true) {
        self.canvasWidth = width
        self.canvasHeight = height
        self.showText = showText

        let overflowW = width * 1.6
        let overflowH = height * 1.9
        self.columns = max(Int(overflowW / cellSize), 1)
        self.rows = max(Int(overflowH / cellSize), 1)

        let all = LucideIconName.allCases
        let count = all.count
        var filled: [LucideIconName] = []
        filled.reserveCapacity(columns * rows)
        for i in 0..<(columns * rows) {
            filled.append(all[i % count])
        }
        self.icons = filled
    }

    public var body: some View {
        ZStack {
            Color.white

            gridView
                .rotationEffect(.degrees(tiltDegrees))
                .frame(width: canvasWidth * 1.6, height: canvasHeight * 1.9)
                .clipped()

            if showText {
                brandingText
            }
        }
        .frame(width: canvasWidth, height: canvasHeight)
    }

    // MARK: - Grid

    private var gridView: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<columns, id: \.self) { col in
                        let idx = row * columns + col
                        if idx < icons.count {
                            LucideIcon(icons[idx], size: iconSize, color: Color(white: 0.85))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Branding

    private var brandingText: some View {
        let titleSize = canvasHeight * 0.14
        let subtitleSize = canvasHeight * 0.05

        return VStack(spacing: canvasHeight * 0.02) {
            Spacer()
            Text("Lucide Swift")
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .foregroundColor(.black)
            Text("Native SwiftUI Shapes · Zero dependencies")
                .font(.system(size: subtitleSize, weight: .medium, design: .rounded))
                .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, canvasWidth * 0.06)
        .padding(.vertical, canvasHeight * 0.05)
        .background(
            RoundedRectangle(cornerRadius: canvasHeight * 0.04)
                .fill(.white)
                .shadow(color: .black.opacity(0.06), radius: canvasHeight * 0.03)
        )
        .padding(canvasHeight * 0.05)
    }
}

#if DEBUG
#Preview("Social 1280×640") {
    SocialPreview(width: 1280, height: 640)
}

#Preview("Banner 1280×280") {
    SocialPreview(width: 1280, height: 280)
}
#endif
