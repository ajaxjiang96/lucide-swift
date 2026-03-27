//
//  SVGPathParser.swift
//  LucideSwift
//
//  Parses SVG path data into Swift Path commands
//

import Foundation

/// Represents a parsed SVG path command
struct SVGPathCommand {
    enum CommandType {
        case moveTo
        case lineTo
        case curveTo
        case closePath
    }
    
    let type: CommandType
    let values: [CGFloat]
}

/// Parses SVG path data strings
enum SVGPathParser {
    static func parse(pathData: String) -> [SVGPathCommand] {
        var commands: [SVGPathCommand] = []
        var currentIndex = pathData.startIndex
        var currentValues: [CGFloat] = []
        var currentCommand: Character?
        var numberBuffer = ""
        
        func flushNumber() {
            if !numberBuffer.isEmpty, let value = Double(numberBuffer) {
                currentValues.append(CGFloat(value))
                numberBuffer = ""
            }
        }
        
        func flushCommand() {
            flushNumber()
            guard let cmd = currentCommand else { return }
            
            switch cmd {
            case "M", "m":
                if currentValues.count >= 2 {
                    commands.append(SVGPathCommand(type: .moveTo, values: Array(currentValues.prefix(2))))
                    currentValues.removeFirst(2)
                }
                // Subsequent pairs are treated as lineTo
                while currentValues.count >= 2 {
                    commands.append(SVGPathCommand(type: .lineTo, values: Array(currentValues.prefix(2))))
                    currentValues.removeFirst(2)
                }
                
            case "L", "l":
                while currentValues.count >= 2 {
                    commands.append(SVGPathCommand(type: .lineTo, values: Array(currentValues.prefix(2))))
                    currentValues.removeFirst(2)
                }
                
            case "H", "h":
                // Horizontal line - only x coordinate
                if let x = currentValues.first {
                    commands.append(SVGPathCommand(type: .lineTo, values: [x]))
                }
                
            case "V", "v":
                // Vertical line - only y coordinate
                if let y = currentValues.first {
                    commands.append(SVGPathCommand(type: .lineTo, values: [0, y]))
                }
                
            case "C", "c":
                // Cubic Bezier curve: x1 y1 x2 y2 x y
                while currentValues.count >= 6 {
                    commands.append(SVGPathCommand(type: .curveTo, values: Array(currentValues.prefix(6))))
                    currentValues.removeFirst(6)
                }
                
            case "Z", "z":
                commands.append(SVGPathCommand(type: .closePath, values: []))
                
            default:
                break
            }
            
            currentValues = []
        }
        
        while currentIndex < pathData.endIndex {
            let char = pathData[currentIndex]
            
            if char.isWhitespace || char == "," {
                flushNumber()
            } else if char.isLetter {
                flushCommand()
                currentCommand = char
            } else if char.isNumber || char == "." || char == "-" {
                // Handle negative numbers
                if char == "-" && !numberBuffer.isEmpty {
                    flushNumber()
                }
                numberBuffer.append(char)
            }
            
            currentIndex = pathData.index(after: currentIndex)
        }
        
        flushCommand()
        
        return commands
    }
}
