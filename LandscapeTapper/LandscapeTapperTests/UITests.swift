import XCTest

final class LandscapeTapperUITests: XCTestCase {

    func testTapLandscape() {
        let app = XCUIApplication()
        app.launch()

        // Take screenshot of initial state
        let initial = app.screenshot()
        let initialAttachment = XCTAttachment(screenshot: initial)
        initialAttachment.name = "Initial"
        initialAttachment.lifetime = .keepAlways
        add(initialAttachment)

        // Tap 10 times at various locations
        let view = app.windows.firstMatch
        let positions: [(CGFloat, CGFloat)] = [
            (0.5, 0.5), (0.3, 0.6), (0.7, 0.4),
            (0.4, 0.7), (0.6, 0.3), (0.5, 0.8),
            (0.35, 0.55), (0.65, 0.45), (0.5, 0.65),
            (0.45, 0.35)
        ]

        for (nx, ny) in positions {
            let coord = view.coordinate(withNormalizedOffset: CGVector(dx: nx, dy: ny))
            coord.tap()
            Thread.sleep(forTimeInterval: 0.3)
        }

        // Take screenshot after tapping
        let tapped = app.screenshot()
        let tappedAttachment = XCTAttachment(screenshot: tapped)
        tappedAttachment.name = "AfterTapping"
        tappedAttachment.lifetime = .keepAlways
        add(tappedAttachment)
    }
}
