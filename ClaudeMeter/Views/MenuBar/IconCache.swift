import AppKit

final class IconCache {
    private let cache = NSCache<NSString, NSImage>()

    init() { cache.countLimit = Constants.Cache.maxIconCacheSize }

    func get(metricValues: [String: Double], status: UsageStatus, isLoading: Bool, isStale: Bool,
             iconStyle: IconStyle, fontSize: Double = 12, singleMetricKey: String = "five_hour",
             customPillsMetrics: [DiscoveredMetric] = [], customBarMetrics: [DiscoveredMetric] = [],
             dualBarMetrics: [DiscoveredMetric] = [], claudeOperational: Bool = true) -> NSImage? {
        cache.object(forKey: cacheKey(metricValues, status, isLoading, isStale, iconStyle,
                                     fontSize, singleMetricKey,
                                     customPillsMetrics, customBarMetrics, dualBarMetrics, claudeOperational))
    }

    // swiftlint:disable:next function_parameter_count
    func set(_ image: NSImage, metricValues: [String: Double], status: UsageStatus, isLoading: Bool,
             isStale: Bool, iconStyle: IconStyle, fontSize: Double = 12,
             singleMetricKey: String = "five_hour", customPillsMetrics: [DiscoveredMetric] = [],
             customBarMetrics: [DiscoveredMetric] = [], dualBarMetrics: [DiscoveredMetric] = [],
             claudeOperational: Bool = true) {
        cache.setObject(image, forKey: cacheKey(
            metricValues, status, isLoading, isStale, iconStyle,
            fontSize, singleMetricKey,
            customPillsMetrics, customBarMetrics, dualBarMetrics, claudeOperational
        ))
    }

    // swiftlint:disable:next function_parameter_count
    private func cacheKey(
        _ metrics: [String: Double], _ usageStatus: UsageStatus,
        _ loading: Bool, _ stale: Bool,
        _ style: IconStyle, _ fontSize: Double, _ singleKey: String,
        _ pillsMetrics: [DiscoveredMetric], _ barMetrics: [DiscoveredMetric],
        _ dualMetrics: [DiscoveredMetric], _ operational: Bool
    ) -> NSString {
        let values = metrics.sorted { $0.key < $1.key }
            .map { "\($0.key):\(String(format: "%.2f", $0.value))" }
            .joined(separator: ",")
        let metricKeys = [
            singleKey,
            pillsMetrics.map(\.key).joined(separator: ","),
            barMetrics.map(\.key).joined(separator: ","),
            dualMetrics.map(\.key).joined(separator: ",")
        ].joined(separator: "|")
        let key = "\(values)|\(String(format: "%.1f", fontSize))|\(usageStatus.rawValue)"
            + "|\(loading)|\(stale)|\(style.rawValue)|\(metricKeys)|\(operational)"
        return key as NSString
    }
}
