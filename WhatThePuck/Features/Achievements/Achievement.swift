import SwiftData
import Foundation

@Model
class Achievement {
    var definitionId: String
    var unlockedAt: Date?
    var currentProgress: Int
    var lastCalculatedAt: Date

    var isUnlocked: Bool { unlockedAt != nil }

    init(definitionId: String, currentProgress: Int = 0) {
        self.definitionId = definitionId
        self.currentProgress = currentProgress
        self.lastCalculatedAt = .now
    }

    func unlock() {
        guard !isUnlocked else { return }
        unlockedAt = .now
    }

    func updateProgress(_ progress: Int) {
        currentProgress = progress
        lastCalculatedAt = .now
    }
}
