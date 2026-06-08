import Foundation

/// Converts between LucideSwift camelCase icon names and lucide-icons-swift kebab-case IDs.
enum NameConversion {

    /// Convert a camelCase name (e.g. "airVent") back to kebab-case (e.g. "air-vent")
    /// for use with lucide-icons-swift's `lucideId` parameter.
    static func camelToKebab(_ camelCase: String) -> String {
        var result = ""
        for char in camelCase {
            if char.isUppercase {
                result += "-"
                result += char.lowercased()
            } else {
                result.append(char)
            }
        }
        return result
    }
}
