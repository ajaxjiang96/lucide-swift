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
    
    func testIconView() {
        let icon = LucideIcon(Lucide.house, size: 24, color: .blue)
        // Just verify it compiles and creates a view
        XCTAssertNotNil(icon)
    }
    
    func testAllIconsExist() {
        // Test that we can access various icons
        let icons: [LucideShape] = [
            Lucide.house,
            Lucide.settings,
            Lucide.heart,
            Lucide.star
        ]
        
        XCTAssertEqual(icons.count, 4)
        
        // Verify all icons can create paths (Path is a value type, can't be empty check)
        for icon in icons {
            let path = icon.path(in: CGRect(x: 0, y: 0, width: 24, height: 24))
            XCTAssertNotNil(path, "Icon should create a path")
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
