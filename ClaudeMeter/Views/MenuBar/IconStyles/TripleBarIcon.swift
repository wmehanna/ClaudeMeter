import SwiftUI

/// Triple bar menu bar icon: session (top), weekly (middle), sonnet (bottom)
struct TripleBarIcon: View {
    let percentage: Double
    let weeklyPercentage: Double
    let sonnetPercentage: Double
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
                VStack(spacing: barSpacing) {
                    ProgressBar(percentage: percentage,      color: isStale ? .gray : status.color, isStale: isStale)
                        .frame(width: barWidth, height: barHeight)
                    ProgressBar(percentage: weeklyPercentage, color: isStale ? .gray : .purple,      isStale: isStale)
                        .frame(width: barWidth, height: barHeight)
                    ProgressBar(percentage: sonnetPercentage, color: isStale ? .gray : .orange,      isStale: isStale)
                        .frame(width: barWidth, height: barHeight)
                }

                Text("\(Int(percentage))%")
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
        .accessibilityLabel("Session: \(Int(percentage))%, Weekly: \(Int(weeklyPercentage))%, Sonnet: \(Int(sonnetPercentage))%")
    }
}

private struct ProgressBar: View {
    let percentage: Double
    let color: Color
    let isStale: Bool

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
    VStack(spacing: 20) {
        TripleBarIcon(percentage: 17, weeklyPercentage: 55, sonnetPercentage: 74, status: .safe,     isLoading: false, isStale: false)
        TripleBarIcon(percentage: 65, weeklyPercentage: 80, sonnetPercentage: 90, status: .warning,  isLoading: false, isStale: false)
        TripleBarIcon(percentage: 95, weeklyPercentage: 95, sonnetPercentage: 99, status: .critical, isLoading: false, isStale: false)
    }
    .padding()
}
