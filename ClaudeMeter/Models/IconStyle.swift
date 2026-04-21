//
//  IconStyle.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-12-28.
//

import Foundation

/// Menu bar icon display style
enum IconStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case battery        // Gradient bar + percentage (DEFAULT)
    case circular       // Donut gauge with percentage in center
    case minimal        // Just color-coded percentage text
    case segments       // 5 segments like signal bars
    case dualBar        // Two stacked bars (customizable metrics)
    case customBar      // Up to 3 stacked bars (customizable metrics)
    case customPills    // Up to 3 inline percentages (customizable metrics)
    case gauge          // SF Symbol gauge icon

    var id: String { rawValue }

    /// Display name for settings UI
    var displayName: String {
        switch self {
        case .battery: return "Battery"
        case .circular: return "Circular"
        case .minimal: return "Minimal"
        case .segments: return "Segments"
        case .dualBar:     return "Dual Bar"
        case .customBar:   return "Custom Bar"
        case .customPills: return "Custom Pills"
        case .gauge:       return "Gauge"
        }
    }

    /// Description for accessibility
    var accessibilityDescription: String {
        switch self {
        case .battery: return "Battery-style bar with percentage"
        case .circular: return "Circular gauge with percentage in center"
        case .minimal: return "Minimal percentage only"
        case .segments: return "Segmented bar indicator"
        case .dualBar:     return "Two stacked bars with customizable metrics"
        case .customBar:   return "Up to three stacked bars with customizable metrics"
        case .customPills: return "Up to three inline percentages with customizable metrics"
        case .gauge:       return "Gauge indicator"
        }
    }
}
