import Testing
import Foundation
import SwiftData
@testable import WhatThePuck

@Suite("Shot Filtering Tests")
struct ShotFilteringTests {

    private func makeTestBean(name: String = "Test Bean") -> Bean {
        Bean(name: name, roaster: "Test Roaster")
    }

    private func makeTestShot(bean: Bean, isFavorite: Bool = false) -> Shot {
        Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean,
            isFavorite: isFavorite
        )
    }

    @Test("returns all shots when no filters active")
    func noFiltersReturnsAll() {
        let bean = makeTestBean()
        let shots = [
            makeTestShot(bean: bean),
            makeTestShot(bean: bean),
            makeTestShot(bean: bean)
        ]

        let result = ShotFiltering.filterShots(
            shots,
            showFavoritesOnly: false,
            selectedBeanId: nil
        )

        #expect(result.count == 3)
    }

    @Test("filters by favorites only")
    func filtersByFavorites() {
        let bean = makeTestBean()
        let shots = [
            makeTestShot(bean: bean, isFavorite: true),
            makeTestShot(bean: bean, isFavorite: false),
            makeTestShot(bean: bean, isFavorite: true)
        ]

        let result = ShotFiltering.filterShots(
            shots,
            showFavoritesOnly: true,
            selectedBeanId: nil
        )

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.isFavorite })
    }

    @Test("filters by bean ID")
    func filtersByBean() {
        let beanA = makeTestBean(name: "Bean A")
        let beanB = makeTestBean(name: "Bean B")
        let shots = [
            makeTestShot(bean: beanA),
            makeTestShot(bean: beanB),
            makeTestShot(bean: beanA)
        ]

        let result = ShotFiltering.filterShots(
            shots,
            showFavoritesOnly: false,
            selectedBeanId: beanA.id
        )

        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.bean.id == beanA.id })
    }

    @Test("combines filters with AND logic")
    func combinesFiltersWithAnd() {
        let beanA = makeTestBean(name: "Bean A")
        let beanB = makeTestBean(name: "Bean B")
        let shots = [
            makeTestShot(bean: beanA, isFavorite: true),
            makeTestShot(bean: beanA, isFavorite: false),
            makeTestShot(bean: beanB, isFavorite: true),
            makeTestShot(bean: beanB, isFavorite: false)
        ]

        let result = ShotFiltering.filterShots(
            shots,
            showFavoritesOnly: true,
            selectedBeanId: beanA.id
        )

        #expect(result.count == 1)
        #expect(result.first?.bean.id == beanA.id)
        #expect(result.first?.isFavorite == true)
    }

    @Test("returns empty when no matches")
    func returnsEmptyWhenNoMatches() {
        let bean = makeTestBean()
        let shots = [
            makeTestShot(bean: bean, isFavorite: false),
            makeTestShot(bean: bean, isFavorite: false)
        ]

        let result = ShotFiltering.filterShots(
            shots,
            showFavoritesOnly: true,
            selectedBeanId: nil
        )

        #expect(result.isEmpty)
    }

    @Test("handles empty shots array")
    func handlesEmptyArray() {
        let result = ShotFiltering.filterShots(
            [],
            showFavoritesOnly: true,
            selectedBeanId: nil
        )

        #expect(result.isEmpty)
    }
}

@Suite("Shot Grouping Tests")
struct ShotGroupingTests {

    private func makeTestBean() -> Bean {
        Bean(name: "Test Bean")
    }

    private func makeTestShot(bean: Bean, date: Date) -> Shot {
        Shot(
            date: date,
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
    }

    @Test("groups shots by date")
    func groupsByDate() {
        let bean = makeTestBean()
        let calendar = Calendar.current
        let today = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let shots = [
            makeTestShot(bean: bean, date: today),
            makeTestShot(bean: bean, date: today),
            makeTestShot(bean: bean, date: yesterday)
        ]

        let result = ShotFiltering.groupShotsByDate(shots, calendar: calendar)

        #expect(result.count == 2)
    }

    @Test("sorts groups in reverse chronological order")
    func sortsReverseChronological() {
        let bean = makeTestBean()
        let calendar = Calendar.current
        let today = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let shots = [
            makeTestShot(bean: bean, date: twoDaysAgo),
            makeTestShot(bean: bean, date: today),
            makeTestShot(bean: bean, date: yesterday)
        ]

        let result = ShotFiltering.groupShotsByDate(shots, calendar: calendar)

        #expect(result.count == 3)
        #expect(result[0].0 > result[1].0)
        #expect(result[1].0 > result[2].0)
    }

    @Test("handles empty array")
    func handlesEmptyArray() {
        let result = ShotFiltering.groupShotsByDate([])
        #expect(result.isEmpty)
    }

    @Test("groups multiple shots on same day")
    func groupsMultipleShotsOnSameDay() {
        let bean = makeTestBean()
        let calendar = Calendar.current
        let morning = calendar.date(bySettingHour: 8, minute: 0, second: 0, of: Date.now)!
        let afternoon = calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date.now)!
        let evening = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date.now)!

        let shots = [
            makeTestShot(bean: bean, date: morning),
            makeTestShot(bean: bean, date: afternoon),
            makeTestShot(bean: bean, date: evening)
        ]

        let result = ShotFiltering.groupShotsByDate(shots, calendar: calendar)

        #expect(result.count == 1)
        #expect(result[0].1.count == 3)
    }
}

@Suite("Has Active Filters Tests")
struct HasActiveFiltersTests {

    @Test("returns false when no filters active")
    func noFiltersReturnsFalse() {
        let result = ShotFiltering.hasActiveFilters(
            showFavoritesOnly: false,
            selectedBean: nil
        )
        #expect(result == false)
    }

    @Test("returns true when favorites filter active")
    func favoritesFilterReturnsTrue() {
        let result = ShotFiltering.hasActiveFilters(
            showFavoritesOnly: true,
            selectedBean: nil
        )
        #expect(result == true)
    }

    @Test("returns true when bean filter active")
    func beanFilterReturnsTrue() {
        let bean = Bean(name: "Test Bean")
        let result = ShotFiltering.hasActiveFilters(
            showFavoritesOnly: false,
            selectedBean: bean
        )
        #expect(result == true)
    }

    @Test("returns true when both filters active")
    func bothFiltersReturnTrue() {
        let bean = Bean(name: "Test Bean")
        let result = ShotFiltering.hasActiveFilters(
            showFavoritesOnly: true,
            selectedBean: bean
        )
        #expect(result == true)
    }
}

@Suite("Filter Description Tests")
struct FilterDescriptionTests {

    @Test("builds description with favorites only")
    func buildsFavoritesDescription() {
        let result = ShotFiltering.buildFilterDescription(
            showFavoritesOnly: true,
            selectedBeanDisplayName: nil
        )
        #expect(result == "No shots match: favorites")
    }

    @Test("builds description with bean only")
    func buildsBeanDescription() {
        let result = ShotFiltering.buildFilterDescription(
            showFavoritesOnly: false,
            selectedBeanDisplayName: "Ethiopian Yirgacheffe"
        )
        #expect(result == "No shots match: Ethiopian Yirgacheffe")
    }

    @Test("builds description with both filters")
    func buildsCombinedDescription() {
        let result = ShotFiltering.buildFilterDescription(
            showFavoritesOnly: true,
            selectedBeanDisplayName: "Geisha"
        )
        #expect(result == "No shots match: favorites, Geisha")
    }

    @Test("builds description with no filters")
    func buildsEmptyDescription() {
        let result = ShotFiltering.buildFilterDescription(
            showFavoritesOnly: false,
            selectedBeanDisplayName: nil
        )
        #expect(result == "No shots match: ")
    }

    @Test("handles bean name with special characters")
    func handlesBeanNameWithSpecialChars() {
        let result = ShotFiltering.buildFilterDescription(
            showFavoritesOnly: false,
            selectedBeanDisplayName: "Bean - Roaster (2024)"
        )
        #expect(result == "No shots match: Bean - Roaster (2024)")
    }
}
