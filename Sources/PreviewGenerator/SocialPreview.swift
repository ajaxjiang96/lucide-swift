//
//  SocialPreview.swift
//  PreviewGenerator
//
//  Social media preview and README header banner generator.
//  Renders a tilted grid of icon tiles with edge fade.
//

import SwiftUI
import LucideSwift

/// Configurable icon-grid preview — grid, tilted, with white edge fade.
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
    private let textOpacity: Double

    /// - Parameters:
    ///   - width: Canvas width in points
    ///   - height: Canvas height in points
    ///   - showText: Whether to overlay centered branding text
    public init(width: CGFloat, height: CGFloat, showText: Bool = true, textOpacity: Double = 0.12) {
        self.canvasWidth = width
        self.canvasHeight = height
        self.showText = showText
        self.textOpacity = textOpacity

        // Size the grid to overflow the canvas so rotation doesn't leave gaps
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

            edgeFadeOverlay

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
                            LucideIcon(icons[idx], size: iconSize, color: .black.opacity(0.06))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Edge Fade

    private var edgeFadeOverlay: some View {
        let hFade = canvasWidth * 0.06
        let vFade = canvasHeight * 0.09

        return ZStack {
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: vFade)
                Spacer()
            }
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .top, endPoint: .bottom
                )
                .frame(height: vFade)
            }
            HStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: hFade)
                Spacer()
            }
            HStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .leading, endPoint: .trailing
                )
                .frame(width: hFade)
            }
        }
    }

    // MARK: - Branding

    private var brandingText: some View {
        let titleSize = canvasHeight * 0.10
        let subtitleSize = canvasHeight * 0.035

        return VStack(spacing: canvasHeight * 0.015) {
            Spacer()
            Text("Lucide Swift")
                .font(.system(size: titleSize, weight: .bold, design: .rounded))
                .foregroundColor(.black.opacity(textOpacity))
            Text("Native SwiftUI Shapes · Zero dependencies")
                .font(.system(size: subtitleSize, weight: .medium, design: .rounded))
                .foregroundColor(.black.opacity(textOpacity * 0.67))
            Spacer()
        }
    }
}

#if DEBUG
#Preview("Social 1280×640") {
    SocialPreview(width: 1280, height: 640)
}

#Preview("Banner 1280×280") {
    SocialPreview(width: 1280, height: 280, showText: false)
}
#endif
