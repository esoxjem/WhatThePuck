import SwiftData
import Foundation

@Observable
class AchievementTracker {
    private(set) var recentlyUnlockedAchievementId: String?
    private(set) var closestAchievementProgress: AchievementProgress?
    private(set) var retroactiveUnlockCount: Int = 0

    private let definitions: [AchievementDefinition]

    init() {
        self.definitions = AchievementDefinitionLoader.loadDefinitions()
    }

    @discardableResult
    func checkAchievements(
        shots: [Shot],
        modelContext: ModelContext,
        isRetroactive: Bool = false
    ) -> Int {
        recentlyUnlockedAchievementId = nil
        var newlyUnlockedCount = 0

        for definition in definitions {
            let achievement = fetchOrCreateAchievement(
                definitionId: definition.id,
                modelContext: modelContext
            )

            guard !achievement.isUnlocked else { continue }

            let progress = AchievementProgressCalculator.calculateProgress(
                for: definition.calculationType,
                shots: shots
            )

            achievement.updateProgress(progress)

            if progress >= definition.targetValue {
                achievement.unlock()
                newlyUnlockedCount += 1
                recentlyUnlockedAchievementId = definition.id
            }
        }

        if isRetroactive {
            retroactiveUnlockCount = newlyUnlockedCount
        }

        updateClosestAchievement(shots: shots, modelContext: modelContext)
        return newlyUnlockedCount
    }

    func getProgress(
        for definitionId: String,
        shots: [Shot],
        modelContext: ModelContext
    ) -> AchievementProgress? {
        guard let definition = definitions.first(where: { $0.id == definitionId }) else {
            return nil
        }

        let achievement = fetchOrCreateAchievement(
            definitionId: definitionId,
            modelContext: modelContext
        )

        let current = AchievementProgressCalculator.calculateProgress(
            for: definition.calculationType,
            shots: shots
        )

        return AchievementProgress(
            definitionId: definitionId,
            current: min(current, definition.targetValue),
            target: definition.targetValue,
            isUnlocked: achievement.isUnlocked
        )
    }

    func allProgress(
        shots: [Shot],
        modelContext: ModelContext
    ) -> [AchievementProgress] {
        definitions.compactMap { definition in
            getProgress(for: definition.id, shots: shots, modelContext: modelContext)
        }
    }

    func unlockedAchievements(modelContext: ModelContext) -> [Achievement] {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.unlockedAt != nil }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func recentlyUnlockedDefinition() -> AchievementDefinition? {
        guard let id = recentlyUnlockedAchievementId else { return nil }
        return definitions.first { $0.id == id }
    }

    func clearRetroactiveUnlockCount() {
        retroactiveUnlockCount = 0
    }

    private func fetchOrCreateAchievement(
        definitionId: String,
        modelContext: ModelContext
    ) -> Achievement {
        let descriptor = FetchDescriptor<Achievement>(
            predicate: #Predicate { $0.definitionId == definitionId }
        )

        if let existing = try? modelContext.fetch(descriptor).first {
            return existing
        }

        let newAchievement = Achievement(definitionId: definitionId)
        modelContext.insert(newAchievement)
        return newAchievement
    }

    private func updateClosestAchievement(
        shots: [Shot],
        modelContext: ModelContext
    ) {
        let allProgressItems = allProgress(shots: shots, modelContext: modelContext)
            .filter { !$0.isUnlocked && $0.percentage > 0 }
            .sorted { $0.percentage > $1.percentage }

        closestAchievementProgress = allProgressItems.first
    }
}

struct AchievementProgress {
    let definitionId: String
    let current: Int
    let target: Int
    let isUnlocked: Bool

    var percentage: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }

    var remaining: Int {
        max(target - current, 0)
    }
}
