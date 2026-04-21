import SwiftUI

/// Inline percentage pills for selected metrics, e.g. "9%|58%|77%"
struct CustomPillsIcon: View {
    let metrics: [DiscoveredMetric]
    let metricValues: [String: Double]
    let status: UsageStatus
    let isLoading: Bool
    let isStale: Bool
    var fontSize: Double = 12

    var body: some View {
        HStack(spacing: 0) {
            if isLoading {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isStale ? .gray : status.color)
            } else {
                let visible = metrics.prefix(4)
                ForEach(Array(visible.enumerated()), id: \.offset) { idx, metric in
                    if idx > 0 { separator }
                    pill("\(Int(metricValues[metric.key] ?? 0))%",
                         color: metricColor(forKey: metric.key, status: status, isStale: isStale))
                }
            }
            if isStale && !isLoading {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                    .padding(.leading, 2)
            }
        }
        .frame(height: 22)
        .padding(.horizontal, 4)
        .accessibilityLabel(metrics.prefix(4).map { "\($0.displayName): \(Int(metricValues[$0.key] ?? 0))%" }.joined(separator: ", "))
    }

    private func pill(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: fontSize, weight: .semibold, design: .monospaced))
            .foregroundColor(color)
    }

    private var separator: some View {
        Text("|")
            .font(.system(size: max(9, fontSize - 1), weight: .light, design: .monospaced))
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 1)
    }
}

#Preview {
    let values: [String: Double] = ["five_hour": 9, "seven_day": 58, "seven_day_sonnet": 77, "seven_day_omelette": 12]
    VStack(spacing: 12) {
        CustomPillsIcon(metrics: DiscoveredMetric.defaults.filter { ["five_hour","seven_day","seven_day_sonnet"].contains($0.key) },
                        metricValues: values, status: .safe, isLoading: false, isStale: false)
        CustomPillsIcon(metrics: DiscoveredMetric.defaults,
                        metricValues: values, status: .warning, isLoading: false, isStale: false)
    }
    .padding()
}
