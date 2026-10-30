//
//  IconFileGenerationTests.swift
//  LucideSwift
//
//  Verify generated files survive case-insensitive filesystems.
//

import Foundation
import XCTest
@testable import LucideGenerator

final class IconFileGenerationTests: XCTestCase {
    func testLetterSAndLettersKeepDistinctFilesAndNamespaces() throws {
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputDirectory) }

        let icons = [IconType.regular, .lab].flatMap { type in
            ["letter-s", "letters"].map { name in
                Icon(name: name, pathStrings: ["M1 2L3 4"], type: type)
            }
        }
        try SwiftCodeGenerator.writeIconFiles(icons: icons, outputDirectory: outputDirectory)

        let generatedAPI = SwiftCodeGenerator.generateSwiftCode(icons: icons)
        for type in [IconType.regular, .lab] {
            let directory = type == .lab ? outputDirectory.appendingPathComponent("Lab") : outputDirectory
            let files = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
                .filter { $0.pathExtension == "swift" }
            XCTAssertEqual(files.count, 2, "letter-s and letters must not overwrite each other")
            XCTAssertEqual(Set(files.map { $0.lastPathComponent.lowercased() }).count, 2)

            let contents = try files.map { try String(contentsOf: $0, encoding: .utf8) }
            for icon in icons where icon.type == type {
                XCTAssertTrue(contents.contains { $0.contains("internal enum \(icon.iconNamespaceEnum) {") })
                XCTAssertTrue(generatedAPI.contains("\(icon.iconNamespaceEnum).combinedPath"))
            }
        }

        // Public API and internal namespaces must retain the Swift casing.
        XCTAssertTrue(generatedAPI.contains("case letterS\n"))
        XCTAssertTrue(generatedAPI.contains("case letters\n"))
        XCTAssertTrue(generatedAPI.contains("LucideIcon_LetterS.combinedPath"))
        XCTAssertTrue(generatedAPI.contains("LucideIcon_Letters.combinedPath"))
    }

    func testRegenerationRemovesOldFiles() throws {
        let outputDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: outputDirectory) }
        try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        let staleFile = outputDirectory.appendingPathComponent("Icon_LetterS.swift")
        try "stale".write(to: staleFile, atomically: true, encoding: .utf8)

        try SwiftCodeGenerator.writeIconFiles(
            icons: [Icon(name: "letter-s", pathStrings: ["M1 2L3 4"], type: .regular)],
            outputDirectory: outputDirectory
        )
        XCTAssertFalse(FileManager.default.fileExists(atPath: staleFile.path))
        let files = try FileManager.default.contentsOfDirectory(atPath: outputDirectory.path)
        XCTAssertEqual(files.filter { $0.hasSuffix(".swift") }.count, 1)
    }
}
