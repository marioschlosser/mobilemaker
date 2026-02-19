import Foundation

class GameModel {
    private let scoreKey = "LandscapeTapper_score"
    private let pptKey = "LandscapeTapper_pointsPerTap"

    private(set) var score: Int {
        didSet {
            UserDefaults.standard.set(score, forKey: scoreKey)
        }
    }

    private(set) var pointsPerTap: Int {
        didSet {
            UserDefaults.standard.set(pointsPerTap, forKey: pptKey)
        }
    }

    init() {
        self.score = UserDefaults.standard.integer(forKey: scoreKey)
        let saved = UserDefaults.standard.integer(forKey: pptKey)
        self.pointsPerTap = saved > 0 ? saved : 1
    }

    func tap() -> Int {
        score += pointsPerTap
        return score
    }

    func increasePointsPerTap() -> Int {
        pointsPerTap += 1
        return pointsPerTap
    }

    func decreasePointsPerTap() -> Int {
        if pointsPerTap > 1 {
            pointsPerTap -= 1
        }
        return pointsPerTap
    }

    func reset() {
        score = 0
        pointsPerTap = 1
    }
}
