//
//  Lucide.swift
//  LucideSwift
//
//  LucideShape — the native SwiftUI Shape backing every Lucide icon.
//

import SwiftUI

/// A Shape representing a Lucide icon.
///
/// `LucideShape` is the underlying vector representation of a Lucide icon.
/// While you can use it directly like any other SwiftUI `Shape`, it is usually
/// easier to use the ``LucideIcon`` view.
///
/// ### Example
/// ```swift
/// Lucide.house
///     .stroke(Color.blue, lineWidth: 2)
///     .frame(width: 24, height: 24)
/// ```
public struct LucideShape: Shape {
    let combinedPath: Path
    let openPath: Path
    let closedPath: Path

    /// Initialize with pre-separated paths.
    ///
    /// Path separation (open vs. closed subpaths) is performed at generation time
    /// so the runtime has no element-walking cost.
    public init(combined: Path, open: Path, closed: Path) {
        self.combinedPath = combined
        self.openPath = open
        self.closedPath = closed
    }

    /// Generates a path for the icon within the given rectangle.
    /// - Parameter rect: The frame to fit the icon into.
    /// - Returns: A `Path` containing all icon elements.
    public func path(in rect: CGRect) -> Path {
        combinedPath.applying(transform(in: rect))
    }

    /// Returns a path containing only the open subpaths, scaled to the given rect.
    ///
    /// Open subpaths are typically decorative lines that should be stroked rather than filled.
    public func openPath(in rect: CGRect) -> Path {
        openPath.applying(transform(in: rect))
    }

    /// Returns a path containing only the closed subpaths, scaled to the given rect.
    ///
    /// Closed subpaths represent solid areas that can be safely filled.
    public func closedPath(in rect: CGRect) -> Path {
        closedPath.applying(transform(in: rect))
    }

    private func transform(in rect: CGRect) -> CGAffineTransform {
        // Scale the pre-generated path to fit the rect
        // Lucide icons are designed for 24x24 viewBox
        let scaleX = rect.width / 24
        let scaleY = rect.height / 24

        // Apply scaling first, then translation to avoid scaling the offset
        let transform = CGAffineTransform(scaleX: scaleX, y: scaleY)
        return transform.concatenating(CGAffineTransform(translationX: rect.minX, y: rect.minY))
    }
}
