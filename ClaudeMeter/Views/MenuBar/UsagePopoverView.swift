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

                Button(action: {
                    Task { await appModel.refreshUsage(forceRefresh: true) }
                }) {
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

                        if errorMessage.contains("invalid") || errorMessage.contains("expired") || errorMessage.contains("authentication") {
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
