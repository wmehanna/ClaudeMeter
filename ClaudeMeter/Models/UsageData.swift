//
//  UsageData.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Complete usage data. metricValues holds every non-null metric discovered
/// from the API response, keyed by the API field name.
struct UsageData: Codable, Equatable, Sendable {
    let sessionUsage: UsageLimit
    let weeklyUsage: UsageLimit
    let discoveredMetrics: [DiscoveredMetric]
    let metricValues: [String: UsageLimit]
    let lastUpdated: Date

    init(sessionUsage: UsageLimit, weeklyUsage: UsageLimit,
         discoveredMetrics: [DiscoveredMetric] = [],
         metricValues: [String: UsageLimit] = [:],
         lastUpdated: Date) {
        self.sessionUsage = sessionUsage
        self.weeklyUsage = weeklyUsage
        self.discoveredMetrics = discoveredMetrics
        self.metricValues = metricValues
        self.lastUpdated = lastUpdated
    }

    enum CodingKeys: String, CodingKey {
        case sessionUsage      = "session_usage"
        case weeklyUsage       = "weekly_usage"
        case discoveredMetrics = "discovered_metrics"
        case metricValues      = "metric_values"
        case lastUpdated       = "last_updated"
    }
}

extension UsageData {
    var primaryStatus: UsageStatus { sessionUsage.status }

    var isStale: Bool {
        Date().timeIntervalSince(lastUpdated) > Constants.Refresh.stalenessThreshold
    }

    func value(forKey key: String) -> Double {
        metricValues[key]?.utilization ?? 0
    }
}
