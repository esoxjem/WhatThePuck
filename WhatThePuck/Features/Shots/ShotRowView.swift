import SwiftUI
import SwiftData

struct ShotRowView: View {
    let shot: Shot

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(doseYieldDisplay)
                    .font(.headline)
                if shot.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                Spacer()
                Text(shot.formattedRatio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(shot.bean.displayName)
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                    Text(shot.formattedTime)
                }
                HStack(spacing: 2) {
                    Image(systemName: "gearshape")
                    Text("Grind \(shot.grindSetting)")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            if !shot.notes.isEmpty {
                Text(shot.notes)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private var doseYieldDisplay: String {
        String(format: "%.1fg → %.1fg", shot.doseGrams, shot.yieldGrams)
    }
}
