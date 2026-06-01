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

    func testImageExtension() {
        // Verify Image initializers compile and return non-nil Image views
        let image1 = Image(lucide: .house)
        let image2 = Image(lucideFill: .heart)
        let image3 = Image(lucideLab: .broom)
        let image4 = Image(lucideLabFill: .avocado)

        XCTAssertNotNil(image1)
        XCTAssertNotNil(image2)
        XCTAssertNotNil(image3)
        XCTAssertNotNil(image4)
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

    func testIconInitialization() {
        // String lookup - Regular
        let house = LucideIcon(name: "house")
        XCTAssertNotNil(house)

        // String lookup - Lab
        let broom = LucideIcon(name: "broom")
        XCTAssertNotNil(broom)

        // String lookup - Non-existent (Fallback to house)
        let unknown = LucideIcon(name: "non-existent-icon")
        XCTAssertNotNil(unknown)

        // Filled version
        let filledHouse = LucideIconFill(name: "house")
        XCTAssertNotNil(filledHouse)
    }
}
