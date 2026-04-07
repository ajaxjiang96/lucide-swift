//
//  SVGPathParser.swift
//  LucideSwift
//
//  SVG parsing logic for extracting path data from SVG content
//

import Foundation

/// A utility for extracting path data from SVG content
public struct SVGParser {
    
    /// Extracts all path data strings from the provided SVG content
    /// This includes both <path> elements and basic shapes (circles, rects, etc.) converted to path data
    /// - Parameter svgContent: The raw SVG string
    /// - Returns: An array of SVG path data strings
    public static func extractPaths(from svgContent: String) -> [String] {
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
