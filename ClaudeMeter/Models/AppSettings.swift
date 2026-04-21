//
//  AppSettings.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

private struct AnyStringKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil
    init(_ value: String) { stringValue = value }
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

/// User preferences and app configuration
struct AppSettings: Codable, Equatable, Sendable {
    var refreshInterval: TimeInterval
    var hasNotificationsEnabled: Bool
    var notificationThresholds: NotificationThresholds
    var isFirstLaunch: Bool
    var cachedOrganizationId: UUID?
    var iconStyle: IconStyle
    var customPillsFontSize: Double

    // Metric keys (API field names) for each icon style
    var singleMetricKey: String
    var customPillsKeys: [String]
    var customBarKeys: [String]
    var dualBarKeys: [String]

    // Popover display
    var isSonnetUsageShown: Bool  // kept for migration compat; logic now uses popoverHiddenKeys
    var isClaudeDesignUsageShown: Bool
    var popoverHiddenKeys: [String]  // metrics hidden in the popover

    static let `default` = AppSettings(
        refreshInterval: 60,
        hasNotificationsEnabled: true,
        notificationThresholds: .default,
        isFirstLaunch: true,
        cachedOrganizationId: nil,
        iconStyle: .battery,
        customPillsFontSize: 12,
        singleMetricKey: "five_hour",
        customPillsKeys: ["five_hour", "seven_day", "seven_day_sonnet"],
        customBarKeys:   ["five_hour", "seven_day", "seven_day_sonnet"],
        dualBarKeys:     ["five_hour", "seven_day"],
        isSonnetUsageShown: true,
        isClaudeDesignUsageShown: false,
        popoverHiddenKeys: []
    )

    enum CodingKeys: String, CodingKey {
        case refreshInterval           = "refresh_interval"
        case hasNotificationsEnabled   = "notifications_enabled"
        case notificationThresholds    = "notification_thresholds"
        case isFirstLaunch             = "is_first_launch"
        case cachedOrganizationId      = "cached_organization_id"
        case iconStyle                 = "icon_style"
        case customPillsFontSize       = "custom_pills_font_size"
        case singleMetricKey           = "single_metric_key"
        case customPillsKeys           = "custom_pills_keys"
        case customBarKeys             = "custom_bar_keys"
        case dualBarKeys               = "dual_bar_keys"
        case isSonnetUsageShown        = "show_sonnet_usage"
        case isClaudeDesignUsageShown  = "show_claude_design_usage"
        case popoverHiddenKeys         = "popover_hidden_keys"
    }

    init(refreshInterval: TimeInterval, hasNotificationsEnabled: Bool,
         notificationThresholds: NotificationThresholds, isFirstLaunch: Bool,
         cachedOrganizationId: UUID?, iconStyle: IconStyle,
         customPillsFontSize: Double, singleMetricKey: String,
         customPillsKeys: [String], customBarKeys: [String], dualBarKeys: [String],
         isSonnetUsageShown: Bool, isClaudeDesignUsageShown: Bool,
         popoverHiddenKeys: [String]) {
        self.refreshInterval = refreshInterval
        self.hasNotificationsEnabled = hasNotificationsEnabled
        self.notificationThresholds = notificationThresholds
        self.isFirstLaunch = isFirstLaunch
        self.cachedOrganizationId = cachedOrganizationId
        self.iconStyle = iconStyle
        self.customPillsFontSize = customPillsFontSize
        self.singleMetricKey = singleMetricKey
        self.customPillsKeys = customPillsKeys
        self.customBarKeys = customBarKeys
        self.dualBarKeys = dualBarKeys
        self.isSonnetUsageShown = isSonnetUsageShown
        self.isClaudeDesignUsageShown = isClaudeDesignUsageShown
        self.popoverHiddenKeys = popoverHiddenKeys
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let anyC = try? decoder.container(keyedBy: AnyStringKey.self)
        refreshInterval         = try c.decode(TimeInterval.self,  forKey: .refreshInterval)
        hasNotificationsEnabled = try c.decode(Bool.self,          forKey: .hasNotificationsEnabled)
        notificationThresholds  = try c.decode(NotificationThresholds.self, forKey: .notificationThresholds)
        isFirstLaunch           = try c.decode(Bool.self,          forKey: .isFirstLaunch)
        cachedOrganizationId    = try c.decodeIfPresent(UUID.self, forKey: .cachedOrganizationId)
        iconStyle               = (try? c.decode(IconStyle.self,   forKey: .iconStyle)) ?? .battery
        customPillsFontSize     = (try? c.decode(Double.self,      forKey: .customPillsFontSize)) ?? 12
        isSonnetUsageShown       = (try? c.decode(Bool.self,     forKey: .isSonnetUsageShown)) ?? true
        isClaudeDesignUsageShown = (try? c.decode(Bool.self,     forKey: .isClaudeDesignUsageShown)) ?? false
        let storedHidden         = try? c.decode([String].self, forKey: .popoverHiddenKeys)

        // Migrate old bool toggles → popoverHiddenKeys only when key was absent from storage
        if let h = storedHidden {
            popoverHiddenKeys = h
        } else {
            var hidden: [String] = []
            if !isSonnetUsageShown       { hidden.append("seven_day_sonnet") }
            if !isClaudeDesignUsageShown { hidden.append("seven_day_omelette") }
            popoverHiddenKeys = hidden
        }

        // Try new string-key format first; fall back to migrating old UsageMetric enum values
        singleMetricKey  = (try? c.decode(String.self,   forKey: .singleMetricKey))
                           ?? Self.migrateMetricKey(try? anyC?.decode(String.self, forKey: AnyStringKey("single_metric")))
                           ?? "five_hour"
        customPillsKeys  = (try? c.decode([String].self, forKey: .customPillsKeys))
                           ?? Self.migrateMetricKeys(try? anyC?.decode([String].self, forKey: AnyStringKey("custom_pills_metrics")))
                           ?? ["five_hour", "seven_day", "seven_day_sonnet"]
        customBarKeys    = (try? c.decode([String].self, forKey: .customBarKeys))
                           ?? Self.migrateMetricKeys(try? anyC?.decode([String].self, forKey: AnyStringKey("custom_bar_metrics")))
                           ?? ["five_hour", "seven_day", "seven_day_sonnet"]
        dualBarKeys      = (try? c.decode([String].self, forKey: .dualBarKeys))
                           ?? Self.migrateMetricKeys(try? anyC?.decode([String].self, forKey: AnyStringKey("dual_bar_metrics")))
                           ?? ["five_hour", "seven_day"]

        // Migrate iconStyle: handle old triplePills / tripleBar enum names
        if iconStyle == .battery,
           let rawStyle = try? c.decode(String.self, forKey: .iconStyle) {
            switch rawStyle {
            case "triplePills": iconStyle = .customPills
            case "tripleBar":   iconStyle = .customBar
            default: break
            }
        }
    }

    // MARK: - Migration helpers

    private static let legacyKeyMap: [String: String] = [
        "session":      "five_hour",
        "weekly":       "seven_day",
        "sonnet":       "seven_day_sonnet",
        "claude_design":"seven_day_omelette",
    ]

    private static func migrateMetricKey(_ old: String?) -> String? {
        guard let old else { return nil }
        return legacyKeyMap[old] ?? old
    }

    private static func migrateMetricKeys(_ old: [String]?) -> [String]? {
        guard let old else { return nil }
        return old.map { legacyKeyMap[$0] ?? $0 }
    }
}

extension AppSettings {
    mutating func setRefreshInterval(_ interval: TimeInterval) {
        refreshInterval = max(60, min(600, interval))
    }

    /// Returns true if the metric key should be shown in the popover
    func isPopoverVisible(key: String) -> Bool {
        !popoverHiddenKeys.contains(key)
    }
}
