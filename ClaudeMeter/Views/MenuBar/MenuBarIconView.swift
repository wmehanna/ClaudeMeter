import SwiftUI

/// SwiftUI view for menu bar icon with configurable style
struct MenuBarIconView: View {
    let metricValues: [String: Double]
    let status: UsageStatus
    let isLoading: Bool
    let isStale: Bool
    let iconStyle: IconStyle
    var fontSize: Double = 12
    var singleMetricKey: String = "five_hour"
    var customPillsMetrics: [DiscoveredMetric] = DiscoveredMetric.defaults
    var customBarMetrics: [DiscoveredMetric] = DiscoveredMetric.defaults
    var dualBarMetrics: [DiscoveredMetric] = Array(DiscoveredMetric.defaults.prefix(2))
    var claudeOperational: Bool = true

    private var singleValue: Double { metricValues[singleMetricKey] ?? 0 }

    private var singleStatus: UsageStatus {
        let pct = singleValue
        switch pct {
        case 0..<Constants.Thresholds.Status.warningStart:
            return .safe
        case Constants.Thresholds.Status.warningStart..<Constants.Thresholds.Status.criticalStart:
            return .warning
        default:
            return .critical
        }
    }

    var body: some View {
        HStack(spacing: 3) {
            switch iconStyle {
            case .battery:
                BatteryIcon(percentage: singleValue, status: singleStatus, isLoading: isLoading, isStale: isStale)
            case .circular:
                CircularGaugeIcon(percentage: singleValue, status: singleStatus, isLoading: isLoading, isStale: isStale)
            case .minimal:
                MinimalIcon(percentage: singleValue, status: singleStatus, isLoading: isLoading, isStale: isStale)
            case .segments:
                SegmentedBarIcon(percentage: singleValue, status: singleStatus, isLoading: isLoading, isStale: isStale)
            case .dualBar:
                DualBarIcon(metrics: dualBarMetrics, metricValues: metricValues,
                            status: status, isLoading: isLoading, isStale: isStale)
            case .customBar:
                CustomBarIcon(metrics: customBarMetrics, metricValues: metricValues,
                              status: status, isLoading: isLoading, isStale: isStale)
            case .customPills:
                CustomPillsIcon(metrics: customPillsMetrics, metricValues: metricValues,
                                status: status, isLoading: isLoading, isStale: isStale, fontSize: fontSize)
            case .gauge:
                GaugeIcon(percentage: singleValue, status: singleStatus, isLoading: isLoading, isStale: isStale)
            }

            Circle()
                .fill(claudeOperational ? Color.green : Color.red)
                .frame(width: 8, height: 8)
        }
    }
}

#Preview("All Styles") {
    let values: [String: Double] = ["five_hour": 65, "seven_day": 45, "seven_day_sonnet": 77, "seven_day_omelette": 12]
    VStack(alignment: .leading, spacing: 12) {
        ForEach(IconStyle.allCases) { style in
            HStack {
                Text(style.displayName).frame(width: 100, alignment: .leading)
                MenuBarIconView(metricValues: values, status: .warning, isLoading: false, isStale: false,
                                iconStyle: style)
            }
        }
    }
    .padding()
}
