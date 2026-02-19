import Foundation
import CoreGraphics

// MARK: - Element

enum Element: String, Codable, CaseIterable {
    case fire, water, earth, air

    var displayName: String {
        rawValue.capitalized
    }

    var colorHex: UInt32 {
        switch self {
        case .fire:  return 0xFF6B35
        case .water: return 0x3DA5D9
        case .earth: return 0x7CB342
        case .air:   return 0xB39DDB
        }
    }
}

// MARK: - Creature

struct Creature: Codable, Equatable {
    let id: String          // Unique key: "fire_water" (headElement_bodyElement)
    let name: String
    let headElement: Element
    let bodyElement: Element
    let description: String
    let spriteName: String  // Asset name in catalog

    var isBase: Bool {
        headElement == bodyElement
    }

    static func creatureID(head: Element, body: Element) -> String {
        "\(head.rawValue)_\(body.rawValue)"
    }
}

// MARK: - Creature Database

struct CreatureDatabase {
    static let all: [String: Creature] = {
        var db: [String: Creature] = [:]
        for entry in creatureEntries {
            db[entry.id] = entry
        }
        return db
    }()

    static func creature(head: Element, body: Element) -> Creature {
        let id = Creature.creatureID(head: head, body: body)
        return all[id]!
    }

    private static let creatureEntries: [Creature] = [
        // Base creatures (pure elements)
        Creature(id: "fire_fire", name: "Ember", headElement: .fire, bodyElement: .fire,
                 description: "A small flame fox that radiates warmth. Its tail flickers like a candle.",
                 spriteName: "creature_fire_fire"),
        Creature(id: "water_water", name: "Splash", headElement: .water, bodyElement: .water,
                 description: "A playful water otter that leaves puddles wherever it goes.",
                 spriteName: "creature_water_water"),
        Creature(id: "earth_earth", name: "Pebble", headElement: .earth, bodyElement: .earth,
                 description: "A sturdy rocky armadillo with moss growing between its plates.",
                 spriteName: "creature_earth_earth"),
        Creature(id: "air_air", name: "Breeze", headElement: .air, bodyElement: .air,
                 description: "A cloud-wisp bird that drifts on invisible currents.",
                 spriteName: "creature_air_air"),

        // Fire head hybrids
        Creature(id: "fire_water", name: "Embash", headElement: .fire, bodyElement: .water,
                 description: "Steam rises from this fox-otter hybrid. Hot head, cool body.",
                 spriteName: "creature_fire_water"),
        Creature(id: "fire_earth", name: "Emberock", headElement: .fire, bodyElement: .earth,
                 description: "A volcanic fox-armadillo with magma veins across its rocky shell.",
                 spriteName: "creature_fire_earth"),
        Creature(id: "fire_air", name: "Embreeze", headElement: .fire, bodyElement: .air,
                 description: "A fiery fox head trails smoke as it soars on feathered air wings.",
                 spriteName: "creature_fire_air"),

        // Water head hybrids
        Creature(id: "water_fire", name: "Splember", headElement: .water, bodyElement: .fire,
                 description: "An otter with a steaming flame body. Hisses when it moves.",
                 spriteName: "creature_water_fire"),
        Creature(id: "water_earth", name: "Spleeble", headElement: .water, bodyElement: .earth,
                 description: "A muddy otter-armadillo that thrives in swamps and marshes.",
                 spriteName: "creature_water_earth"),
        Creature(id: "water_air", name: "Splabreeze", headElement: .water, bodyElement: .air,
                 description: "An otter head rides a cloud body, summoning gentle rain.",
                 spriteName: "creature_water_air"),

        // Earth head hybrids
        Creature(id: "earth_fire", name: "Pebbember", headElement: .earth, bodyElement: .fire,
                 description: "A stone-headed creature with a blazing flame body. Erupts when angry.",
                 spriteName: "creature_earth_fire"),
        Creature(id: "earth_water", name: "Pebblash", headElement: .earth, bodyElement: .water,
                 description: "A mossy rock head atop a flowing water body. Calm and ancient.",
                 spriteName: "creature_earth_water"),
        Creature(id: "earth_air", name: "Pebbeze", headElement: .earth, bodyElement: .air,
                 description: "A floating boulder head carried by wispy air currents.",
                 spriteName: "creature_earth_air"),

        // Air head hybrids
        Creature(id: "air_fire", name: "Breember", headElement: .air, bodyElement: .fire,
                 description: "A cloud-faced bird with a blazing fire tail. Sparks fly in the wind.",
                 spriteName: "creature_air_fire"),
        Creature(id: "air_water", name: "Breeplash", headElement: .air, bodyElement: .water,
                 description: "A misty bird-otter that creates fog wherever it wanders.",
                 spriteName: "creature_air_water"),
        Creature(id: "air_earth", name: "Breeble", headElement: .air, bodyElement: .earth,
                 description: "A floating wisp head on a sturdy rock body. Surprisingly heavy.",
                 spriteName: "creature_air_earth"),
    ]
}

// MARK: - Mix Result

enum MixResult {
    case newDiscovery(Creature)
    case duplicate(Creature)
    case notEnoughEssence
}

// MARK: - Game Model

class GameModel {
    private(set) var essence: Int = 10
    private(set) var discoveredIDs: Set<String> = []
    private(set) var ownedCreatureIDs: [String] = []

    // Mixing state
    private(set) var headSelection: Creature?
    private(set) var bodySelection: Creature?

    let mixCost = 1
    let newDiscoveryReward = 3
    let duplicateReward = 1
    let totalCreatures = 16

    var discoveredCount: Int { discoveredIDs.count }
    var mixodexProgress: Float { Float(discoveredCount) / Float(totalCreatures) }

    init() {
        // Start with the 4 base creatures discovered
        let starters: [(Element, Element)] = [
            (.fire, .fire), (.water, .water), (.earth, .earth), (.air, .air)
        ]
        for (head, body) in starters {
            let id = Creature.creatureID(head: head, body: body)
            discoveredIDs.insert(id)
            ownedCreatureIDs.append(id)
        }
    }

    // MARK: - Selection

    func selectHead(_ creature: Creature) {
        headSelection = creature
    }

    func selectBody(_ creature: Creature) {
        bodySelection = creature
    }

    func clearSelection() {
        headSelection = nil
        bodySelection = nil
    }

    // MARK: - Mixing

    func canMix() -> Bool {
        guard headSelection != nil, bodySelection != nil else { return false }
        return essence >= mixCost
    }

    func performMix() -> MixResult {
        guard let head = headSelection, let body = bodySelection else {
            return .notEnoughEssence
        }
        guard essence >= mixCost else {
            return .notEnoughEssence
        }

        essence -= mixCost

        let resultCreature = CreatureDatabase.creature(head: head.headElement, body: body.bodyElement)
        let isNew = !discoveredIDs.contains(resultCreature.id)

        if isNew {
            discoveredIDs.insert(resultCreature.id)
            if !ownedCreatureIDs.contains(resultCreature.id) {
                ownedCreatureIDs.append(resultCreature.id)
            }
            essence += newDiscoveryReward
            clearSelection()
            return .newDiscovery(resultCreature)
        } else {
            essence += duplicateReward
            clearSelection()
            return .duplicate(resultCreature)
        }
    }

    // MARK: - Queries

    func ownedCreatures() -> [Creature] {
        ownedCreatureIDs.compactMap { CreatureDatabase.all[$0] }
    }

    func isDiscovered(head: Element, body: Element) -> Bool {
        discoveredIDs.contains(Creature.creatureID(head: head, body: body))
    }

    func creatureFor(head: Element, body: Element) -> Creature? {
        let id = Creature.creatureID(head: head, body: body)
        guard discoveredIDs.contains(id) else { return nil }
        return CreatureDatabase.all[id]
    }

    // MARK: - Persistence

    func save() {
        let data: [String: Any] = [
            "essence": essence,
            "discoveredIDs": Array(discoveredIDs),
            "ownedCreatureIDs": ownedCreatureIDs
        ]
        UserDefaults.standard.set(data, forKey: "MixodiaGameState")
    }

    func load() {
        guard let data = UserDefaults.standard.dictionary(forKey: "MixodiaGameState") else { return }
        if let e = data["essence"] as? Int { essence = e }
        if let d = data["discoveredIDs"] as? [String] { discoveredIDs = Set(d) }
        if let o = data["ownedCreatureIDs"] as? [String] { ownedCreatureIDs = o }
    }

    func reset() {
        essence = 10
        discoveredIDs = []
        ownedCreatureIDs = []
        headSelection = nil
        bodySelection = nil

        let starters: [(Element, Element)] = [
            (.fire, .fire), (.water, .water), (.earth, .earth), (.air, .air)
        ]
        for (head, body) in starters {
            let id = Creature.creatureID(head: head, body: body)
            discoveredIDs.insert(id)
            ownedCreatureIDs.append(id)
        }
        save()
    }

    // MARK: - State for Test Harness

    func stateDict() -> [String: Any] {
        return [
            "essence": essence,
            "discoveredCount": discoveredCount,
            "totalCreatures": totalCreatures,
            "mixodexProgress": mixodexProgress,
            "ownedCount": ownedCreatureIDs.count,
            "headSelection": headSelection?.id ?? NSNull(),
            "bodySelection": bodySelection?.id ?? NSNull(),
            "canMix": canMix()
        ]
    }
}
