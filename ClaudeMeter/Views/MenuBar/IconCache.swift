import AppKit

final class IconCache {
    private let cache = NSCache<NSString, NSImage>()

    init() { cache.countLimit = Constants.Cache.maxIconCacheSize }

    func get(metricValues: [String: Double], status: UsageStatus, isLoading: Bool, isStale: Bool,
             iconStyle: IconStyle, fontSize: Double = 12, singleMetricKey: String = "five_hour",
             customPillsMetrics: [DiscoveredMetric] = [], customBarMetrics: [DiscoveredMetric] = [],
             dualBarMetrics: [DiscoveredMetric] = []) -> NSImage? {
        cache.object(forKey: cacheKey(metricValues, status, isLoading, isStale, iconStyle,
                                     fontSize, singleMetricKey,
                                     customPillsMetrics, customBarMetrics, dualBarMetrics))
    }

    func set(_ image: NSImage, metricValues: [String: Double], status: UsageStatus, isLoading: Bool,
             isStale: Bool, iconStyle: IconStyle, fontSize: Double = 12,
             singleMetricKey: String = "five_hour", customPillsMetrics: [DiscoveredMetric] = [],
             customBarMetrics: [DiscoveredMetric] = [], dualBarMetrics: [DiscoveredMetric] = []) {
        cache.setObject(image, forKey: cacheKey(metricValues, status, isLoading, isStale, iconStyle,
                                                fontSize, singleMetricKey,
                                                customPillsMetrics, customBarMetrics, dualBarMetrics))
    }

    private func cacheKey(_ mv: [String: Double], _ s: UsageStatus, _ l: Bool, _ st: Bool,
                          _ i: IconStyle, _ fs: Double, _ sm: String,
                          _ pm: [DiscoveredMetric], _ bm: [DiscoveredMetric],
                          _ dm: [DiscoveredMetric]) -> NSString {
        let values = mv.sorted { $0.key < $1.key }
            .map { "\($0.key):\(String(format: "%.2f", $0.value))" }
            .joined(separator: ",")
        let metricKeys = "\(sm)|\(pm.map(\.key).joined(separator:","))|\(bm.map(\.key).joined(separator:","))|\(dm.map(\.key).joined(separator:","))"
        return "\(values)|\(String(format: "%.1f", fs))|\(s.rawValue)|\(l)|\(st)|\(i.rawValue)|\(metricKeys)" as NSString
    }
}
