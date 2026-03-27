//
//  SVGPathParser.swift
//  LucideSwift
//
//  Parses SVG path data into Swift Path commands
//

import Foundation

/// Represents a parsed SVG path command with absolute coordinates
struct SVGPathCommand {
    enum CommandType {
        case moveTo
        case lineTo
        case curveTo  // Cubic bezier
        case quadCurveTo  // Quadratic bezier
        case arcTo
        case closePath
    }
    
    let type: CommandType
    let values: [CGFloat]  // All values in absolute coordinates
}

/// Parses SVG path data strings and converts to absolute coordinates
enum SVGPathParser {
    static func parse(pathData: String) -> [SVGPathCommand] {
        var commands: [SVGPathCommand] = []
        var currentIndex = pathData.startIndex
        var currentValues: [CGFloat] = []
        var currentCommand: Character?
        var numberBuffer = ""
        
        // Current position for relative coordinate calculations
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var subpathStartX: CGFloat = 0
        var subpathStartY: CGFloat = 0
        
        // Previous control point for smooth curves
        var lastControlX: CGFloat = 0
        var lastControlY: CGFloat = 0
        
        func flushNumber() {
            if !numberBuffer.isEmpty, let value = Double(numberBuffer) {
                currentValues.append(CGFloat(value))
                numberBuffer = ""
            }
        }
        
        func flushCommand() {
            flushNumber()
            guard let cmd = currentCommand else { return }
            let isRelative = cmd.isLowercase
            
            switch cmd {
            case "M", "m":
                // Move to: x y
                while currentValues.count >= 2 {
                    var x = currentValues[0]
                    var y = currentValues[1]
                    
                    if isRelative {
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .moveTo, values: [x, y]))
                    currentX = x
                    currentY = y
                    subpathStartX = x
                    subpathStartY = y
                    
                    currentValues.removeFirst(2)
                }
                // Subsequent pairs are treated as lineTo
                while currentValues.count >= 2 {
                    var x = currentValues[0]
                    var y = currentValues[1]
                    
                    if isRelative {
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .lineTo, values: [x, y]))
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(2)
                }
                
            case "L", "l":
                // Line to: x y
                while currentValues.count >= 2 {
                    var x = currentValues[0]
                    var y = currentValues[1]
                    
                    if isRelative {
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .lineTo, values: [x, y]))
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(2)
                }
                
            case "H", "h":
                // Horizontal line: x
                while !currentValues.isEmpty {
                    var x = currentValues[0]
                    
                    if isRelative {
                        x += currentX
                    }
                    
                    commands.append(SVGPathCommand(type: .lineTo, values: [x, currentY]))
                    currentX = x
                    
                    currentValues.removeFirst(1)
                }
                
            case "V", "v":
                // Vertical line: y
                while !currentValues.isEmpty {
                    var y = currentValues[0]
                    
                    if isRelative {
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .lineTo, values: [currentX, y]))
                    currentY = y
                    
                    currentValues.removeFirst(1)
                }
                
            case "C", "c":
                // Cubic bezier: x1 y1 x2 y2 x y
                while currentValues.count >= 6 {
                    var x1 = currentValues[0]
                    var y1 = currentValues[1]
                    var x2 = currentValues[2]
                    var y2 = currentValues[3]
                    var x = currentValues[4]
                    var y = currentValues[5]
                    
                    if isRelative {
                        x1 += currentX
                        y1 += currentY
                        x2 += currentX
                        y2 += currentY
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .curveTo, values: [x1, y1, x2, y2, x, y]))
                    
                    lastControlX = x2
                    lastControlY = y2
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(6)
                }
                
            case "S", "s":
                // Smooth cubic bezier: x2 y2 x y
                while currentValues.count >= 4 {
                    var x2 = currentValues[0]
                    var y2 = currentValues[1]
                    var x = currentValues[2]
                    var y = currentValues[3]
                    
                    if isRelative {
                        x2 += currentX
                        y2 += currentY
                        x += currentX
                        y += currentY
                    }
                    
                    // First control point is reflection of last control point
                    let x1 = 2 * currentX - lastControlX
                    let y1 = 2 * currentY - lastControlY
                    
                    commands.append(SVGPathCommand(type: .curveTo, values: [x1, y1, x2, y2, x, y]))
                    
                    lastControlX = x2
                    lastControlY = y2
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(4)
                }
                
            case "Q", "q":
                // Quadratic bezier: x1 y1 x y
                while currentValues.count >= 4 {
                    var x1 = currentValues[0]
                    var y1 = currentValues[1]
                    var x = currentValues[2]
                    var y = currentValues[3]
                    
                    if isRelative {
                        x1 += currentX
                        y1 += currentY
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .quadCurveTo, values: [x1, y1, x, y]))
                    
                    lastControlX = x1
                    lastControlY = y1
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(4)
                }
                
            case "T", "t":
                // Smooth quadratic bezier: x y
                while currentValues.count >= 2 {
                    var x = currentValues[0]
                    var y = currentValues[1]
                    
                    if isRelative {
                        x += currentX
                        y += currentY
                    }
                    
                    // Control point is reflection of last control point
                    let x1 = 2 * currentX - lastControlX
                    let y1 = 2 * currentY - lastControlY
                    
                    commands.append(SVGPathCommand(type: .quadCurveTo, values: [x1, y1, x, y]))
                    
                    lastControlX = x1
                    lastControlY = y1
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(2)
                }
                
            case "A", "a":
                // Arc: rx ry x-axis-rotation large-arc-flag sweep-flag x y
                while currentValues.count >= 7 {
                    let rx = currentValues[0]
                    let ry = currentValues[1]
                    let rotation = currentValues[2]
                    let largeArc = currentValues[3]
                    let sweep = currentValues[4]
                    var x = currentValues[5]
                    var y = currentValues[6]
                    
                    if isRelative {
                        x += currentX
                        y += currentY
                    }
                    
                    commands.append(SVGPathCommand(type: .arcTo, values: [rx, ry, rotation, largeArc, sweep, x, y]))
                    
                    currentX = x
                    currentY = y
                    
                    currentValues.removeFirst(7)
                }
                
            case "Z", "z":
                commands.append(SVGPathCommand(type: .closePath, values: []))
                currentX = subpathStartX
                currentY = subpathStartY
                
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
