//
//  main.swift
//  LucideGenerator
//
//  Generates Swift source files from Lucide SVG icons using SVGPath
//

import Foundation
import CoreGraphics
import SVGPath

// MARK: - Configuration

struct Config {
    static let lucideRepoURL = "https://github.com/lucide-icons/lucide.git"
    static let iconsPath = "icons"
    static let outputFile = "Sources/LucideSwift/Lucide+Generated.swift"
    static let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("lucide-generator")
}

// MARK: - Icon Data Structure

struct Icon {
    let name: String
    let pathStrings: [String]
    
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
    static func extractPaths(from svgContent: String) -> [String] {
        var paths: [String] = []
        
        // Extract all path data from SVG content
        let pattern = #"<path[^/]*d=["']([^"']+)["']"#
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let range = NSRange(svgContent.startIndex..., in: svgContent)
            let matches = regex.matches(in: svgContent, options: [], range: range)
            
            for match in matches {
                let pathRange = match.range(at: 1)
                if let swiftRange = Range(pathRange, in: svgContent) {
                    paths.append(String(svgContent[swiftRange]))
                }
            }
        }
        
        // Extract and convert basic shapes
        paths.append(contentsOf: extractCircles(from: svgContent))
        paths.append(contentsOf: extractRects(from: svgContent))
        paths.append(contentsOf: extractEllipses(from: svgContent))
        paths.append(contentsOf: extractLines(from: svgContent))
        paths.append(contentsOf: extractPolygons(from: svgContent))
        
        return paths
    }
    
    private static func extractPolygons(from svgContent: String) -> [String] {
        var paths: [String] = []
        // Match polygon and polyline elements
        let pattern = #"<(polygon|polyline)\s+([^>]+)>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = regex.matches(in: svgContent, options: [], range: NSRange(svgContent.startIndex..., in: svgContent))
            
            for match in matches {
                let isPolygon = match.range(at: 1).length == 7 // "polygon"
                
                if let attrRange = Range(match.range(at: 2), in: svgContent) {
                    let attributes = String(svgContent[attrRange])
                    
                    if let pointsStr = extractAttributeValue(named: "points", from: attributes) {
                        // Parse points like "12 2 19 21 12 17 5 21" or "12,2 19,21 12,17 5,21"
                        let points = pointsStr.split(separator: " ").flatMap { point -> [String] in
                            point.split(separator: ",").map { String($0) }
                        }
                        
                        if points.count >= 4 {
                            var path = "M\(points[0]) \(points[1])"
                            for i in stride(from: 2, to: points.count, by: 2) {
                                if i + 1 < points.count {
                                    path += " L\(points[i]) \(points[i+1])"
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
        }
        
        return paths
    }
    
    private static func extractLines(from svgContent: String) -> [String] {
        var paths: [String] = []
        let pattern = #"<line\s+([^>]+)>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = regex.matches(in: svgContent, options: [], range: NSRange(svgContent.startIndex..., in: svgContent))
            
            for match in matches {
                if let attrRange = Range(match.range(at: 1), in: svgContent) {
                    let attributes = String(svgContent[attrRange])
                    
                    let x1 = extractAttributeValue(named: "x1", from: attributes) ?? "0"
                    let y1 = extractAttributeValue(named: "y1", from: attributes) ?? "0"
                    let x2 = extractAttributeValue(named: "x2", from: attributes) ?? "0"
                    let y2 = extractAttributeValue(named: "y2", from: attributes) ?? "0"
                    
                    if let x1Val = Double(x1), let y1Val = Double(y1), let x2Val = Double(x2), let y2Val = Double(y2) {
                        let path = "M\(x1Val) \(y1Val) L\(x2Val) \(y2Val)"
                        paths.append(path)
                    }
                }
            }
        }
        
        return paths
    }
    
    private static func extractCircles(from svgContent: String) -> [String] {
        var paths: [String] = []
        // Match circle with attributes in any order
        let pattern = #"<circle\s+([^>]+)>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = regex.matches(in: svgContent, options: [], range: NSRange(svgContent.startIndex..., in: svgContent))
            
            for match in matches {
                if let attrRange = Range(match.range(at: 1), in: svgContent) {
                    let attributes = String(svgContent[attrRange])
                    
                    let cx = extractAttributeValue(named: "cx", from: attributes) ?? "0"
                    let cy = extractAttributeValue(named: "cy", from: attributes) ?? "0"
                    let r = extractAttributeValue(named: "r", from: attributes) ?? "0"
                    
                    if let cxVal = Double(cx), let cyVal = Double(cy), let rVal = Double(r) {
                        let path = "M\(cxVal - rVal) \(cyVal) A\(rVal) \(rVal) 0 1 0 \(cxVal + rVal) \(cyVal) A\(rVal) \(rVal) 0 1 0 \(cxVal - rVal) \(cyVal)"
                        paths.append(path)
                    }
                }
            }
        }
        
        return paths
    }
    
    private static func extractRects(from svgContent: String) -> [String] {
        var paths: [String] = []
        // Match rect with attributes in any order
        let pattern = #"<rect\s+([^>]+)>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = regex.matches(in: svgContent, options: [], range: NSRange(svgContent.startIndex..., in: svgContent))
            
            for match in matches {
                if let attrRange = Range(match.range(at: 1), in: svgContent) {
                    let attributes = String(svgContent[attrRange])
                    
                    // Extract individual attributes
                    let x = extractAttributeValue(named: "x", from: attributes) ?? "0"
                    let y = extractAttributeValue(named: "y", from: attributes) ?? "0"
                    let w = extractAttributeValue(named: "width", from: attributes) ?? "0"
                    let h = extractAttributeValue(named: "height", from: attributes) ?? "0"
                    let rx = extractAttributeValue(named: "rx", from: attributes)
                    let ry = extractAttributeValue(named: "ry", from: attributes) ?? rx
                    
                    if let xVal = Double(x), let yVal = Double(y), let wVal = Double(w), let hVal = Double(h) {
                        let path: String
                        if let rx = rx, let rxVal = Double(rx), rxVal > 0 {
                            // Rounded rectangle
                            let r = min(rxVal, (ry != nil ? Double(ry!) ?? rxVal : rxVal))
                            path = "M\(xVal + r) \(yVal) H\(xVal + wVal - r) A\(r) \(r) 0 0 1 \(xVal + wVal) \(yVal + r) V\(yVal + hVal - r) A\(r) \(r) 0 0 1 \(xVal + wVal - r) \(yVal + hVal) H\(xVal + r) A\(r) \(r) 0 0 1 \(xVal) \(yVal + hVal - r) V\(yVal + r) A\(r) \(r) 0 0 1 \(xVal + r) \(yVal) Z"
                        } else {
                            // Regular rectangle
                            path = "M\(xVal) \(yVal) H\(xVal + wVal) V\(yVal + hVal) H\(xVal) Z"
                        }
                        paths.append(path)
                    }
                }
            }
        }
        
        return paths
    }
    
    private static func extractAttributeValue(named name: String, from attributes: String) -> String? {
        let pattern = "\\b\(name)=[\"']([^\"']+)[\"']"
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
           let match = regex.firstMatch(in: attributes, options: [], range: NSRange(attributes.startIndex..., in: attributes)),
           let valueRange = Range(match.range(at: 1), in: attributes) {
            return String(attributes[valueRange])
        }
        return nil
    }
    
    private static func extractEllipses(from svgContent: String) -> [String] {
        var paths: [String] = []
        // Match ellipse with attributes in any order
        let pattern = #"<ellipse\s+([^>]+)>"#
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let matches = regex.matches(in: svgContent, options: [], range: NSRange(svgContent.startIndex..., in: svgContent))
            
            for match in matches {
                if let attrRange = Range(match.range(at: 1), in: svgContent) {
                    let attributes = String(svgContent[attrRange])
                    
                    let cx = extractAttributeValue(named: "cx", from: attributes) ?? "0"
                    let cy = extractAttributeValue(named: "cy", from: attributes) ?? "0"
                    let rx = extractAttributeValue(named: "rx", from: attributes) ?? "0"
                    let ry = extractAttributeValue(named: "ry", from: attributes) ?? "0"
                    
                    if let cxVal = Double(cx), let cyVal = Double(cy), let rxVal = Double(rx), let ryVal = Double(ry) {
                        let path = "M\(cxVal - rxVal) \(cyVal) A\(rxVal) \(ryVal) 0 1 0 \(cxVal + rxVal) \(cyVal) A\(rxVal) \(ryVal) 0 1 0 \(cxVal - rxVal) \(cyVal)"
                        paths.append(path)
                    }
                }
            }
        }
        
        return paths
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
        //  Auto-generated from Lucide Icons using SVGPath
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
        
            /// Returns a SwiftUI Path for this icon
            public var path: Path {
                switch self {
        
        """
        
        // Generate path data
        for icon in icons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return Self.\(icon.swiftName)Path\n"
        }
        
        code += """
                }
            }
            
            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideIconShape {
                LucideIconShape(path: self.path)
            }
        
        """
        
        // Generate individual path functions
        for icon in icons {
            var pathCode = ""
            
            for pathString in icon.pathStrings {
                do {
                    // Use SVGPath to parse the path string
                    // Don't invert Y-axis to maintain SVG coordinate system (origin at top-left)
                    let options = SVGPath.ParseOptions(invertYAxis: false)
                    let svgPath = try SVGPath(string: pathString, with: options)
                    let cgPath = CGPath.from(svgPath)
                    let swiftCode = convertToSwiftPathCode(cgPath: cgPath)
                    pathCode += swiftCode
                } catch {
                    print("⚠️  Failed to parse path for \(icon.name): \(error)")
                }
            }
            
            code += "        \n"
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon path\n"
            code += "    static var \(icon.swiftName)Path: Path {\n"
            code += "        var path = Path()\n"
            code += "        \(pathCode)"
            code += "        return path\n"
            code += "    }\n"
        }
        
        code += "}\n"
        code += "\n"
        
        code += """
        // MARK: - Convenient Access
        
        public struct Lucide {
        
        """
        
        // Generate static properties
        for icon in icons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon\n"
            code += "    public static var \(icon.swiftName): LucideIconShape {\n"
            code += "        LucideIconShape(path: LucideIconName.\(icon.swiftName)Path)\n"
            code += "    }\n\n"
        }
        
        code += "}\n"
        
        return code
    }
    
    private static func convertToSwiftPathCode(cgPath: CGPath) -> String {
        var code = ""
        
        cgPath.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            let points = element.points
            
            switch element.type {
            case .moveToPoint:
                let point = points[0]
                code += "path.move(to: CGPoint(x: \(point.x), y: \(point.y)))\n"
                
            case .addLineToPoint:
                let point = points[0]
                code += "path.addLine(to: CGPoint(x: \(point.x), y: \(point.y)))\n"
                
            case .addQuadCurveToPoint:
                let controlPoint = points[0]
                let endPoint = points[1]
                code += "path.addQuadCurve(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)), control: CGPoint(x: \(controlPoint.x), y: \(controlPoint.y)))\n"
                
            case .addCurveToPoint:
                let controlPoint1 = points[0]
                let controlPoint2 = points[1]
                let endPoint = points[2]
                code += "path.addCurve(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)), control1: CGPoint(x: \(controlPoint1.x), y: \(controlPoint1.y)), control2: CGPoint(x: \(controlPoint2.x), y: \(controlPoint2.y)))\n"
                
            case .closeSubpath:
                code += "path.closeSubpath()\n"
                
            @unknown default:
                break
            }
        }
        
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
    
    for (index, svgFile) in svgFiles.enumerated() {
        let name = svgFile.deletingPathExtension().lastPathComponent
        
        // Progress indicator
        if index % 100 == 0 && index > 0 {
            print("  Processed \(index)/\(svgFiles.count) icons...")
        }
        
        do {
            let svgContent = try String(contentsOf: svgFile, encoding: .utf8)
            let pathStrings = SVGParser.extractPaths(from: svgContent)
            
            if pathStrings.isEmpty {
                print("⚠️  No paths found in: \(name)")
                continue
            }
            
            let icon = Icon(name: name, pathStrings: pathStrings)
            icons.append(icon)
        } catch {
            print("⚠️  Could not parse: \(name) - \(error)")
        }
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
