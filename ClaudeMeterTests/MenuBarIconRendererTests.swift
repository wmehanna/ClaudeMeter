import XCTest
@testable import ClaudeMeter

@MainActor
final class MenuBarIconRendererTests: XCTestCase {
    private let testValues: [String: Double] = [
        "five_hour": TestConstants.sessionPercentage,
        "seven_day": TestConstants.weeklyPercentage,
    ]

    func test_menuBarIconRendersForAllStyles() {
        let renderer = MenuBarIconRenderer()

        for style in IconStyle.allCases {
            let image = renderer.render(
                metricValues: testValues,
                status: .safe,
                isLoading: false,
                isStale: false,
                iconStyle: style
            )

            XCTAssertGreaterThan(image.size.width, 0)
            XCTAssertGreaterThan(image.size.height, 0)
        }
    }

    func test_menuBarIconRendersWhenLoadingOrStale() {
        let renderer = MenuBarIconRenderer()

        let loadingImage = renderer.render(
            metricValues: testValues,
            status: .safe,
            isLoading: true,
            isStale: false,
            iconStyle: .battery
        )

        let staleImage = renderer.render(
            metricValues: testValues,
            status: .safe,
            isLoading: false,
            isStale: true,
            iconStyle: .battery
        )

        XCTAssertGreaterThan(loadingImage.size.width, 0)
        XCTAssertGreaterThan(loadingImage.size.height, 0)
        XCTAssertGreaterThan(staleImage.size.width, 0)
        XCTAssertGreaterThan(staleImage.size.height, 0)
    }

    func test_menuBarIconIsRenderedAsNonTemplateImage() {
        let renderer = MenuBarIconRenderer()

        let image = renderer.render(
            metricValues: testValues,
            status: .safe,
            isLoading: false,
            isStale: false,
            iconStyle: .battery
        )

        XCTAssertFalse(image.isTemplate)
    }
}
