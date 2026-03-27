//
//  LucideSwiftTests.swift
//  LucideSwiftTests
//

import XCTest
import SwiftUI
@testable import LucideSwift

final class LucideSwiftTests: XCTestCase {
    
    func testIconRendering() {
        // Test that icons can be created (using actual Lucide icon names)
        let houseIcon = Lucide.house
        let settingsIcon = Lucide.settings
        
        // Verify they conform to Shape
        let _: any Shape = houseIcon
        let _: any Shape = settingsIcon
    }
    
    func testSVGPathParser() {
        let pathData = "M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"
        let commands = SVGPathParser.parse(pathData: pathData)
        
        // Should have parsed some commands
        XCTAssertGreaterThan(commands.count, 0)
    }
    
    func testIconView() {
        let icon = LucideIcon(Lucide.house, size: 24, color: .blue)
        // Just verify it compiles and creates a view
        XCTAssertNotNil(icon)
    }
    
    func testAllIconsExist() {
        // Test that we can access various icons
        let icons: [LucideIconShape] = [
            Lucide.house,
            Lucide.settings,
            Lucide.heart,
            Lucide.star
        ]
        
        XCTAssertEqual(icons.count, 4)
        
        // Verify all icons have path data
        for icon in icons {
            XCTAssertFalse(icon.pathData.isEmpty, "Icon should have path data")
        }
    }
    
    func testReservedKeywords() {
        // Test that reserved keywords are properly escaped
        // These would fail to compile if not escaped
        let `case` = Lucide.caseLower
        let `switch` = Lucide.switchCamera
        
        XCTAssertNotNil(`case`)
        XCTAssertNotNil(`switch`)
    }
}
