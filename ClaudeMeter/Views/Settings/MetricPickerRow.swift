import SwiftUI

/// Inline metric toggle row used in icon style settings
struct MetricPickerRow: View {
    let label: String
    let caption: String
    let available: [DiscoveredMetric]
    @Binding var selectedKeys: [String]
    let maxCount: Int

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.subheadline)
                Text(caption).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 6) {
                ForEach(available) { metric in
                    let isOn = selectedKeys.contains(metric.key)
                    let canAdd = maxCount == 1 || selectedKeys.count < maxCount
                    let tint = metricTintColor(forKey: metric.key)
                    Button(action: { toggle(metric.key) }) {
                        Text(metric.displayName)
                            .font(.system(size: 11, weight: .medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isOn ? tint.opacity(0.2) : Color.gray.opacity(0.1))
                            .foregroundColor(isOn ? tint : (canAdd ? .primary : .secondary))
                            .cornerRadius(6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(isOn ? tint : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isOn && !canAdd)
                }
            }
        }
    }

    private func toggle(_ key: String) {
        if maxCount == 1 {
            selectedKeys = [key]
        } else if selectedKeys.contains(key) {
            guard selectedKeys.count > 1 else { return }
            selectedKeys.removeAll { $0 == key }
        } else {
            guard selectedKeys.count < maxCount else { return }
            selectedKeys.append(key)
        }
    }
}
