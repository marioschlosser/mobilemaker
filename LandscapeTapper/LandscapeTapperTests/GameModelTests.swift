import XCTest
@testable import LandscapeTapper

final class GameModelTests: XCTestCase {

    override func setUp() {
        super.setUp()
        UserDefaults.standard.removeObject(forKey: "LandscapeTapper_score")
    }

    func testInitialScoreIsZero() {
        let model = GameModel()
        XCTAssertEqual(model.score, 0)
    }

    func testTapIncrementsScore() {
        let model = GameModel()
        let score = model.tap()
        XCTAssertEqual(score, 1)
        XCTAssertEqual(model.score, 1)
    }

    func testMultipleTaps() {
        let model = GameModel()
        for _ in 0..<10 {
            _ = model.tap()
        }
        XCTAssertEqual(model.score, 10)
    }

    func testScorePersists() {
        let model1 = GameModel()
        _ = model1.tap()
        _ = model1.tap()
        _ = model1.tap()

        let model2 = GameModel()
        XCTAssertEqual(model2.score, 3)
    }
}
