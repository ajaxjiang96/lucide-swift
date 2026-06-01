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
    static let lucideLabRepoURL = "https://github.com/lucide-icons/lucide-lab.git"
    static let iconsPath = "icons"
    static let outputFile = "Sources/LucideSwift/Lucide+Generated.swift"
    static let tempDirectory = FileManager.default.temporaryDirectory.appendingPathComponent("lucide-generator")
    static let lucideVersionFile = ".lucide-version"
    static let lucideLabVersionFile = ".lucide-lab-version"
    static let libraryVersionFile = ".library-version"
    
    /// Get the library version from .library-version file, or return "dev" if not found
    static var libraryVersion: String {
        return readVersion(from: libraryVersionFile) ?? "dev"
    }
    
    /// Get the upstream Lucide version from the version file
    static var lucideVersion: String {
        return readVersion(from: lucideVersionFile) ?? "unknown"
    }
    
    /// Get the upstream Lucide Lab version from the version file
    static var lucideLabVersion: String {
        return readVersion(from: lucideLabVersionFile) ?? "main"
    }
    
    private static func readVersion(from fileName: String) -> String? {
        var searchDir = FileManager.default.currentDirectoryPath
        for _ in 0..<10 {
            let filePath = "\(searchDir)/\(fileName)"
            if FileManager.default.fileExists(atPath: filePath) {
                do {
                    let content = try String(contentsOfFile: filePath, encoding: .utf8)
                    return content.trimmingCharacters(in: .whitespacesAndNewlines)
                } catch {
                    print("⚠️  Warning: Could not read \(fileName) at \(filePath)")
                }
            }
            let parentDir = (searchDir as NSString).deletingLastPathComponent
            if parentDir == searchDir { break }
            searchDir = parentDir
        }
        return nil
    }

    /// Extra icons that are not in the Lucide repository but should be included
    static let extraIcons: [Icon] = [
        Icon(name: "lucide", pathStrings: [
            "M7 21h10",
            "M7 3v18"
        ], type: .regular),
        Icon(name: "lucide-lab", pathStrings: [
            "M10 2v7.31",
            "M14 9.3V2",
            "M8.5 2h7",
            "M14 9.3a6.5 6.5 0 1 1-4 0",
            "M5.52 16h12.96"
        ], type: .lab)
    ]
}

// MARK: - Icon Data Structure

enum IconType {
    case regular
    case lab
}

struct Icon {
    let name: String
    let pathStrings: [String]
    let type: IconType
    
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

// MARK: - Swift Code Generator

struct SwiftCodeGenerator {
    static func generateSwiftCode(icons: [Icon]) -> String {
        let libraryVersion = Config.libraryVersion
        let lucideVersion = Config.lucideVersion
        let lucideLabVersion = Config.lucideLabVersion
        
        let regularIcons = icons.filter { $0.type == .regular }
        let labIcons = icons.filter { $0.type == .lab }
        
        var code = """
        //
        //  Lucide+Generated.swift
        //  LucideSwift
        //
        //  Auto-generated from Lucide Icons using SVGPath
        //  Library Version: \(libraryVersion)
        //  Lucide Icons Version: \(lucideVersion)
        //  Lucide Lab Version: \(lucideLabVersion)
        //  DO NOT EDIT MANUALLY
        //
        
        import SwiftUI
        
        // MARK: - Lucide Icon Enum
        
        public enum LucideIconName: String, CaseIterable {
        
        """
        
        // Generate regular enum cases
        for icon in regularIcons {
            code += "    case \(icon.swiftName)\n"
        }
        
        code += """
        
            /// Returns a SwiftUI Path for this icon
            public var path: Path {
                switch self {
        
        """
        
        // Generate regular path switches
        for icon in regularIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return Self.\(icon.swiftName)Path\n"
        }
        
        code += """
                }
            }
            
            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideShape {
                LucideShape(path: self.path)
            }
        
        """
        
        // Generate regular path definitions
        for icon in regularIcons {
            code += generatePathStaticProperty(for: icon)
        }
        
        code += "}\n\n"
        
        // MARK: - Lucide Lab Icon Enum
        
        code += """
        // MARK: - Lucide Lab Icon Enum
        
        public enum LucideLabIconName: String, CaseIterable {
        
        """
        
        // Generate lab enum cases
        for icon in labIcons {
            code += "    case \(icon.swiftName)\n"
        }
        
        code += """
        
            /// Returns a SwiftUI Path for this icon
            public var path: Path {
                switch self {
        
        """
        
        // Generate lab path switches
        for icon in labIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return Self.\(icon.swiftName)Path\n"
        }
        
        code += """
                }
            }
            
            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideShape {
                LucideShape(path: self.path)
            }
        
        """
        
        // Generate lab path definitions
        for icon in labIcons {
            code += generatePathStaticProperty(for: icon)
        }
        
        code += "}\n\n"
        
        code += """
        // MARK: - Convenient Access
        
        public struct Lucide {
        
        """
        
        // Generate regular static properties
        for icon in regularIcons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon\n"
            code += "    public static let \(icon.swiftName): LucideShape = LucideShape(path: LucideIconName.\(icon.swiftName)Path)\n\n"
        }
        
        code += "}\n\n"
        
        code += """
        public struct LucideLab {
        
        """
        
        // Generate lab static properties
        for icon in labIcons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon (Experimental)\n"
            code += "    public static let \(icon.swiftName): LucideShape = LucideShape(path: LucideLabIconName.\(icon.swiftName)Path)\n\n"
        }
        
        code += "}\n\n"
        
        code += """
        // MARK: - Version Information
        
        /// Version information for LucideSwift
        public struct LucideVersions {
            /// The version of the LucideSwift library (from git tags)
            public static let libraryVersion = "\(libraryVersion)"
            
            /// The version of upstream Lucide Icons bundled with this release
            public static let lucideVersion = "\(lucideVersion)"
            
            /// The version of upstream Lucide Lab icons bundled with this release
            public static let lucideLabVersion = "\(lucideLabVersion)"
        }
        """
        
        return code
    }
    
    private static func generatePathStaticProperty(for icon: Icon) -> String {
        var pathCode = ""
        for pathString in icon.pathStrings {
            do {
                let options = SVGPath.ParseOptions(invertYAxis: false)
                let svgPath = try SVGPath(string: pathString, with: options)
                let cgPath = CGPath.from(svgPath)
                pathCode += convertToSwiftPathCode(cgPath: cgPath)
            } catch {
                print("⚠️  Failed to parse path for \(icon.name): \(error)")
            }
        }
        
        var code = "        \n"
        code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon path\n"
        code += "    static let \(icon.swiftName)Path: Path = {\n"
        code += "        var path = Path()\n"
        code += "        \(pathCode)"
        code += "        return path\n"
        code += "    }()\n"
        return code
    }
    
    private static func convertToSwiftPathCode(cgPath: CGPath) -> String {
        var code = ""
        var currentPoint: CGPoint?
        
        cgPath.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            let points = element.points
            
            switch element.type {
            case .moveToPoint:
                let point = points[0]
                code += "path.move(to: CGPoint(x: \(point.x), y: \(point.y)))\n"
                currentPoint = point
                
            case .addLineToPoint:
                let endPoint = points[0]
                if let start = currentPoint {
                    let dx = endPoint.x - start.x
                    let dy = endPoint.y - start.y
                    let distance = sqrt(dx * dx + dy * dy)
                    if distance < 0.1 && distance > 0 {
                        let radius = 0.35
                        code += "path.addEllipse(in: CGRect(x: \(endPoint.x - radius), y: \(endPoint.y - radius), width: \(radius * 2), height: \(radius * 2)))\n"
                    } else {
                        code += "path.addLine(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)))\n"
                    }
                } else {
                    code += "path.addLine(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)))\n"
                }
                currentPoint = endPoint
                
            case .addQuadCurveToPoint:
                let controlPoint = points[0]
                let endPoint = points[1]
                code += "path.addQuadCurve(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)), control: CGPoint(x: \(controlPoint.x), y: \(controlPoint.y)))\n"
                currentPoint = endPoint
                
            case .addCurveToPoint:
                let controlPoint1 = points[0]
                let controlPoint2 = points[1]
                let endPoint = points[2]
                code += "path.addCurve(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)), control1: CGPoint(x: \(controlPoint1.x), y: \(controlPoint1.y)), control2: CGPoint(x: \(controlPoint2.x), y: \(controlPoint2.y)))\n"
                currentPoint = endPoint
                
            case .closeSubpath:
                code += "path.closeSubpath()\n"
                currentPoint = nil
                
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
    
    var icons: [Icon] = []
    
    // Process Regular Icons
    print("📦 Cloning Lucide repository...")
    let regularPath = Config.tempDirectory.appendingPathComponent("lucide")
    try clone(url: Config.lucideRepoURL, to: regularPath, branch: Config.lucideVersion)
    icons.append(contentsOf: try parseIcons(in: regularPath, type: .regular))
    
    // Process Lab Icons
    print("📦 Cloning Lucide Lab repository...")
    let labPath = Config.tempDirectory.appendingPathComponent("lucide-lab")
    try clone(url: Config.lucideLabRepoURL, to: labPath, branch: Config.lucideLabVersion)
    icons.append(contentsOf: try parseIcons(in: labPath, type: .lab))
    
    print("✅ Parsed \(icons.count) total icons (\(icons.filter { $0.type == .regular }.count) regular, \(icons.filter { $0.type == .lab }.count) lab)")
    
    // Add extra icons
    icons.append(contentsOf: Config.extraIcons)
    
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

func clone(url: String, to path: URL, branch: String) throws {
    #if os(macOS)
    // Check if branch is a commit SHA (40 hex characters)
    let isCommitSHA = branch.count == 40 && branch.range(of: "^[a-f0-9]+$", options: .regularExpression) != nil
    
    if isCommitSHA {
        // For commit SHAs, we need to clone without --depth 1, then checkout
        print("  Detected commit SHA, cloning full repo...")
        let cloneProcess = Process()
        cloneProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        cloneProcess.arguments = ["clone", url, path.path]
        try cloneProcess.run()
        cloneProcess.waitUntilExit()
        if cloneProcess.terminationStatus != 0 {
            throw GeneratorError.cloneFailed
        }
        
        // Checkout the specific commit
        let checkoutProcess = Process()
        checkoutProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        checkoutProcess.arguments = ["-C", path.path, "checkout", branch]
        try checkoutProcess.run()
        checkoutProcess.waitUntilExit()
        if checkoutProcess.terminationStatus != 0 {
            throw GeneratorError.cloneFailed
        }
    } else {
        // For branches/tags, use shallow clone
        let cloneProcess = Process()
        cloneProcess.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        cloneProcess.arguments = ["clone", "--depth", "1", "--branch", branch, url, path.path]
        try cloneProcess.run()
        cloneProcess.waitUntilExit()
        if cloneProcess.terminationStatus != 0 {
            throw GeneratorError.cloneFailed
        }
    }
    #else
    throw GeneratorError.unsupportedPlatform
    #endif
}

func parseIcons(in path: URL, type: IconType) throws -> [Icon] {
    let fileManager = FileManager.default
    let iconsDirectory = path.appendingPathComponent(Config.iconsPath)
    
    // Check if icons directory exists, some repos might have it at root or elsewhere
    // but Lucide and Lucide-Lab use 'icons/'
    guard fileManager.fileExists(atPath: iconsDirectory.path) else {
        print("⚠️  Warning: Icons directory not found at \(iconsDirectory.path)")
        return []
    }
    
    let contents = try fileManager.contentsOfDirectory(at: iconsDirectory, includingPropertiesForKeys: nil)
    let svgFiles = contents.filter { $0.pathExtension == "svg" }
    
    var icons: [Icon] = []
    for svgFile in svgFiles {
        let name = svgFile.deletingPathExtension().lastPathComponent
        do {
            let svgContent = try String(contentsOf: svgFile, encoding: .utf8)
            let pathStrings = SVGParser.extractPaths(from: svgContent)
            if !pathStrings.isEmpty {
                icons.append(Icon(name: name, pathStrings: pathStrings, type: type))
            }
        } catch {
            print("⚠️  Could not parse: \(name) - \(error)")
        }
    }
    return icons
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
