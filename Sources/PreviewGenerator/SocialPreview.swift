//
//  SocialPreview.swift
//  PreviewGenerator
//
//  Social media preview image generator.
//  Renders a tilted grid of 48pt icon tiles with subtle edge fade for use as
//  an og:image / social card banner (1280×640).
//

import SwiftUI
import LucideSwift

/// Social media preview view — icon grid, tilted, with white edge fade.
/// Output: 1280×640 px.
public struct SocialPreview: View {
    private let icons: [LucideIconName]
    private let columns: Int
    private let rows: Int

    private let tiltDegrees: Double = 6
    private let iconSize: CGFloat = 48
    private let cellSize: CGFloat = 56

    public init() {
        let all = LucideIconName.allCases
        let columns = 36
        let count = all.count
        let rows = 22
        var filled: [LucideIconName] = []
        filled.reserveCapacity(columns * rows)
        for i in 0..<(columns * rows) {
            filled.append(all[i % count])
        }
        self.icons = filled
        self.columns = columns
        self.rows = rows
    }

    public var body: some View {
        ZStack {
            // White background
            Color.white

            // Tilted icon grid
            gridView
                .rotationEffect(.degrees(tiltDegrees))
                .frame(width: 2000, height: 1200) // oversized to avoid gaps after rotation
                .clipped()

            // Edge fade — narrow gradients only at the very edges
            edgeFadeOverlay
        }
        .frame(width: 1280, height: 640)
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

    /// Narrow white gradients on all four edges — fades the grid to white
    /// only at the perimeter, leaving the vast majority of the image clear.
    private var edgeFadeOverlay: some View {
        ZStack {
            // Top edge
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                Spacer()
            }

            // Bottom edge
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
            }

            // Left edge
            HStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 80)
                Spacer()
            }

            // Right edge
            HStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 80)
            }
        }
    }
}

#if DEBUG
#Preview {
    SocialPreview()
}
#endif
