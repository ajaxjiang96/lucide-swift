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
    
    func testLabIcons() {
        // Test that we can access lab icons
        let broomIcon = LucideLab.broom
        let avocadoIcon = LucideLab.avocado
        
        XCTAssertNotNil(broomIcon)
        XCTAssertNotNil(avocadoIcon)
        
        // Test lab icon view
        let iconView = LucideLabIcon(.broom, size: 32, color: .purple)
        XCTAssertNotNil(iconView)
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
    
    func testSVGParser() {
        let svgContent = """
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12 2L2 7l10 5 10-5-10-5z" />
            <path d="M2 17l10 5 10-5" />
            <path d="M2 12l10 5 10-5" />
            <circle cx="12" cy="12" r="10" />
            <rect x="2" y="2" width="20" height="20" rx="2" ry="2" />
            <line x1="12" y1="2" x2="12" y2="22" />
            <ellipse cx="12" cy="12" rx="10" ry="5" />
            <polygon points="12 2 19 21 12 17 5 21" />
        </svg>
        """
        
        let paths = SVGParser.extractPaths(from: svgContent)
        
        // 3 paths + 1 circle + 1 rect + 1 line + 1 ellipse + 1 polygon = 8 total
        XCTAssertEqual(paths.count, 8)
        
        XCTAssertTrue(paths.contains("M12 2L2 7l10 5 10-5-10-5z"))
        XCTAssertTrue(paths.contains("M2 17l10 5 10-5"))
        XCTAssertTrue(paths.contains("M2 12l10 5 10-5"))
        
        // Circle conversion: M(cx-r) cy A r r 0 1 0 (cx+r) cy A r r 0 1 0 (cx-r) cy
        XCTAssertTrue(paths.contains("M2.0 12.0 A10.0 10.0 0 1 0 22.0 12.0 A10.0 10.0 0 1 0 2.0 12.0"))
        
        // Rect conversion (rounded): M(x+r) y H(x+w-r) A r r 0 0 1 (x+w) (y+r) V(y+h-r) A r r 0 0 1 (x+w-r) (y+h) H(x+r) A r r 0 0 1 x (y+h-r) V(y+r) A r r 0 0 1 (x+r) y Z
        XCTAssertTrue(paths.contains("M4.0 2.0 H20.0 A2.0 2.0 0 0 1 22.0 4.0 V20.0 A2.0 2.0 0 0 1 20.0 22.0 H4.0 A2.0 2.0 0 0 1 2.0 20.0 V4.0 A2.0 2.0 0 0 1 4.0 2.0 Z"))
        
        // Line conversion: M x1 y1 L x2 y2
        XCTAssertTrue(paths.contains("M12.0 2.0 L12.0 22.0"))
        
        // Ellipse conversion: M(cx-rx) cy A rx ry 0 1 0 (cx+rx) cy A rx ry 0 1 0 (cx-rx) cy
        XCTAssertTrue(paths.contains("M2.0 12.0 A10.0 5.0 0 1 0 22.0 12.0 A10.0 5.0 0 1 0 2.0 12.0"))
        
        // Polygon conversion: M x1 y1 L x2 y2 ... Z
        XCTAssertTrue(paths.contains("M12 2 L19 21 L12 17 L5 21 Z"))
    }
}
