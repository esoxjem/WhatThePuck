import SwiftUI
import SwiftData

struct AchievementGalleryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Shot.date, order: .reverse) private var shots: [Shot]

    private var allProgress: [AchievementProgress] {
        let tracker = AchievementTracker()
        return tracker.allProgress(shots: shots, modelContext: modelContext)
    }

    private var definitions: [AchievementDefinition] {
        AchievementDefinitionLoader.loadDefinitions()
    }

    private var groupedByCategory: [(AchievementCategory, [AchievementDefinition])] {
        let grouped = Dictionary(grouping: definitions) { $0.category }
        return AchievementCategory.displayOrder.compactMap { category in
            guard let achievements = grouped[category], !achievements.isEmpty else { return nil }
            return (category, achievements)
        }
    }

    var body: some View {
        List {
            ForEach(groupedByCategory, id: \.0) { category, achievements in
                Section(header: categoryHeader(category)) {
                    ForEach(achievements) { definition in
                        AchievementRowView(
                            definition: definition,
                            progress: progressFor(definition.id)
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryHeader(_ category: AchievementCategory) -> some View {
        Text(category.displayName)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
    }

    private func progressFor(_ definitionId: String) -> AchievementProgress? {
        allProgress.first { $0.definitionId == definitionId }
    }
}

private struct AchievementRowView: View {
    let definition: AchievementDefinition
    let progress: AchievementProgress?

    private var isUnlocked: Bool {
        progress?.isUnlocked ?? false
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                statusIndicator
                nameText
                Spacer()
                progressText
            }
            descriptionText
            if !isUnlocked, let progress {
                progressBar(progress)
            }
        }
        .padding(.vertical, 4)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }

    private var statusIndicator: some View {
        Text(isUnlocked ? "✓" : "○")
            .font(.system(.body, design: .monospaced))
            .foregroundStyle(isUnlocked ? .green : .secondary)
    }

    private var nameText: some View {
        Text(definition.name)
            .font(.system(.body, design: .monospaced))
            .fontWeight(isUnlocked ? .medium : .regular)
    }

    private var progressText: some View {
        Group {
            if let progress {
                Text("\(progress.current)/\(progress.target)")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var descriptionText: some View {
        Text(definition.description)
            .font(.system(.caption, design: .monospaced))
            .foregroundStyle(.secondary)
    }

    private func progressBar(_ progress: AchievementProgress) -> some View {
        let barWidth = 20
        let filled = Int(progress.percentage * Double(barWidth))
        let empty = barWidth - filled
        let filledChars = String(repeating: "▓", count: filled)
        let emptyChars = String(repeating: "░", count: empty)

        return Text(filledChars + emptyChars)
            .font(.system(.caption2, design: .monospaced))
            .foregroundStyle(.secondary)
    }
}

extension AchievementCategory {
    static var displayOrder: [AchievementCategory] {
        [.milestone, .consistency, .exploration, .mastery]
    }

    var displayName: String {
        switch self {
        case .milestone: return "MILESTONES"
        case .consistency: return "CONSISTENCY"
        case .exploration: return "EXPLORATION"
        case .mastery: return "MASTERY"
        }
    }
}

#Preview {
    NavigationStack {
        AchievementGalleryView()
    }
    .modelContainer(for: [Shot.self, Bean.self, Achievement.self], inMemory: true)
}
