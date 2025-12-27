import SwiftUI

struct AchievementProgressView: View {
    let progress: AchievementProgress
    let definition: AchievementDefinition?

    private var progressBarWidth: Int { 10 }

    var body: some View {
        HStack(spacing: 8) {
            progressBar
            progressFraction
            achievementName
            Spacer()
        }
        .font(.system(.caption, design: .monospaced))
        .foregroundStyle(.secondary)
    }

    private var progressBar: some View {
        Text(progressBarText)
    }

    private var progressBarText: String {
        let filled = Int(progress.percentage * Double(progressBarWidth))
        let empty = progressBarWidth - filled
        let filledChars = String(repeating: "▓", count: filled)
        let emptyChars = String(repeating: "░", count: empty)
        return filledChars + emptyChars
    }

    private var progressFraction: some View {
        Text("\(progress.current)/\(progress.target)")
    }

    private var achievementName: some View {
        Text(definition?.name ?? progress.definitionId)
    }
}

#Preview {
    VStack(spacing: 16) {
        AchievementProgressView(
            progress: AchievementProgress(
                definitionId: "bean_counter",
                current: 4,
                target: 10,
                isUnlocked: false
            ),
            definition: AchievementDefinition(
                id: "bean_counter",
                name: "Bean Counter",
                description: "Try 10 different beans",
                category: .exploration,
                targetValue: 10,
                calculationType: .uniqueBeans,
                unlockMessages: [["Nice."]]
            )
        )

        AchievementProgressView(
            progress: AchievementProgress(
                definitionId: "steady_hand",
                current: 3,
                target: 5,
                isUnlocked: false
            ),
            definition: AchievementDefinition(
                id: "steady_hand",
                name: "Steady Hand",
                description: "5 consecutive shots within 1g yield variance",
                category: .consistency,
                targetValue: 5,
                calculationType: .ratioVariance,
                unlockMessages: [["Consistent."]]
            )
        )

        AchievementProgressView(
            progress: AchievementProgress(
                definitionId: "century",
                current: 87,
                target: 100,
                isUnlocked: false
            ),
            definition: AchievementDefinition(
                id: "century",
                name: "Century",
                description: "Pull 100 shots",
                category: .milestone,
                targetValue: 100,
                calculationType: .shotCount,
                unlockMessages: [["100 shots. A milestone."]]
            )
        )
    }
    .padding()
}
