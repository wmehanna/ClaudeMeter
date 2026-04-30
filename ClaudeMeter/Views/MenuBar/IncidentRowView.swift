import SwiftUI

struct IncidentRowView: View {
    let incident: ClaudeIncident

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(impactColor)
                    .frame(width: 7, height: 7)
                Text(incident.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                Spacer()
                Text(incident.status.capitalized)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(impactColor)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(impactColor.opacity(0.12)))
                if let link = incident.shortlink, let url = URL(string: link) {
                    Link(destination: url) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            Text(incident.latestUpdate)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(nsColor: .windowBackgroundColor)))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(impactColor.opacity(0.4), lineWidth: 1))
    }

    private var impactColor: Color {
        switch incident.impact {
        case .critical: .red
        case .major: .orange
        case .minor: .yellow
        case .unknown: .secondary
        }
    }
}
