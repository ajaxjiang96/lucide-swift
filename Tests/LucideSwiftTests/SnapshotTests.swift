//
//  SnapshotTests.swift
//  LucideSwiftTests
//
//  Pixel snapshot tests for every Lucide icon. Renders each icon's Path
//  through CoreGraphics matching the default LucideIcon View (stroked,
//  size 24, strokeWidth 2) at 4× resolution, and compares the resulting
//  PNG bytes against a committed baseline.
//
//  Recording mode: set SNAPSHOT_RECORD=1 in the environment to (re)write
//  every baseline. Recording is silent — no test failures — so it can be
//  used as a normal pipeline step after generator regeneration.
//
//  Compare mode (default): a missing baseline records an XCTFail and skips.
//  A byte mismatch fails the test with a hint about SNAPSHOT_RECORD.
//
//  Determinism: CoreGraphics rendering at integer coordinates and integer
//  line widths is byte-deterministic. The render size (96×96) and line width
//  (8) are chosen to match the default LucideIcon proportions at 4× scale
//  while keeping all parameters integral.
//

import XCTest
import SwiftUI
import CoreGraphics
import ImageIO
@testable import LucideSwift

final class SnapshotTests: XCTestCase {

    // MARK: - Configuration

    /// The pixel dimensions of the rendered image. Must be a multiple of 24
    /// for clean coordinate scaling from the 24×24 viewBox.
    private static let renderSize = 96

    /// The stroke width used when rendering. Matches the default
    /// LucideIcon strokeWidth=2 scaled to renderSize:
    ///   2 × (renderSize / 24) = 2 × (96 / 24) = 8
    private static let strokeWidth: CGFloat = 8

    /// Baseline directory, resolved from this source file's location.
    private static var snapshotDir: URL {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__", isDirectory: true)
    }

    // MARK: - Rendering

    private enum RenderError: Error {
        case contextFailed
        case imageFailed
        case encodeFailed
    }

    /// Renders an icon to PNG data using the same default settings as
    /// `LucideIcon` — stroked mode, round cap/join, proportional stroke width.
    private func renderPNG(iconName: LucideIconName) throws -> Data {
        let size = Self.renderSize
        let rect = CGRect(x: 0, y: 0, width: CGFloat(size), height: CGFloat(size))
        let shape = iconName.shape

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: size,
            height: size,
            bitsPerComponent: 8,
            bytesPerRow: size * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            throw RenderError.contextFailed
        }

        // White background
        ctx.setFillColor(red: 1, green: 1, blue: 1, alpha: 1)
        ctx.fill(rect)

        // Flip Y: SwiftUI puts origin at top-left; CGContext at bottom-left
        ctx.translateBy(x: 0, y: CGFloat(size))
        ctx.scaleBy(x: 1, y: -1)

        // Render the icon path, stroked — matches LucideIcon's .stroked (default) style
        let path = shape.path(in: rect)
        ctx.addPath(path.cgPath)
        ctx.setStrokeColor(red: 0, green: 0, blue: 0, alpha: 1)
        ctx.setLineWidth(Self.strokeWidth)
        ctx.setLineCap(.round)
        ctx.setLineJoin(.round)
        ctx.strokePath()

        guard let image = ctx.makeImage() else {
            throw RenderError.imageFailed
        }

        let data = NSMutableData()
        guard let dest = CGImageDestinationCreateWithData(data, "public.png" as CFString, 1, nil) else {
            throw RenderError.encodeFailed
        }
        CGImageDestinationAddImage(dest, image, nil)
        guard CGImageDestinationFinalize(dest) else {
            throw RenderError.encodeFailed
        }

        return data as Data
    }

    // MARK: - Snapshot comparison

    private func assertSnapshot(_ iconName: LucideIconName, file: StaticString = #filePath, line: UInt = #line) throws {
        let name = iconName.rawValue
        let baselineURL = Self.snapshotDir.appendingPathComponent("\(name).png")
        let record = ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1"

        if record {
            let actual = try renderPNG(iconName: iconName)
            try FileManager.default.createDirectory(at: Self.snapshotDir, withIntermediateDirectories: true)
            try actual.write(to: baselineURL)
            return
        }

        guard FileManager.default.fileExists(atPath: baselineURL.path) else {
            XCTFail("No snapshot baseline for '\(name)'. Run tests with SNAPSHOT_RECORD=1 to create one.", file: file, line: line)
            return
        }

        let actual = try renderPNG(iconName: iconName)
        let expected = try Data(contentsOf: baselineURL)

        XCTAssertEqual(
            actual, expected,
            "Snapshot mismatch for '\(name)'. Re-run with SNAPSHOT_RECORD=1 if the change is intentional.",
            file: file, line: line
        )
    }

    // MARK: - Tests

    func testSnapshotAllRegularIcons() throws {
        let iconNames = LucideIconName.allCases

        XCTAssertFalse(iconNames.isEmpty, "Expected at least one regular icon to snapshot")

        var failures: [(String, Error)] = []

        for iconName in iconNames {
            do {
                try assertSnapshot(iconName)
            } catch {
                failures.append((iconName.rawValue, error))
            }
        }

        if !failures.isEmpty {
            let names = failures.map(\.0).joined(separator: ", ")
            XCTFail("\(failures.count) snapshot(s) threw errors: \(names)")
        }
    }
}
