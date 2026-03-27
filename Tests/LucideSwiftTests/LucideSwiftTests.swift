//
//  LucideSwiftTests.swift
//  LucideSwiftTests
//

import XCTest
import SwiftUI
@testable import LucideSwift

final class LucideSwiftTests: XCTestCase {
    
    func testIconRendering() {
        // Test that icons can be created
        let homeIcon = Lucide.home
        let settingsIcon = Lucide.settings
        
        // Verify they conform to Shape
        let _: any Shape = homeIcon
        let _: any Shape = settingsIcon
    }
    
    func testSVGPathParser() {
        let pathData = "M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
        let commands = SVGPathParser.parse(pathData: pathData)
        
        // Should have parsed some commands
        XCTAssertGreaterThan(commands.count, 0)
    }
    
    func testIconView() {
        let icon = LucideIcon(.home, size: 24, color: .blue)
        // Just verify it compiles and creates a view
        XCTAssertNotNil(icon)
    }
    
    func testAllIconsExist() {
        // Test that we can access all icons
        let icons: [LucideIconShape] = [
            Lucide.home,
            Lucide.settings,
            Lucide.heart,
            Lucide.star,
            Lucide.circle
        ]
        
        XCTAssertEqual(icons.count, 5)
    }
}
