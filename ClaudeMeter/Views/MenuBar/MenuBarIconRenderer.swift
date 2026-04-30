import AppKit
import SwiftUI

@MainActor
struct MenuBarIconRenderer {
    func render(metricValues: [String: Double], status: UsageStatus, isLoading: Bool, isStale: Bool,
                iconStyle: IconStyle, fontSize: Double = 12, singleMetricKey: String = "five_hour",
                customPillsMetrics: [DiscoveredMetric] = [],
                customBarMetrics: [DiscoveredMetric] = [],
                dualBarMetrics: [DiscoveredMetric] = [],
                claudeOperational: Bool = true) -> NSImage {
        let iconView = MenuBarIconView(
            metricValues: metricValues, status: status, isLoading: isLoading, isStale: isStale,
            iconStyle: iconStyle, fontSize: fontSize, singleMetricKey: singleMetricKey,
            customPillsMetrics: customPillsMetrics, customBarMetrics: customBarMetrics,
            dualBarMetrics: dualBarMetrics, claudeOperational: claudeOperational
        )

        let renderer = ImageRenderer(content: iconView)
        renderer.scale = NSScreen.main?.backingScaleFactor ?? 2.0

        guard let nsImage = renderer.nsImage else {
            return NSImage(systemSymbolName: "exclamationmark.triangle", accessibilityDescription: "Error") ?? NSImage()
        }
        nsImage.isTemplate = false
        return nsImage
    }
}
