import SwiftUI
import SwiftData

struct BeanRowView: View {
    let bean: Bean

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(bean.name)
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 4) {
                if !bean.roaster.isEmpty {
                    compactLabel(bean.roaster, systemImage: "building.2")
                }

                compactLabel(bean.roastLevel.rawValue, systemImage: "flame")

                if let roastAge = bean.roastAgeDescription {
                    compactLabel(roastAge, systemImage: "calendar")
                }
            }
        }
        .padding(.vertical, 4)
    }

    private func compactLabel(_ text: String, systemImage: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: systemImage)
            Text(text)
        }
        .font(.caption)
        .imageScale(.small)
        .foregroundStyle(.secondary)
    }
}

#Preview {
    List {
        BeanRowView(bean: Bean(
            name: "Ethiopia Yirgacheffe",
            roaster: "Blue Bottle",
            roastLevel: .light,
            roastDate: Calendar.current.date(byAdding: .day, value: -14, to: .now)
        ))
        BeanRowView(bean: Bean(
            name: "House Blend",
            roastLevel: .medium
        ))
    }
    .modelContainer(for: Bean.self, inMemory: true)
}
