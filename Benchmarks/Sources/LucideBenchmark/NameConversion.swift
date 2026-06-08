import Foundation

/// Converts between LucideSwift camelCase icon names and lucide-icons-swift kebab-case IDs.
///
/// The generator's kebab→camelCase transform is lossy: dashes are removed, subsequent
/// segments are capitalized, and reserved Swift keywords get an "Icon" suffix.
/// We reverse this as accurately as possible for benchmark comparison.
enum NameConversion {

    /// Swift reserved keywords that receive an "Icon" suffix during generation.
    private static let reservedKeywords: Set<String> = [
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
        "async", "await", "yield", "each", "any", "some", "package",
    ]

    /// Convert a LucideSwift camelCase name back to the kebab-case ID used by
    /// lucide-icons-swift (and the upstream Lucide icon set).
    ///
    /// Examples:
    /// - "airVent" → "air-vent"
    /// - "axis3d" → "axis-3d"
    /// - "arrowDown01" → "arrow-down-01"
    /// - "importIcon" → "import" (reserved keyword)
    static func camelToKebab(_ camelCase: String) -> String {
        var name = camelCase

        // Undo reserved-keyword suffix: e.g. "importIcon" → "import"
        for keyword in reservedKeywords {
            let suffixed = keyword + "Icon"
            if name.hasPrefix(suffixed) && name.count == suffixed.count {
                // Exact match — the icon IS the keyword
                return keyword
            }
            // Also handle: the keyword followed by more segments, e.g. "importIconSomething"
            // But that wouldn't happen in practice since keywords only get the suffix
            // when the entire name IS the keyword.
        }

        // Check if the base name (minus trailing "Icon" if present) would be a keyword
        // Only when the name ends with "Icon" and removing it gives a reserved keyword
        if name.hasSuffix("Icon") {
            let base = String(name.dropLast(4))
            if reservedKeywords.contains(base) {
                return base
            }
        }

        // Build kebab-case: insert dash before uppercase letters and at
        // letter↔digit and digit↔letter boundaries.
        var result = ""
        var previousWasDigit = false
        let scalars = Array(name.unicodeScalars)

        for (i, scalar) in scalars.enumerated() {
            let isUpper = CharacterSet.uppercaseLetters.contains(scalar)
            let isDigit = CharacterSet.decimalDigits.contains(scalar)
            let isLower = CharacterSet.lowercaseLetters.contains(scalar)

            // Insert dash before uppercase, but NOT when it follows a digit
            // (e.g. axis3D → axis-3d, not axis-3-d; grid2X2 → grid-2x2, not grid-2-x-2)
            if i > 0 && isUpper {
                let prevScalar = scalars[i - 1]
                if !CharacterSet.decimalDigits.contains(prevScalar) {
                    result += "-"
                }
            }

            // Insert dash at letter→digit boundaries, but NOT when this forms
            // a compact digit-letter-digit group (e.g. grid3X3 → grid-3x3, not grid-3x-3)
            // Only when the letter is NOT preceded by a digit.
            if i > 0 && isDigit {
                let prevScalar = scalars[i - 1]
                let prevIsLetter = CharacterSet.letters.contains(prevScalar)
                let prevIsDigit  = CharacterSet.decimalDigits.contains(prevScalar)

                // Dash before digit when preceded by a letter that wasn't itself after a digit
                if prevIsLetter && (i < 2 || !CharacterSet.decimalDigits.contains(scalars[i - 2])) {
                    if !result.hasSuffix("-") {
                        result += "-"
                    }
                }
                // Dash before digit when preceded by another digit (e.g. arrowDown01 → arrow-down-01)
                // The "01" part: the '0' already got a dash from letter→digit, '1' follows '0' — no new dash needed
            }

            result.append(isUpper ? Character(scalar).lowercased() : String(scalar))
        }

        return result
    }
}
