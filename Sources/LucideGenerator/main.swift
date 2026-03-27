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
        name.components(separatedBy: "-")
            .enumerated()
            .map { $0.offset == 0 ? $0.element : $0.element.capitalized }
            .joined()
    }
}

// MARK: - SVG Parser

struct SVGParser {
    static func parseIcon(from jsonData: Data) throws -> Icon {
        let decoder = JSONDecoder()
        return try decoder.decode(Icon.self, from: jsonData)
    }
    
    static func extractPath(from svgContent: String) -> String? {
        // Extract path data from SVG content
        let pattern = #"<path[^>]*d="([^"]*)"#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return nil
        }
        
        let range = NSRange(svgContent.startIndex..., in: svgContent)
        if let match = regex.firstMatch(in: svgContent, options: [], range: range) {
            let pathRange = match.range(at: 1)
            if let swiftRange = Range(pathRange, in: svgContent) {
                return String(svgContent[swiftRange])
            }
        }
        
        return nil
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
        
        public enum LucideIcon: String, CaseIterable {
        
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
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["clone", "--depth", "1", Config.lucideRepoURL, Config.tempDirectory.path]
    
    try process.run()
    process.waitUntilExit()
    
    if process.terminationStatus != 0 {
        throw GeneratorError.cloneFailed
    }
    
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
}

// Run the generator
do {
    try await main()
} catch {
    print("❌ Error: \(error)")
    exit(1)
}
