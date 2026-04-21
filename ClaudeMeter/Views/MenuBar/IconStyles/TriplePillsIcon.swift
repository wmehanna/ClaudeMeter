import SwiftUI

/// Three inline percentage pills: session | weekly | sonnet
struct TriplePillsIcon: View {
    let percentage: Double        // session
    let weeklyPercentage: Double
    let sonnetPercentage: Double
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
                pill("\(Int(percentage))%",   color: isStale ? .gray : status.color)
                separator
                pill("\(Int(weeklyPercentage))%", color: isStale ? .gray : .purple)
                separator
                pill("\(Int(sonnetPercentage))%", color: isStale ? .gray : .orange)
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
        .accessibilityLabel("Session: \(Int(percentage))%, Weekly: \(Int(weeklyPercentage))%, Sonnet: \(Int(sonnetPercentage))%")
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
    VStack(spacing: 12) {
        TriplePillsIcon(percentage: 17, weeklyPercentage: 55, sonnetPercentage: 74, status: .safe,     isLoading: false, isStale: false)
        TriplePillsIcon(percentage: 65, weeklyPercentage: 80, sonnetPercentage: 90, status: .warning,  isLoading: false, isStale: false)
        TriplePillsIcon(percentage: 95, weeklyPercentage: 95, sonnetPercentage: 99, status: .critical, isLoading: false, isStale: false)
    }
    .padding()
}
