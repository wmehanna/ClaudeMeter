import AppKit
import Observation
import SwiftUI

/// Manages NSStatusItem and NSPopover presentation.
@MainActor
final class MenuBarManager {
    private let appModel: AppModel
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let iconCache = IconCache()
    private let iconRenderer = MenuBarIconRenderer()
    private var openUsageObserver: NSObjectProtocol?

    init(appModel: AppModel) {
        self.appModel = appModel
    }

    func start() {
        setupStatusItem()
        createPopover()
        observeIconUpdates()
        observeOpenPopoverRequests()

        Task {
            await appModel.bootstrap()
        }
    }

    #if DEBUG
    func startWithoutBootstrap() {
        setupStatusItem()
        createPopover()
        observeIconUpdates()
        observeOpenPopoverRequests()
    }
    #endif

    deinit {
        if let openUsageObserver {
            NotificationCenter.default.removeObserver(openUsageObserver)
        }
    }

    // MARK: - Setup

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        guard let button = statusItem?.button else { return }

        button.target = self
        button.action = #selector(togglePopover)
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.imagePosition = .imageOnly
        button.setAccessibilityLabel("ClaudeMeter")

        updateIcon()
    }

    private func createPopover() {
        let popoverView = MenuBarPopoverView(appModel: appModel) { [weak self] in
            self?.closePopover()
        }
        let hostingController = NSHostingController(rootView: popoverView)

        let popover = NSPopover()
        popover.contentViewController = hostingController
        popover.behavior = .transient
        popover.animates = true

        self.popover = popover
    }

    private func observeOpenPopoverRequests() {
        openUsageObserver = NotificationCenter.default.addObserver(
            forName: .openUsagePopover,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.showPopover()
            }
        }
    }

    // MARK: - Observation

    private func observeIconUpdates() {
        withObservationTracking {
            _ = appModel.usageData
            _ = appModel.isLoading
            _ = appModel.claudeStatus
            _ = appModel.settings.iconStyle
            _ = appModel.settings.customPillsFontSize
            _ = appModel.settings.singleMetricKey
            _ = appModel.settings.customPillsKeys
            _ = appModel.settings.customBarKeys
            _ = appModel.settings.dualBarKeys
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.updateIcon()
                self.observeIconUpdates()
            }
        }
    }

    private func updateIcon() {
        guard let button = statusItem?.button else { return }

        let usageData    = appModel.usageData
        let metricValues = usageData?.metricValues.mapValues { $0.percentage } ?? [:]
        let status       = usageData?.primaryStatus ?? .safe
        let isStale      = usageData?.isStale ?? false
        let isLoading    = appModel.isLoading
        let style        = appModel.settings.iconStyle
        let fontSize     = appModel.settings.customPillsFontSize
        let singleKey    = appModel.settings.singleMetricKey

        let available    = usageData?.discoveredMetrics ?? DiscoveredMetric.defaults

        func resolve(_ keys: [String]) -> [DiscoveredMetric] {
            keys.compactMap { key in available.first { $0.key == key } }
        }

        let pillsMetrics = resolve(appModel.settings.customPillsKeys)
        let barMetrics   = resolve(appModel.settings.customBarKeys)
        let dualMetrics  = resolve(appModel.settings.dualBarKeys)

        let operational  = appModel.claudeStatus.isOperational

        let icon: NSImage
        if let cached = iconCache.get(
            metricValues: metricValues, status: status, isLoading: isLoading, isStale: isStale,
            iconStyle: style, fontSize: fontSize, singleMetricKey: singleKey,
            customPillsMetrics: pillsMetrics, customBarMetrics: barMetrics, dualBarMetrics: dualMetrics,
            claudeOperational: operational
        ) {
            icon = cached
        } else {
            icon = iconRenderer.render(
                metricValues: metricValues, status: status, isLoading: isLoading, isStale: isStale,
                iconStyle: style, fontSize: fontSize, singleMetricKey: singleKey,
                customPillsMetrics: pillsMetrics, customBarMetrics: barMetrics, dualBarMetrics: dualMetrics,
                claudeOperational: operational
            )
            iconCache.set(
                icon, metricValues: metricValues, status: status, isLoading: isLoading, isStale: isStale,
                iconStyle: style, fontSize: fontSize, singleMetricKey: singleKey,
                customPillsMetrics: pillsMetrics, customBarMetrics: barMetrics, dualBarMetrics: dualMetrics,
                claudeOperational: operational
            )
        }

        button.image = icon
        button.imagePosition = .imageOnly
        button.attributedTitle = NSAttributedString(string: "")
    }

    // MARK: - Popover Control

    @objc private func togglePopover() {
        guard let popover else { return }
        if popover.isShown { closePopover() } else { showPopover() }
    }

    private func showPopover() {
        guard let button = statusItem?.button, let popover else { return }
        guard !popover.isShown else { return }

        popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        NSApp.activate(ignoringOtherApps: true)
    }

    private func closePopover() {
        popover?.performClose(nil)
    }
}
