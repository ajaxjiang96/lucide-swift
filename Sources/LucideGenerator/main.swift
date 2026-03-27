//
//  main.swift
//  LucideGenerator
//
//  Generates Swift source files from Lucide SVG icons
//

import Foundation

// MARK: - Configuration

struct Config {
    static let lucideRepoURL = "https://github.com/lucide-icons/lucide.git"
    static let iconsPath = "icons"
    static let outputFile = "Sources/LucideSwift/Lucide+Generated.swift"
    static let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("lucide-generator")
}

// MARK: - Icon Data Structure

struct Icon: Codable {
    let name: String
    let path: String
    let viewBox: String
    let tags: [String]
    
    var swiftName: String {
        // Convert kebab-case to camelCase for Swift
        let baseName = name.components(separatedBy: "-")
            .enumerated()
            .map { $0.offset == 0 ? $0.element : $0.element.capitalized }
            .joined()
        
        // Escape Swift reserved keywords by appending "Icon"
        let reservedKeywords: Set<String> = [
            "import", "subscript", "default", "return", "class", "struct", "enum",
            "func", "var", "let", "if", "else", "while", "for", "switch", "case",
            "break", "continue", "guard", "where", "in", "as", "is", "throw",
            "throws", "catch", "do", "try", "protocol", "extension", "typealias",
            "associatedtype", "lazy", "mutating", "nonmutating", "optional",
            "override", "required", "static", "final", "dynamic", "indirect",
            "convenience", "prefix", "postfix", "infix", "operator", "precedence",
            "associativity", "right", "left", "none", "true", "false", "nil",
            "self", "Self", "super", "init", "deinit", "get", "set", "willSet",
            "didSet", "repeat", "fallthrough", "defer", "internal", "private",
            "public", "open", "fileprivate", "unowned", "weak", "strong",
            "async", "await", "yield", "each", "any", "some", "package"
        ]
        
        return reservedKeywords.contains(baseName) ? baseName + "Icon" : baseName
    }
}

// MARK: - SVG Parser

struct SVGParser {
    static func parseIcon(from jsonData: Data) throws -> Icon {
        let decoder = JSONDecoder()
        return try decoder.decode(Icon.self, from: jsonData)
    }
    
    static func extractPath(from svgContent: String) -> String? {
        // First try to extract from <path> element
        if let pathData = extractPathElement(from: svgContent) {
            return pathData
        }
        
        // Otherwise try to convert basic shapes to paths
        return extractBasicShapes(from: svgContent)
    }
    
    private static func extractPathElement(from svgContent: String) -> String? {
        // Extract ALL path data from SVG content and combine them
        // Support both single and double quotes, and handle path being any attribute
        let pattern = #"<path\s+[^>]*d=["']([^"']+)["']"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        let paths = matches.compactMap { match -> String? in
            let pathRange = match.range(at: 1)
            if let swiftRange = Range(pathRange, in: svgContent) {
                return String(svgContent[swiftRange])
            }
            return nil
        }
        
        return paths.isEmpty ? nil : paths.joined(separator: " ")
    }
    
    private static func extractBasicShapes(from svgContent: String) -> String? {
        var paths: [String] = []
        
        // Extract all circles
        paths.append(contentsOf: extractCircles(from: svgContent))
        
        // Extract all rects
        paths.append(contentsOf: extractRects(from: svgContent))
        
        // Extract all ellipses
        paths.append(contentsOf: extractEllipses(from: svgContent))
        
        // Extract all lines
        paths.append(contentsOf: extractLines(from: svgContent))
        
        // Extract all polylines/polygons
        paths.append(contentsOf: extractPolylines(from: svgContent))
        
        return paths.isEmpty ? nil : paths.joined(separator: " ")
    }
    
    private static func extractAttribute(_ attribute: String, from content: String) -> String? {
        let pattern = "\\s\(attribute)\\s*=\\s*[\"']([^\"']+)[\"']"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
        let range = NSRange(content.startIndex..., in: content)
        if let match = regex?.firstMatch(in: content, options: [], range: range) {
            let valueRange = match.range(at: 2)
            if let swiftRange = Range(valueRange, in: content) {
                return String(content[swiftRange])
            }
        }
        return nil
    }
    
    private static func extractCircles(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<circle\s+[^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return paths
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        for match in matches {
            let tagRange = match.range(at: 0)
            if let swiftRange = Range(tagRange, in: svgContent) {
                let tagContent = String(svgContent[swiftRange])
                if let cx = extractAttributeValue("cx", from: tagContent),
                   let cy = extractAttributeValue("cy", from: tagContent),
                   let r = extractAttributeValue("r", from: tagContent) {
                    // Convert circle to path: M cx-r cy A r r 0 1 0 cx+r cy A r r 0 1 0 cx-r cy
                    let path = "M\(cx.doubleValue - r.doubleValue) \(cy) A\(r) \(r) 0 1 0 \(cx.doubleValue + r.doubleValue) \(cy) A\(r) \(r) 0 1 0 \(cx.doubleValue - r.doubleValue) \(cy)"
                    paths.append(path)
                }
            }
        }
        
        return paths
    }
    
    private static func extractRects(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<rect\s+[^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return paths
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        for match in matches {
            let tagRange = match.range(at: 0)
            if let swiftRange = Range(tagRange, in: svgContent) {
                let tagContent = String(svgContent[swiftRange])
                let x = extractAttributeValue("x", from: tagContent) ?? "0"
                let y = extractAttributeValue("y", from: tagContent) ?? "0"
                let width = extractAttributeValue("width", from: tagContent) ?? "0"
                let height = extractAttributeValue("height", from: tagContent) ?? "0"
                let rx = extractAttributeValue("rx", from: tagContent)
                let ry = extractAttributeValue("ry", from: tagContent) ?? rx
                
                let path: String
                if let rx = rx, let ry = ry, rx.doubleValue > 0 || ry.doubleValue > 0 {
                    // Rounded rectangle
                    let r = min(rx.doubleValue, ry.doubleValue)
                    let w = width.doubleValue
                    let h = height.doubleValue
                    let x1 = x.doubleValue
                    let y1 = y.doubleValue
                    path = "M\(x1 + r) \(y1) H\(x1 + w - r) A\(r) \(r) 0 0 1 \(x1 + w) \(y1 + r) V\(y1 + h - r) A\(r) \(r) 0 0 1 \(x1 + w - r) \(y1 + h) H\(x1 + r) A\(r) \(r) 0 0 1 \(x1) \(y1 + h - r) V\(y1 + r) A\(r) \(r) 0 0 1 \(x1 + r) \(y1) Z"
                } else {
                    // Regular rectangle
                    path = "M\(x) \(y) H\(x.doubleValue + width.doubleValue) V\(y.doubleValue + height.doubleValue) H\(x) Z"
                }
                paths.append(path)
            }
        }
        
        return paths
    }
    
    private static func extractEllipses(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<ellipse\s+[^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return paths
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        for match in matches {
            let tagRange = match.range(at: 0)
            if let swiftRange = Range(tagRange, in: svgContent) {
                let tagContent = String(svgContent[swiftRange])
                if let cx = extractAttributeValue("cx", from: tagContent),
                   let cy = extractAttributeValue("cy", from: tagContent),
                   let rx = extractAttributeValue("rx", from: tagContent),
                   let ry = extractAttributeValue("ry", from: tagContent) {
                    // Convert ellipse to path using two arc commands
                    let path = "M\(cx.doubleValue - rx.doubleValue) \(cy) A\(rx) \(ry) 0 1 0 \(cx.doubleValue + rx.doubleValue) \(cy) A\(rx) \(ry) 0 1 0 \(cx.doubleValue - rx.doubleValue) \(cy)"
                    paths.append(path)
                }
            }
        }
        
        return paths
    }
    
    private static func extractLines(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<line\s+[^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return paths
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        for match in matches {
            let tagRange = match.range(at: 0)
            if let swiftRange = Range(tagRange, in: svgContent) {
                let tagContent = String(svgContent[swiftRange])
                if let x1 = extractAttributeValue("x1", from: tagContent),
                   let y1 = extractAttributeValue("y1", from: tagContent),
                   let x2 = extractAttributeValue("x2", from: tagContent),
                   let y2 = extractAttributeValue("y2", from: tagContent) {
                    let path = "M\(x1) \(y1) L\(x2) \(y2)"
                    paths.append(path)
                }
            }
        }
        
        return paths
    }
    
    private static func extractPolylines(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<(polyline|polygon)\s+[^>]*points=["']([^"']+)["'][^>]*>"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return paths
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        let matches = regex.matches(in: svgContent, options: [], range: range)
        
        for match in matches {
            let pointsRange = match.range(at: 2)
            if let swiftRange = Range(pointsRange, in: svgContent) {
                let pointsString = String(svgContent[swiftRange])
                let isPolygon = match.range(at: 1).length == 7 // "polygon"
                
                // Parse points like "0 0 1 1 2 2" into path commands
                let points = pointsString.split(separator: " ").map { String($0) }
                if points.count >= 2 {
                    let coordinates = points.flatMap { point -> [String] in
                        point.split(separator: ",").map { String($0) }
                    }
                    
                    if coordinates.count >= 4 {
                        var path = "M\(coordinates[0]) \(coordinates[1])"
                        for i in stride(from: 2, to: coordinates.count, by: 2) {
                            if i + 1 < coordinates.count {
                                path += " L\(coordinates[i]) \(coordinates[i + 1])"
                            }
                        }
                        if isPolygon {
                            path += " Z"
                        }
                        paths.append(path)
                    }
                }
            }
        }
        
        return paths
    }
    
    private static func extractAttributeValue(_ attribute: String, from content: String) -> String? {
        let pattern = "\\s\(attribute)\\s*=\\s*[\"']([^\"']+)[\"']"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else {
            return nil
        }
        
        let range = NSRange(content.startIndex..., in: content)
        if let match = regex.firstMatch(in: content, options: [], range: range) {
            let valueRange = match.range(at: 1)
            if let swiftRange = Range(valueRange, in: content) {
                return String(content[swiftRange])
            }
        }
        return nil
    }
}

extension String {
    var doubleValue: Double {
        return Double(self) ?? 0
    }
}

// MARK: - Swift Code Generator

struct SwiftCodeGenerator {
    static func generateSwiftCode(icons: [Icon]) -> String {
        var code = """
        //
        //  Lucide+Generated.swift
        //  LucideSwift
        //
        //  Auto-generated from Lucide Icons
        //  DO NOT EDIT MANUALLY
        //
        
        import SwiftUI
        
        // MARK: - Lucide Icon Enum
        
        public enum LucideIconName: String, CaseIterable {
        
        """
        
        // Generate enum cases
        for icon in icons {
            code += "    case \(icon.swiftName)\n"
        }
        
        code += """
        
            /// Returns the SVG path data for this icon
            public var path: String {
                switch self {
        
        """
        
        // Generate path data
        for icon in icons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return \"\(icon.path)\"\n"
        }
        
        code += """
                }
            }
            
            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideIconShape {
                LucideIconShape(path: path)
            }
        }
        
        // MARK: - Convenient Access
        
        public struct Lucide {
        
        """
        
        // Generate static properties
        for icon in icons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon\n"
            code += "    public static var \(icon.swiftName): LucideIconShape {\n"
            code += "        LucideIconShape(path: \"\(icon.path)\")\n"
            code += "    }\n\n"
        }
        
        code += "}\n"
        
        return code
    }
}

// MARK: - Main

func main() async throws {
    print("🚀 Lucide Swift Code Generator")
    print("================================")
    
    let fileManager = FileManager.default
    
    // Clean up and create temp directory
    if fileManager.fileExists(atPath: Config.tempDirectory.path) {
        try fileManager.removeItem(at: Config.tempDirectory)
    }
    try fileManager.createDirectory(at: Config.tempDirectory, withIntermediateDirectories: true)
    
    // Clone Lucide repository
    print("📦 Cloning Lucide repository...")
    
    #if os(macOS)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["clone", "--depth", "1", Config.lucideRepoURL, Config.tempDirectory.path]
    
    try process.run()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
        throw GeneratorError.cloneFailed
    }
    #else
    throw GeneratorError.unsupportedPlatform
    #endif
    
    print("✅ Repository cloned")
    
    // Find and parse icons
    let iconsDirectory = Config.tempDirectory.appendingPathComponent(Config.iconsPath)
    let contents = try fileManager.contentsOfDirectory(at: iconsDirectory, includingPropertiesForKeys: nil)
    
    let svgFiles = contents.filter { $0.pathExtension == "svg" }
    print("📁 Found \(svgFiles.count) icons")
    
    var icons: [Icon] = []
    
    for svgFile in svgFiles {
        let name = svgFile.deletingPathExtension().lastPathComponent
        let svgContent = try String(contentsOf: svgFile, encoding: .utf8)
        
        guard let path = SVGParser.extractPath(from: svgContent) else {
            print("⚠️  Could not parse path for: \(name)")
            continue
        }
        
        let icon = Icon(
            name: name,
            path: path,
            viewBox: "0 0 24 24",
            tags: []
        )
        
        icons.append(icon)
    }
    
    print("✅ Parsed \(icons.count) icons")
    
    // Sort icons by name
    icons.sort { $0.name < $1.name }
    
    // Generate Swift code
    print("📝 Generating Swift code...")
    let swiftCode = SwiftCodeGenerator.generateSwiftCode(icons: icons)
    
    // Write to file
    let outputURL = URL(fileURLWithPath: Config.outputFile)
    try swiftCode.write(to: outputURL, atomically: true, encoding: .utf8)
    
    print("✅ Generated: \(Config.outputFile)")
    print("🎉 Done! Generated \(icons.count) icons")
    
    // Cleanup
    try fileManager.removeItem(at: Config.tempDirectory)
}

enum GeneratorError: Error {
    case cloneFailed
    case unsupportedPlatform
}

// Run the generator
do {
    try await main()
} catch {
    print("❌ Error: \(error)")
    exit(1)
}
