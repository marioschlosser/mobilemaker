import XCTest
@testable import Mixodia

final class GameModelTests: XCTestCase {

    var model: GameModel!

    override func setUp() {
        super.setUp()
        model = GameModel()
    }

    // MARK: - Initial State

    func testInitialEssence() {
        XCTAssertEqual(model.essence, 10)
    }

    func testStartsWith4BaseCreatures() {
        XCTAssertEqual(model.ownedCreatureIDs.count, 4)
        XCTAssertTrue(model.isDiscovered(head: .fire, body: .fire))
        XCTAssertTrue(model.isDiscovered(head: .water, body: .water))
        XCTAssertTrue(model.isDiscovered(head: .earth, body: .earth))
        XCTAssertTrue(model.isDiscovered(head: .air, body: .air))
    }

    func testStartsWith4Discovered() {
        XCTAssertEqual(model.discoveredCount, 4)
    }

    func testHybridsNotDiscoveredAtStart() {
        XCTAssertFalse(model.isDiscovered(head: .fire, body: .water))
        XCTAssertFalse(model.isDiscovered(head: .earth, body: .air))
    }

    // MARK: - Selection

    func testSelectHead() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        model.selectHead(ember)
        XCTAssertEqual(model.headSelection?.id, "fire_fire")
    }

    func testSelectBody() {
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectBody(splash)
        XCTAssertEqual(model.bodySelection?.id, "water_water")
    }

    func testClearSelection() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)
        model.clearSelection()
        XCTAssertNil(model.headSelection)
        XCTAssertNil(model.bodySelection)
    }

    // MARK: - Mixing

    func testCannotMixWithoutSelection() {
        XCTAssertFalse(model.canMix())
    }

    func testCannotMixWithOnlyHead() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        model.selectHead(ember)
        XCTAssertFalse(model.canMix())
    }

    func testCanMixWithBothSelected() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)
        XCTAssertTrue(model.canMix())
    }

    func testMixNewDiscovery() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)

        let result = model.performMix()
        if case .newDiscovery(let creature) = result {
            XCTAssertEqual(creature.id, "fire_water")
            XCTAssertEqual(creature.name, "Embash")
            XCTAssertEqual(creature.headElement, .fire)
            XCTAssertEqual(creature.bodyElement, .water)
        } else {
            XCTFail("Expected new discovery")
        }
    }

    func testMixCostsEssence() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)

        let startEssence = model.essence
        _ = model.performMix()
        // Cost 1, gain 3 for new discovery = net +2
        XCTAssertEqual(model.essence, startEssence - 1 + 3)
    }

    func testMixDuplicate() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)

        // First mix: new discovery
        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        // Second mix: duplicate
        model.selectHead(ember)
        model.selectBody(splash)
        let result = model.performMix()

        if case .duplicate(let creature) = result {
            XCTAssertEqual(creature.id, "fire_water")
        } else {
            XCTFail("Expected duplicate")
        }
    }

    func testDuplicateGivesLessEssence() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)

        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        let essenceBefore = model.essence
        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        // Cost 1, gain 1 for duplicate = net 0
        XCTAssertEqual(model.essence, essenceBefore)
    }

    func testMixOrderMatters() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)

        // Fire head + Water body
        model.selectHead(ember)
        model.selectBody(splash)
        let result1 = model.performMix()

        // Water head + Fire body
        model.selectHead(splash)
        model.selectBody(ember)
        let result2 = model.performMix()

        if case .newDiscovery(let c1) = result1, case .newDiscovery(let c2) = result2 {
            XCTAssertNotEqual(c1.id, c2.id)
            XCTAssertEqual(c1.id, "fire_water")
            XCTAssertEqual(c2.id, "water_fire")
        } else {
            XCTFail("Both should be new discoveries")
        }
    }

    func testMixAddsToOwned() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)

        let ownedBefore = model.ownedCreatureIDs.count
        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        XCTAssertEqual(model.ownedCreatureIDs.count, ownedBefore + 1)
        XCTAssertTrue(model.ownedCreatureIDs.contains("fire_water"))
    }

    func testMixClearsSelection() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        XCTAssertNil(model.headSelection)
        XCTAssertNil(model.bodySelection)
    }

    // MARK: - Creature Database

    func testDatabaseHas16Creatures() {
        XCTAssertEqual(CreatureDatabase.all.count, 16)
    }

    func testAllElementCombinationsExist() {
        for head in Element.allCases {
            for body in Element.allCases {
                let id = Creature.creatureID(head: head, body: body)
                XCTAssertNotNil(CreatureDatabase.all[id], "Missing creature: \(id)")
            }
        }
    }

    func testBaseCreaturesHaveMatchingElements() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        XCTAssertTrue(ember.isBase)
        XCTAssertEqual(ember.name, "Ember")
    }

    func testHybridsHaveDifferentElements() {
        let embash = CreatureDatabase.creature(head: .fire, body: .water)
        XCTAssertFalse(embash.isBase)
    }

    // MARK: - Progress

    func testMixodexProgress() {
        XCTAssertEqual(model.mixodexProgress, 4.0 / 16.0)
    }

    func testTotalCreatures() {
        XCTAssertEqual(model.totalCreatures, 16)
    }

    // MARK: - Reset

    func testReset() {
        let ember = CreatureDatabase.creature(head: .fire, body: .fire)
        let splash = CreatureDatabase.creature(head: .water, body: .water)
        model.selectHead(ember)
        model.selectBody(splash)
        _ = model.performMix()

        model.reset()

        XCTAssertEqual(model.essence, 10)
        XCTAssertEqual(model.discoveredCount, 4)
        XCTAssertEqual(model.ownedCreatureIDs.count, 4)
        XCTAssertNil(model.headSelection)
        XCTAssertNil(model.bodySelection)
    }
}
