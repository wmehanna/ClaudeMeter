//
//  MarketingSnapshotTests.swift
//  ClaudeMeterTests
//

import AppKit
import SwiftUI
import XCTest
@testable import ClaudeMeter

@MainActor
final class MarketingSnapshotTests: XCTestCase {

    static let outputDir: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = docs.appendingPathComponent("claudemeter-marketing", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    // MARK: - Shot helpers

    /// For views with @Observable/@Bindable state — uses NSHostingView in an off-screen window.
    private func shot<V: View>(_ view: V, name: String, width: CGFloat, height: CGFloat) {
        let sized = view
            .frame(width: width, height: height)
            .environment(\.colorScheme, .dark)

        let host = NSHostingView(rootView: sized)
        host.appearance = NSAppearance(named: .darkAqua)
        let size = NSSize(width: width, height: height)
        host.frame = NSRect(origin: .zero, size: size)

        let window = NSWindow(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentView = host
        window.makeKeyAndOrderFront(nil)
        host.layout()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.3))

        guard let bitmapRep = host.bitmapImageRepForCachingDisplay(in: host.bounds) else {
            XCTFail("bitmapImageRepForCachingDisplay failed for \(name)")
            return
        }
        host.cacheDisplay(in: host.bounds, to: bitmapRep)
        guard let png = bitmapRep.representation(using: .png, properties: [:]) else {
            XCTFail("PNG conversion failed for \(name)")
            return
        }
        window.orderOut(nil)
        save(png, name: name)
    }

    /// For pure value views (no @Observable) — uses ImageRenderer at 2x scale.
    private func shotStatic<V: View>(_ view: V, name: String) {
        let dark = view.environment(\.colorScheme, .dark)
        let renderer = ImageRenderer(content: dark)
        renderer.scale = 2.0
        renderer.isOpaque = false
        guard let image = renderer.nsImage,
              let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff),
              let png = rep.representation(using: .png, properties: [:]) else {
            XCTFail("ImageRenderer failed for \(name)")
            return
        }
        save(png, name: name)
    }

    private func save(_ png: Data, name: String) {
        let url = Self.outputDir.appendingPathComponent("\(name).png")
        XCTAssertNoThrow(try png.write(to: url))
        print("📸 \(url.path)")
    }

    // MARK: - Mock data

    private func makeAppModel() -> AppModel {
        let model = AppModel(
            settingsRepository: SettingsRepositoryFake(),
            keychainRepository: KeychainRepositoryFake()
        )
        model.isReady = true

        let resetSoon  = Date().addingTimeInterval(3600)
        let resetWeek  = Date().addingTimeInterval(7 * 86400)

        let session  = UsageLimit(utilization: 22, resetAt: resetSoon)
        let weekly   = UsageLimit(utilization: 61, resetAt: resetWeek)
        let sonnet   = UsageLimit(utilization: 84, resetAt: resetWeek)
        let design   = UsageLimit(utilization: 7,  resetAt: resetSoon)

        let discovered: [DiscoveredMetric] = [
            DiscoveredMetric(key: "five_hour",         displayName: "Session"),
            DiscoveredMetric(key: "seven_day",          displayName: "Weekly"),
            DiscoveredMetric(key: "seven_day_sonnet",   displayName: "Sonnet"),
            DiscoveredMetric(key: "seven_day_omelette", displayName: "Design"),
        ]

        model.usageData = UsageData(
            sessionUsage: session,
            weeklyUsage: weekly,
            discoveredMetrics: discovered,
            metricValues: [
                "five_hour":         session,
                "seven_day":          weekly,
                "seven_day_sonnet":   sonnet,
                "seven_day_omelette": design,
            ],
            lastUpdated: Date()
        )

        model.settings.customPillsKeys = ["seven_day", "seven_day_sonnet", "five_hour"]
        model.settings.iconStyle = .customPills
        return model
    }

    // MARK: - Tests

    func test_marketing_popover() {
        let model = makeAppModel()
        shot(UsagePopoverView(appModel: model, onRequestClose: nil), name: "Marketing_Popover", width: 320, height: 580)
    }

    func test_marketing_settings_general() {
        let model = makeAppModel()
        let available = model.usageData?.discoveredMetrics ?? DiscoveredMetric.defaults
        let view = SettingsPreviewShell(appModel: model, available: available)
        shot(view, name: "Marketing_Settings_General", width: 600, height: 660)
    }

    func test_marketing_menubar_custompills() {
        let values: [String: Double] = [
            "seven_day": 61, "seven_day_sonnet": 84, "five_hour": 22,
        ]
        let metrics = [
            DiscoveredMetric(key: "seven_day",        displayName: "Weekly"),
            DiscoveredMetric(key: "seven_day_sonnet", displayName: "Sonnet"),
            DiscoveredMetric(key: "five_hour",        displayName: "Session"),
        ]
        let view = MenuBarIconView(
            metricValues: values,
            status: .warning,
            isLoading: false,
            isStale: false,
            iconStyle: .customPills,
            fontSize: 13,
            customPillsMetrics: metrics
        ).fixedSize()
        shotStatic(view, name: "Marketing_MenuBar_CustomPills")
    }

    func test_marketing_menubar_battery() {
        let view = MenuBarIconView(
            metricValues: ["five_hour": 22],
            status: .safe,
            isLoading: false,
            isStale: false,
            iconStyle: .battery
        ).fixedSize()
        shotStatic(view, name: "Marketing_MenuBar_Battery")
    }

    func test_marketing_menubar_dualbar() {
        let values: [String: Double] = ["five_hour": 22, "seven_day": 61]
        let metrics = [
            DiscoveredMetric(key: "five_hour", displayName: "Session"),
            DiscoveredMetric(key: "seven_day", displayName: "Weekly"),
        ]
        let view = MenuBarIconView(
            metricValues: values,
            status: .warning,
            isLoading: false,
            isStale: false,
            iconStyle: .dualBar,
            dualBarMetrics: metrics
        ).fixedSize()
        shotStatic(view, name: "Marketing_MenuBar_DualBar")
    }
}

// MARK: - Settings preview shell (avoids TabView + SMAppService window requirements)

@MainActor
private struct SettingsPreviewShell: View {
    @Bindable var appModel: AppModel
    let available: [DiscoveredMetric]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                popoverSection
                Divider()
                iconStyleSection
            }
            .padding(20)
        }
        .background(Color(NSColor.windowBackgroundColor))
    }

    private var popoverSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Popover Metrics")
                .font(.subheadline).bold()
            Text("Choose which metrics appear in the usage popover")
                .font(.caption).foregroundStyle(.secondary)
            ForEach(available.filter { !$0.isSession }) { metric in
                HStack {
                    Text(metric.displayName).font(.callout)
                    Spacer()
                    Toggle("", isOn: Binding(
                        get: { appModel.settings.isPopoverVisible(key: metric.key) },
                        set: { shown in
                            if shown {
                                appModel.settings.popoverHiddenKeys.removeAll { $0 == metric.key }
                            } else if !appModel.settings.popoverHiddenKeys.contains(metric.key) {
                                appModel.settings.popoverHiddenKeys.append(metric.key)
                            }
                        }
                    )).labelsHidden()
                }
            }
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var iconStyleSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Menu Bar Icon Style")
                .font(.subheadline).bold()
            Text("Choose how the usage indicator appears in your menu bar")
                .font(.caption).foregroundStyle(.secondary)
            IconStylePicker(selection: $appModel.settings.iconStyle)
            MetricPickerRow(
                label: "Metrics",
                caption: "Select up to 4 (left to right order)",
                available: available,
                selectedKeys: $appModel.settings.customPillsKeys,
                maxCount: 4
            )
        }
        .padding()
        .background(.quaternary.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

