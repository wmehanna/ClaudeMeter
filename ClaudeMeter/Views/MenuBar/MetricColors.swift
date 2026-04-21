import SwiftUI

/// Returns the display color for a metric key in icon views.
/// Session (five_hour) uses the live status color; all others use fixed hues.
func metricColor(forKey key: String, status: UsageStatus, isStale: Bool) -> Color {
    guard !isStale else { return .gray }
    switch key {
    case "five_hour":          return status.color
    case "seven_day":          return .purple
    case "seven_day_sonnet":   return .orange
    case "seven_day_omelette": return .teal
    case "seven_day_opus":     return .indigo
    case "seven_day_cowork":   return .green
    default:
        let palette: [Color] = [.mint, .cyan, .pink, .brown, .yellow]
        return palette[abs(key.hashValue) % palette.count]
    }
}

/// Returns a stable tint color for use in non-status-aware UI (e.g. metric picker buttons).
func metricTintColor(forKey key: String) -> Color {
    switch key {
    case "five_hour":          return .blue
    case "seven_day":          return .purple
    case "seven_day_sonnet":   return .orange
    case "seven_day_omelette": return .teal
    case "seven_day_opus":     return .indigo
    case "seven_day_cowork":   return .green
    default:
        let palette: [Color] = [.mint, .cyan, .pink, .brown, .yellow]
        return palette[abs(key.hashValue) % palette.count]
    }
}
