//
//  SocialPreview.swift
//  PreviewGenerator
//
//  Social media preview image generator.
//  Renders a tilted grid of 24pt icon tiles with edge fade for use as
//  an og:image / social card banner (1280×640).
//

import SwiftUI
import LucideSwift

/// Social media preview view — dense icon grid, tilted, with white edge fade.
/// Output: 1280×640 px at 2× scale.
public struct SocialPreview: View {
    /// Icons to tile (sampled from the full set for performance).
    private let icons: [LucideIconName]
    /// Columns in the grid (before rotation, spans wider area to avoid gaps).
    private let columns: Int
    /// Rows in the grid.
    private let rows: Int

    /// Rotation angle in degrees for the grid tilt.
    private let tiltDegrees: Double = 6
    /// Size of each icon cell (icon + spacing).
    private let cellSize: CGFloat = 28

    public init() {
        let all = LucideIconName.allCases
        let columns = 70
        let count = all.count
        // Tile as many rows as needed to fill ~1100px vertically (accounts for rotation overflow)
        let rows = 40
        // Repeat icons cyclically to fill the grid
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
                .frame(width: 1600, height: 1000) // oversized to cover after rotation
                .clipped()

            // Edge fade — linear gradients on all four sides
            edgeFadeOverlay

            // Subtle center text branding
            VStack(spacing: 8) {
                Spacer()
                Text("Lucide Swift")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.black.opacity(0.15))
                Text("2,112+ icons · Native SwiftUI Shapes · Zero dependencies")
                    .font(.system(size: 24, weight: .medium, design: .rounded))
                    .foregroundColor(.black.opacity(0.10))
                Spacer()
            }
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
                            LucideIcon(icons[idx], size: 22, color: .black.opacity(0.07))
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Edge Fade

    /// White gradient overlays on all four edges that fade the icon grid toward the center.
    private var edgeFadeOverlay: some View {
        ZStack {
            // Top fade
            VStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
                Spacer()
            }

            // Bottom fade
            VStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 180)
            }

            // Left fade
            HStack {
                LinearGradient(
                    gradient: Gradient(colors: [.white, .white.opacity(0)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 200)
                Spacer()
            }

            // Right fade
            HStack {
                Spacer()
                LinearGradient(
                    gradient: Gradient(colors: [.white.opacity(0), .white]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 200)
            }
        }
    }
}

#if DEBUG
#Preview {
    SocialPreview()
}
#endif
