import Foundation
import SwiftData

enum AchievementProgressCalculator {

    static func calculateProgress(
        for calculationType: CalculationType,
        shots: [Shot],
        calendar: Calendar = .current
    ) -> Int {
        switch calculationType {
        case .shotCount:
            return shots.count

        case .uniqueBeans:
            return countUniqueBeans(shots: shots)

        case .grindRange:
            return countUniqueGrindSettings(shots: shots)

        case .ratioVariance:
            return countConsecutiveTightYieldShots(shots: shots, maxVariance: 1.0, required: 5)

        case .timeVariance:
            return countConsecutiveTightTimeShots(shots: shots, maxVarianceSeconds: 2, required: 10)

        case .consecutiveDialedInDays:
            return countConsecutiveDialedInDays(shots: shots, calendar: calendar)

        case .maxShotsWithSameBean:
            return countMaxShotsWithSameBean(shots: shots)

        case .quickDialIn:
            return hasQuickDialIn(shots: shots) ? 1 : 0
        }
    }

    private static func countUniqueBeans(shots: [Shot]) -> Int {
        let uniqueBeanIds = Set(shots.map { $0.bean.persistentModelID })
        return uniqueBeanIds.count
    }

    private static func countUniqueGrindSettings(shots: [Shot]) -> Int {
        let uniqueSettings = Set(shots.map { $0.grindSetting })
        return uniqueSettings.count
    }

    private static func countConsecutiveTightYieldShots(
        shots: [Shot],
        maxVariance: Double,
        required: Int
    ) -> Int {
        let sortedShots = shots.sorted { $0.date > $1.date }
        guard sortedShots.count >= required else { return sortedShots.count }

        let recentShots = Array(sortedShots.prefix(required))
        let yields = recentShots.map { $0.yieldGrams }
        let range = yields.max()! - yields.min()!

        return range <= maxVariance ? required : required - 1
    }

    private static func countConsecutiveTightTimeShots(
        shots: [Shot],
        maxVarianceSeconds: Int,
        required: Int
    ) -> Int {
        let sortedShots = shots.sorted { $0.date > $1.date }
        guard sortedShots.count >= required else { return sortedShots.count }

        let recentShots = Array(sortedShots.prefix(required))
        let times = recentShots.map { $0.timeSeconds }
        let range = times.max()! - times.min()!

        let maxVarianceTenths = maxVarianceSeconds * 10
        return range <= maxVarianceTenths ? required : required - 1
    }

    private static func countConsecutiveDialedInDays(
        shots: [Shot],
        calendar: Calendar
    ) -> Int {
        let dialedInDates = shots
            .filter { $0.rating == .dialedIn }
            .map { calendar.startOfDay(for: $0.date) }

        let uniqueDays = Set(dialedInDates).sorted(by: >)
        guard let mostRecentDay = uniqueDays.first else { return 0 }

        var consecutiveDays = 0
        var checkDate = mostRecentDay

        for day in uniqueDays {
            if day == checkDate {
                consecutiveDays += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break
            }
        }

        return consecutiveDays
    }

    private static func countMaxShotsWithSameBean(shots: [Shot]) -> Int {
        var countsPerBean: [String: Int] = [:]
        for shot in shots {
            let beanId = shot.bean.persistentModelID.hashValue.description
            countsPerBean[beanId, default: 0] += 1
        }
        return countsPerBean.values.max() ?? 0
    }

    private static func hasQuickDialIn(shots: [Shot]) -> Bool {
        var shotsByBean: [String: [Shot]] = [:]

        for shot in shots {
            let beanId = shot.bean.persistentModelID.hashValue.description
            shotsByBean[beanId, default: []].append(shot)
        }

        for (_, beanShots) in shotsByBean {
            let sortedByDate = beanShots.sorted { $0.date < $1.date }
            let firstThree = sortedByDate.prefix(3)

            if firstThree.contains(where: { $0.rating == .dialedIn }) {
                return true
            }
        }

        return false
    }
}
