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
    static let iconsOutputDir = "Sources/LucideSwift/Icons"
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

    /// PascalCase file name, prefixed to avoid collisions with existing source files.
    /// e.g. "house" → "Icon_House.swift", "arrow-right" → "Icon_ArrowRight.swift"
    /// Lab: "house" → "Icon_Lab_House.swift"
    var fileName: String {
        let pascal = name.components(separatedBy: "-")
            .map { $0.capitalized }
            .joined()
        let scope = type == .lab ? "Lab_" : ""
        return "Icon_\(scope)\(pascal)"
    }

    /// Namespace enum type name, e.g. "LucideHouseIcon" or "LucideLabHouseIcon"
    var iconNamespaceEnum: String {
        let prefix = type == .lab ? "LucideLab" : "Lucide"
        return prefix + fileName
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
            code += "            return \(icon.iconNamespaceEnum).combinedPath\n"
        }
        
        code += """
                }
            }

            /// Returns a Path containing only the open subpaths (stroked in filled mode).
            public var openPath: Path {
                switch self {

        """

        for icon in regularIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return \(icon.iconNamespaceEnum).openPath\n"
        }

        code += """
                }
            }

            /// Returns a Path containing only the closed subpaths (filled in filled mode).
            public var closedPath: Path {
                switch self {

        """

        for icon in regularIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return \(icon.iconNamespaceEnum).closedPath\n"
        }

        code += """
                }
            }

            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideShape {
                LucideShape(combined: self.path, open: self.openPath, closed: self.closedPath)
            }

        """

        // Path data lives in individual icon files under Sources/LucideSwift/Icons/
        code += "\n}\n\n"

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
            code += "            return \(icon.iconNamespaceEnum).combinedPath\n"
        }
        
        code += """
                }
            }

            /// Returns a Path containing only the open subpaths (stroked in filled mode).
            public var openPath: Path {
                switch self {

        """

        for icon in labIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return \(icon.iconNamespaceEnum).openPath\n"
        }

        code += """
                }
            }

            /// Returns a Path containing only the closed subpaths (filled in filled mode).
            public var closedPath: Path {
                switch self {

        """

        for icon in labIcons {
            code += "        case .\(icon.swiftName):\n"
            code += "            return \(icon.iconNamespaceEnum).closedPath\n"
        }

        code += """
                }
            }

            /// Returns a SwiftUI Shape for this icon
            public var shape: LucideShape {
                LucideShape(combined: self.path, open: self.openPath, closed: self.closedPath)
            }

        """

        // Path data lives in individual icon files under Sources/LucideSwift/Icons/Lab/
        code += "\n}\n\n"
        
        code += """
        // MARK: - Convenient Access
        
        public struct Lucide {
        
        """
        
        // Generate regular static properties
        for icon in regularIcons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon\n"
            code += "    public static let \(icon.swiftName): LucideShape = LucideShape(combined: \(icon.iconNamespaceEnum).combinedPath, open: \(icon.iconNamespaceEnum).openPath, closed: \(icon.iconNamespaceEnum).closedPath)\n\n"
        }
        
        code += "}\n\n"
        
        code += """
        public struct LucideLab {
        
        """
        
        // Generate lab static properties
        for icon in labIcons {
            code += "    /// \(icon.name.replacingOccurrences(of: "-", with: " ").capitalized) icon (Experimental)\n"
            code += "    public static let \(icon.swiftName): LucideShape = LucideShape(combined: \(icon.iconNamespaceEnum).combinedPath, open: \(icon.iconNamespaceEnum).openPath, closed: \(icon.iconNamespaceEnum).closedPath)\n\n"
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
    
    /// Parse an SVG path string into a CGPath, correctly handling arc direction.
    ///
    /// Uses invertYAxis: true to let SVGPath compute arcs in y-up math space,
    /// then flips Y back to y-down for SwiftUI. This ensures arc sweep directions
    /// are interpreted correctly and bezier approximations stay within bounds.
    private static func parseSVGPath(_ pathString: String) throws -> CGPath {
        let options = SVGPath.ParseOptions(invertYAxis: true)
        let svgPath = try SVGPath(string: pathString, with: options)
        let cgPath = CGPath.from(svgPath)
        var flip = CGAffineTransform(scaleX: 1, y: -1)
        return cgPath.copy(using: &flip) ?? cgPath
    }

    private static func generatePathStaticProperty(for icon: Icon) -> String {
        var combinedPathCode = ""
        for pathString in icon.pathStrings {
            do {
                let cgPath = try parseSVGPath(pathString)
                combinedPathCode += convertToSwiftPathCode(cgPath: cgPath)
            } catch {
                print("⚠️  Failed to parse path for \(icon.name): \(error)")
            }
        }

        // Build the combined CGPath again to separate into open/closed subpaths
        var openPathCode = ""
        var closedPathCode = ""
        for pathString in icon.pathStrings {
            do {
                let cgPath = try parseSVGPath(pathString)
                let (open, closed) = separateCGPathIntoOpenAndClosed(cgPath: cgPath)
                openPathCode += convertToSwiftPathCode(cgPath: open)
                closedPathCode += convertToSwiftPathCode(cgPath: closed)
            } catch {
                // Already logged above
            }
        }

        let name = icon.name.replacingOccurrences(of: "-", with: " ").capitalized
        var code = "        \n"

        // Combined path (all subpaths)
        code += "    /// \(name) icon path (combined)\n"
        code += "    static let combinedPath: Path = {\n"
        code += "        var path = Path()\n"
        code += "        \(combinedPathCode)"
        code += "        return path\n"
        code += "    }()\n"

        // Open subpaths only
        code += "    /// \(name) icon open subpaths\n"
        code += "    static let openPath: Path = {\n"
        code += "        var path = Path()\n"
        code += "        \(openPathCode)"
        code += "        return path\n"
        code += "    }()\n"

        // Closed subpaths only
        code += "    /// \(name) icon closed subpaths\n"
        code += "    static let closedPath: Path = {\n"
        code += "        var path = Path()\n"
        code += "        \(closedPathCode)"
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
                        // Near-zero-length segment: round caps render this as a
                        // filled dot. Keep the path connected (no extra move)
                        // to preserve closed contours for .filled rendering.
                        code += "path.addLine(to: CGPoint(x: \(endPoint.x), y: \(endPoint.y)))\n"
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

    /// Separates a CGPath into open and closed subpaths.
    /// Mirrors the original runtime `separatePaths()` — a subpath is closed if it ends with
    /// `closeSubpath` or if its last point matches its first point (a geometric loop).
    private static func separateCGPathIntoOpenAndClosed(cgPath: CGPath) -> (open: CGPath, closed: CGPath) {
        let openMutable = CGMutablePath()
        let closedMutable = CGMutablePath()

        var currentSubpath = CGMutablePath()
        var startPoint: CGPoint?
        var lastPoint: CGPoint?
        var isExplicitlyClosed = false

        func finishCurrentSubpath() {
            guard !currentSubpath.isEmpty else { return }

            let isLoop = startPoint != nil && lastPoint != nil &&
                abs(startPoint!.x - lastPoint!.x) < 0.001 &&
                abs(startPoint!.y - lastPoint!.y) < 0.001
            let actuallyClosed = isExplicitlyClosed || isLoop

            if actuallyClosed {
                closedMutable.addPath(currentSubpath)
            } else {
                openMutable.addPath(currentSubpath)
            }
        }

        cgPath.applyWithBlock { elementPtr in
            let element = elementPtr.pointee
            let points = element.points

            switch element.type {
            case .moveToPoint:
                finishCurrentSubpath()
                currentSubpath = CGMutablePath()
                currentSubpath.move(to: points[0])
                startPoint = points[0]
                lastPoint = points[0]
                isExplicitlyClosed = false

            case .addLineToPoint:
                currentSubpath.addLine(to: points[0])
                lastPoint = points[0]

            case .addQuadCurveToPoint:
                currentSubpath.addQuadCurve(to: points[1], control: points[0])
                lastPoint = points[1]

            case .addCurveToPoint:
                currentSubpath.addCurve(to: points[2], control1: points[0], control2: points[1])
                lastPoint = points[2]

            case .closeSubpath:
                currentSubpath.closeSubpath()
                isExplicitlyClosed = true

            @unknown default:
                break
            }
        }

        finishCurrentSubpath()

        return (openMutable, closedMutable)
    }

    /// Generates a single icon file containing a namespace enum with the three static path properties.
    /// e.g. `Sources/LucideSwift/Icons/HouseIcon.swift`
    static func generateIconFile(icon: Icon) -> String {
        let pathData = generatePathStaticProperty(for: icon)
        // Strip the leading 4-space indent (was for embedding inside the main enum body)
        let dedented = pathData.components(separatedBy: "\n")
            .map { line in
                if line.hasPrefix("    ") {
                    return String(line.dropFirst(4))
                }
                if line.isEmpty { return line }
                return line
            }
            .joined(separator: "\n")

        let iconName = icon.name.replacingOccurrences(of: "-", with: " ").capitalized

        // Use caseless enum as a namespace for static stored properties
        return """
        //
        //  \(icon.fileName).swift
        //  LucideSwift
        //
        //  Auto-generated — DO NOT EDIT
        //  Icon: \(icon.name)
        //

        import SwiftUI

        /// \(iconName) icon
        internal enum \(icon.iconNamespaceEnum) {
        \(dedented)
        }

        """
    }

    /// Writes one Swift file per icon under `Sources/LucideSwift/Icons/`.
    /// Cleans the output directory first to remove stale files from previous generations.
    static func writeIconFiles(icons: [Icon]) throws {
        let fileManager = FileManager.default
        let baseDir = URL(fileURLWithPath: Config.iconsOutputDir)
        let labDir = baseDir.appendingPathComponent("Lab")

        // Clean directories
        if fileManager.fileExists(atPath: baseDir.path) {
            try fileManager.removeItem(at: baseDir)
        }
        try fileManager.createDirectory(at: labDir, withIntermediateDirectories: true)

        for icon in icons {
            let code = generateIconFile(icon: icon)
            let dir = icon.type == .lab ? labDir : baseDir
            let fileURL = dir.appendingPathComponent("\(icon.fileName).swift")
            try code.write(to: fileURL, atomically: true, encoding: .utf8)
        }
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
    
    // Write main generated file
    let outputURL = URL(fileURLWithPath: Config.outputFile)
    try swiftCode.write(to: outputURL, atomically: true, encoding: .utf8)
    print("✅ Generated: \(Config.outputFile)")

    // Write individual icon files
    print("📝 Writing individual icon files...")
    try SwiftCodeGenerator.writeIconFiles(icons: icons)
    print("✅ Generated \(icons.count) icon files in \(Config.iconsOutputDir)")

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
