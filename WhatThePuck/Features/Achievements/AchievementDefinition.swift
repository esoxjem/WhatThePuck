import Foundation

struct AchievementDefinition: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: AchievementCategory
    let targetValue: Int
    let calculationType: CalculationType
    let unlockMessages: [[String]]

    var randomUnlockMessage: [String] {
        unlockMessages.randomElement() ?? ["> Achievement unlocked."]
    }
}

enum AchievementCategory: String, Codable {
    case consistency
    case exploration
    case mastery
    case milestone
}

enum CalculationType: String, Codable {
    case shotCount
    case uniqueBeans
    case grindRange
    case ratioVariance
    case timeVariance
    case consecutiveDialedInDays
    case maxShotsWithSameBean
    case quickDialIn
}

struct AchievementDefinitions: Codable {
    let achievements: [AchievementDefinition]
}

enum AchievementDefinitionLoader {
    static func loadDefinitions() -> [AchievementDefinition] {
        guard let url = Bundle.main.url(forResource: "achievements", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let definitions = try? JSONDecoder().decode(AchievementDefinitions.self, from: data) else {
            return []
        }
        return definitions.achievements
    }

    static func definition(for id: String) -> AchievementDefinition? {
        loadDefinitions().first { $0.id == id }
    }
}
