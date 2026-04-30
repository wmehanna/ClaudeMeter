import SwiftUI
import AppKit

/// Usage popover view with detailed metrics
struct UsagePopoverView: View {
    @Bindable var appModel: AppModel
    let onRequestClose: (() -> Void)?
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Claude Usage")
                    .font(.title2)
                    .fontWeight(.bold)

                Spacer()

                statusBadge

                Button {
                    Task { await appModel.refreshUsage(forceRefresh: true) }
                } label: {
                    if appModel.isRefreshing {
                        ProgressView().scaleEffect(0.7).frame(width: 20, height: 20)
                    } else {
                        Image(systemName: "arrow.clockwise")
                    }
                }
                .buttonStyle(.plain)
                .disabled(appModel.isRefreshing)
                .help("Refresh usage data")
                .keyboardShortcut("r", modifiers: .command)
            }
            .padding()

            Divider()

            if !appModel.claudeStatus.incidents.isEmpty {
                incidentPanel
                Divider()
            }

            // Error banner
            if let errorMessage = appModel.errorMessage {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.orange)
                        Text(errorMessage).font(.callout).foregroundColor(.primary)
                        Spacer()
                    }
                    HStack(spacing: 8) {
                        Button("Retry") {
                            Task { await appModel.refreshUsage(forceRefresh: true) }
                        }
                        .buttonStyle(.bordered)

                        let isAuthError = errorMessage.contains("invalid")
                            || errorMessage.contains("expired")
                            || errorMessage.contains("authentication")
                        if isAuthError {
                            Button("Update Session Key") { openSettingsFront() }
                                .buttonStyle(.borderedProminent)
                        }
                    }
                }
                .padding()
                .background(Color.orange.opacity(0.1))

                Divider()
            }

            // Content
            if let usageData = appModel.usageData {
                VStack(spacing: 16) {
                    // Session is always shown
                    UsageCardView(
                        title: "5-Hour Session",
                        usageLimit: usageData.sessionUsage,
                        icon: "gauge.with.dots.needle.67percent",
                        windowDuration: Constants.Pacing.sessionWindow
                    )

                    // All other discovered metrics, filtered by popoverHiddenKeys
                    ForEach(usageData.discoveredMetrics.filter { !$0.isSession }) { metric in
                        if appModel.settings.isPopoverVisible(key: metric.key),
                           let limit = usageData.metricValues[metric.key] {
                            UsageCardView(
                                title: metric.displayName,
                                usageLimit: limit,
                                icon: popoverIcon(forKey: metric.key),
                                windowDuration: Constants.Pacing.weeklyWindow
                            )
                        }
                    }
                }
                .padding()
            } else {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Loading usage data...")
                        .font(.callout)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            }

            Divider()

            // Footer
            HStack {
                Button("Settings") { openSettingsFront() }
                    .buttonStyle(.plain)
                    .keyboardShortcut(",", modifiers: .command)
                    .accessibilityLabel("Open settings window")

                Spacer()

                Button("Quit") { NSApplication.shared.terminate(nil) }
                    .buttonStyle(.plain)
                    .keyboardShortcut("q", modifiers: .command)
                    .accessibilityLabel("Quit application")
            }
            .padding()
        }
        .frame(width: 320)
        .background(Color(nsColor: .windowBackgroundColor))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Usage Dashboard")
    }

    @ViewBuilder
    private var statusBadge: some View {
        if appModel.claudeStatus.isOperational {
            Label("Operational", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.green))
                .help("All systems operational")
        } else {
            let name = appModel.claudeStatus.incidents.first?.name ?? "Incident ongoing"
            Text(name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .lineLimit(1)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(Color.red))
                .help(name)
        }
    }

    private var incidentPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(appModel.claudeStatus.incidents) { incident in
                    IncidentRowView(incident: incident)
                }
            }
            .padding(10)
        }
        .frame(maxHeight: 160)
        .background(Color.red.opacity(0.05))
    }

    private func popoverIcon(forKey key: String) -> String {
        switch key {
        case "seven_day":          return "calendar"
        case "seven_day_sonnet":   return "sparkles"
        case "seven_day_omelette": return "paintpalette"
        case "seven_day_opus":     return "brain"
        case "seven_day_cowork":   return "person.2"
        default:                   return "chart.bar"
        }
    }

    private func openSettingsFront() {
        onRequestClose?()
        if let keyWindow = NSApp.keyWindow, keyWindow.level != .normal {
            keyWindow.orderOut(nil)
        }
        NSApp.activate(ignoringOtherApps: true)
        openSettings()
    }
}
