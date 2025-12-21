import Foundation
import SwiftData

enum ShotFiltering {

    static func filterShots(
        _ shots: [Shot],
        showFavoritesOnly: Bool,
        selectedBeanId: PersistentIdentifier?
    ) -> [Shot] {
        shots.filter { shot in
            let matchesFavorite = !showFavoritesOnly || shot.isFavorite
            let matchesBean = selectedBeanId == nil || shot.bean.id == selectedBeanId
            return matchesFavorite && matchesBean
        }
    }

    static func groupShotsByDate(_ shots: [Shot], calendar: Calendar = .current) -> [(Date, [Shot])] {
        let grouped = Dictionary(grouping: shots) { shot in
            calendar.startOfDay(for: shot.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    static func hasActiveFilters(showFavoritesOnly: Bool, selectedBean: Bean?) -> Bool {
        showFavoritesOnly || selectedBean != nil
    }

    static func buildFilterDescription(showFavoritesOnly: Bool, selectedBeanDisplayName: String?) -> String {
        var filters: [String] = []
        if showFavoritesOnly { filters.append("favorites") }
        if let beanName = selectedBeanDisplayName { filters.append(beanName) }
        return "No shots match: \(filters.joined(separator: ", "))"
    }
}
