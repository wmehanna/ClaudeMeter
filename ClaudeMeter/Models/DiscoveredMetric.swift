import Foundation

/// A usage metric discovered dynamically from the Claude API response.
/// New metrics added by Anthropic appear automatically without an app update.
struct DiscoveredMetric: Codable, Equatable, Hashable, Sendable, Identifiable {
    let key: String          // API field name, e.g. "seven_day_omelette"
    let displayName: String  // Human-readable label, e.g. "Design"

    var id: String { key }

    var isSession: Bool { key == "five_hour" }

    /// Derive a human-readable name from an API key.
    /// Known keys get curated names; unknown keys are auto-formatted.
    static func displayName(for key: String) -> String {
        let known: [String: String] = [
            "five_hour":           "Session",
            "seven_day":           "Weekly",
            "seven_day_sonnet":    "Sonnet",
            "seven_day_omelette":  "Design",
            "seven_day_opus":      "Opus",
            "seven_day_cowork":    "Cowork",
        ]
        if let name = known[key] { return name }

        // Strip "seven_day_" prefix and capitalize each word
        let stripped = key.hasPrefix("seven_day_") ? String(key.dropFirst("seven_day_".count)) : key
        return stripped
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined(separator: " ")
    }

    /// Stable fallback metrics used before the first API response arrives.
    static let defaults: [DiscoveredMetric] = [
        DiscoveredMetric(key: "five_hour",          displayName: "Session"),
        DiscoveredMetric(key: "seven_day",           displayName: "Weekly"),
        DiscoveredMetric(key: "seven_day_sonnet",    displayName: "Sonnet"),
        DiscoveredMetric(key: "seven_day_omelette",  displayName: "Design"),
    ]

    /// Default key ordering for display
    private static let sortOrder: [String: Int] = [
        "five_hour":          0,
        "seven_day":          1,
        "seven_day_sonnet":   2,
        "seven_day_omelette": 3,
        "seven_day_opus":     4,
        "seven_day_cowork":   5,
    ]

    static func sorted(_ metrics: [DiscoveredMetric]) -> [DiscoveredMetric] {
        metrics.sorted {
            let a = sortOrder[$0.key] ?? 99
            let b = sortOrder[$1.key] ?? 99
            return a == b ? $0.key < $1.key : a < b
        }
    }
}
