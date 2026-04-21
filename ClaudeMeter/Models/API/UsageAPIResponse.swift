//
//  UsageAPIResponse.swift
//  ClaudeMeter
//
//  Created by Edd on 2025-11-14.
//

import Foundation

/// Flexible coding key that accepts any string key from the JSON response.
private struct AnyCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int? = nil
    init(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}

/// Individual usage limit from the API
struct UsageLimitResponse: Codable {
    let utilization: Double
    let resetsAt: String?

    enum CodingKeys: String, CodingKey {
        case utilization
        case resetsAt = "resets_at"
    }
}

/// Mapping error for API response conversion
enum MappingError: LocalizedError {
    case invalidDateFormat
    case missingCriticalField(field: String)

    var errorDescription: String? {
        switch self {
        case .invalidDateFormat:
            return "Server returned invalid date format"
        case .missingCriticalField(let field):
            return "Server response missing critical field: \(field)"
        }
    }
}

/// Dynamically decoded API response.
/// Captures any non-null five_hour / seven_day* field — new metrics added by
/// Anthropic are discovered automatically without an app update.
struct UsageAPIResponse: Decodable {
    let discoveredMetrics: [DiscoveredMetric]
    let metricLimits: [String: UsageLimitResponse]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnyCodingKey.self)

        var metrics: [DiscoveredMetric] = []
        var limits: [String: UsageLimitResponse] = [:]

        for key in container.allKeys {
            let k = key.stringValue
            guard k == "five_hour" || k.hasPrefix("seven_day") else { continue }

            // Decode the value; skip nulls and objects that don't match UsageLimitResponse
            guard let response = try? container.decodeIfPresent(UsageLimitResponse.self, forKey: key) else { continue }

            let metric = DiscoveredMetric(key: k, displayName: DiscoveredMetric.displayName(for: k))
            metrics.append(metric)
            limits[k] = response
        }

        self.discoveredMetrics = DiscoveredMetric.sorted(metrics)
        self.metricLimits = limits
    }

    func toDomain() throws -> UsageData {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        guard let sessionResponse = metricLimits["five_hour"],
              let sessionResetStr = sessionResponse.resetsAt,
              let sessionResetDate = formatter.date(from: sessionResetStr) else {
            throw MappingError.missingCriticalField(field: "five_hour.resets_at")
        }

        guard let weeklyResponse = metricLimits["seven_day"],
              let weeklyResetStr = weeklyResponse.resetsAt,
              let weeklyResetDate = formatter.date(from: weeklyResetStr) else {
            throw MappingError.missingCriticalField(field: "seven_day.resets_at")
        }

        var metricValues: [String: UsageLimit] = [:]
        for (key, response) in metricLimits {
            let resetDate: Date
            if let s = response.resetsAt, let d = formatter.date(from: s) {
                resetDate = d
            } else {
                resetDate = Date().addingTimeInterval(7 * 24 * 3600)
            }
            metricValues[key] = UsageLimit(utilization: response.utilization, resetAt: resetDate)
        }

        return UsageData(
            sessionUsage: UsageLimit(utilization: sessionResponse.utilization, resetAt: sessionResetDate),
            weeklyUsage:  UsageLimit(utilization: weeklyResponse.utilization,  resetAt: weeklyResetDate),
            discoveredMetrics: discoveredMetrics,
            metricValues: metricValues,
            lastUpdated: Date()
        )
    }
}
