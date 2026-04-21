import AppKit
import SwiftUI
@testable import ClaudeMeter

@MainActor
enum MenuBarIconSnapshotRenderer {
    static func render(
        percentage: Double,
        weeklyPercentage: Double,
        status: UsageStatus,
        isLoading: Bool,
        isStale: Bool,
        iconStyle: IconStyle
    ) -> NSImage {
        let metricValues: [String: Double] = [
            "five_hour": percentage,
            "seven_day": weeklyPercentage,
        ]
        let view = MenuBarIconView(
            metricValues: metricValues,
            status: status,
            isLoading: isLoading,
            isStale: isStale,
            iconStyle: iconStyle
        )
        .fixedSize()

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0
        renderer.isOpaque = false

        guard let image = renderer.nsImage else {
            return NSImage(
                systemSymbolName: "exclamationmark.triangle",
                accessibilityDescription: "Snapshot render failed"
            ) ?? NSImage()
        }

        image.isTemplate = false
        return image
    }
}
