import SwiftUI

/// Stacked progress bars for selected metrics (up to 3)
struct CustomBarIcon: View {
    let metrics: [DiscoveredMetric]
    let metricValues: [String: Double]
    let status: UsageStatus
    let isLoading: Bool
    let isStale: Bool

    private let barWidth: CGFloat = 32
    private let barHeight: CGFloat = 4
    private let barSpacing: CGFloat = 1.5

    var body: some View {
        HStack(spacing: 4) {
            if isLoading {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isStale ? .gray : status.color)
            } else {
                let visible = Array(metrics.prefix(3))
                VStack(spacing: barSpacing) {
                    ForEach(visible) { metric in
                        ProgressBar(percentage: metricValues[metric.key] ?? 0,
                                    color: metricColor(forKey: metric.key, status: status, isStale: isStale))
                            .frame(width: barWidth, height: barHeight)
                    }
                }
                let primaryValue = metricValues[metrics.first?.key ?? "five_hour"] ?? 0
                Text("\(Int(primaryValue))%")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(isStale ? .gray : status.color)
            }
            if isStale && !isLoading {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
            }
        }
        .frame(height: 22)
        .padding(.horizontal, 4)
        .accessibilityLabel(metrics.prefix(3).map { "\($0.displayName): \(Int(metricValues[$0.key] ?? 0))%" }.joined(separator: ", "))
    }
}

private struct ProgressBar: View {
    let percentage: Double
    let color: Color

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 1.5).fill(Color.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 1.5)
                    .fill(color)
                    .frame(width: geo.size.width * min(percentage / 100, 1.0))
            }
        }
    }
}

#Preview {
    let values: [String: Double] = ["five_hour": 17, "seven_day": 55, "seven_day_sonnet": 74]
    VStack(spacing: 20) {
        CustomBarIcon(metrics: DiscoveredMetric.defaults.filter { ["five_hour","seven_day","seven_day_sonnet"].contains($0.key) },
                      metricValues: values, status: .safe, isLoading: false, isStale: false)
        CustomBarIcon(metrics: DiscoveredMetric.defaults.filter { ["five_hour","seven_day"].contains($0.key) },
                      metricValues: values, status: .warning, isLoading: false, isStale: false)
    }
    .padding()
}
