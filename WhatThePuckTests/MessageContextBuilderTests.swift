import Testing
import Foundation
@testable import WhatThePuck

@Suite("MessageContextBuilder Tests")
struct MessageContextBuilderTests {

    private func makeBean(name: String = "Test Bean", roastLevel: RoastLevel = .medium, roastDate: Date? = nil) -> Bean {
        Bean(name: name, roaster: "", roastLevel: roastLevel, roastDate: roastDate)
    }

    private func makeShot(bean: Bean, date: Date = .now, rating: ShotRating? = nil) -> Shot {
        Shot(
            date: date,
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean,
            rating: rating
        )
    }

    private func makeCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    @Test("shotCount returns zero for empty shots")
    func shotCountZeroForEmpty() {
        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil
        )
        #expect(context.shotCount == 0)
    }

    @Test("shotCount returns correct count")
    func shotCountReturnsCount() {
        let bean = makeBean()
        let shots = [
            makeShot(bean: bean),
            makeShot(bean: bean),
            makeShot(bean: bean)
        ]
        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean
        )
        #expect(context.shotCount == 3)
    }

    @Test("daysSinceLastShot is nil for empty shots")
    func daysSinceLastShotNilForEmpty() {
        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil
        )
        #expect(context.daysSinceLastShot == nil)
    }

    @Test("daysSinceLastShot calculates correctly")
    func daysSinceLastShotCalculates() {
        let calendar = makeCalendar()
        let today = Date.now
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        let bean = makeBean()
        let shot = makeShot(bean: bean, date: threeDaysAgo)

        let context = MessageContextBuilder.buildContext(
            from: [shot],
            beans: [bean],
            activeBean: bean,
            currentDate: today,
            calendar: calendar
        )
        #expect(context.daysSinceLastShot == 3)
    }

    @Test("streakDays is zero for empty shots")
    func streakDaysZeroForEmpty() {
        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil
        )
        #expect(context.streakDays == 0)
    }

    @Test("streakDays counts consecutive days from today")
    func streakDaysCountsConsecutive() {
        let calendar = makeCalendar()
        let today = calendar.startOfDay(for: Date.now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: today)!

        let bean = makeBean()
        let shots = [
            makeShot(bean: bean, date: today),
            makeShot(bean: bean, date: yesterday),
            makeShot(bean: bean, date: twoDaysAgo)
        ]

        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean,
            currentDate: today,
            calendar: calendar
        )
        #expect(context.streakDays == 3)
    }

    @Test("streakDays breaks on gap")
    func streakDaysBreaksOnGap() {
        let calendar = makeCalendar()
        let today = calendar.startOfDay(for: Date.now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        let threeDaysAgo = calendar.date(byAdding: .day, value: -3, to: today)!

        let bean = makeBean()
        let shots = [
            makeShot(bean: bean, date: today),
            makeShot(bean: bean, date: yesterday),
            makeShot(bean: bean, date: threeDaysAgo)
        ]

        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean,
            currentDate: today,
            calendar: calendar
        )
        #expect(context.streakDays == 2)
    }

    @Test("lastShotRating is nil when no rating")
    func lastShotRatingNilWhenNoRating() {
        let bean = makeBean()
        let shot = makeShot(bean: bean, rating: nil)

        let context = MessageContextBuilder.buildContext(
            from: [shot],
            beans: [bean],
            activeBean: bean
        )
        #expect(context.lastShotRating == nil)
    }

    @Test("lastShotRating returns jsonValue of most recent shot")
    func lastShotRatingReturnsJsonValue() {
        let calendar = makeCalendar()
        let today = Date.now
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!

        let bean = makeBean()
        let oldShot = makeShot(bean: bean, date: yesterday, rating: .bad)
        let recentShot = makeShot(bean: bean, date: today, rating: .dialedIn)

        let context = MessageContextBuilder.buildContext(
            from: [oldShot, recentShot],
            beans: [bean],
            activeBean: bean,
            currentDate: today,
            calendar: calendar
        )
        #expect(context.lastShotRating == "dialed_in")
    }

    @Test("consecutiveBadShots counts from most recent")
    func consecutiveBadShotsCountsFromRecent() {
        let calendar = makeCalendar()
        let now = Date.now

        let bean = makeBean()
        let shots = [
            makeShot(bean: bean, date: now, rating: .bad),
            makeShot(bean: bean, date: calendar.date(byAdding: .hour, value: -1, to: now)!, rating: .bad),
            makeShot(bean: bean, date: calendar.date(byAdding: .hour, value: -2, to: now)!, rating: .bad),
            makeShot(bean: bean, date: calendar.date(byAdding: .hour, value: -3, to: now)!, rating: .good)
        ]

        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean,
            currentDate: now,
            calendar: calendar
        )
        #expect(context.consecutiveBadShots == 3)
    }

    @Test("consecutiveBadShots is zero when last shot is good")
    func consecutiveBadShotsZeroWhenGood() {
        let bean = makeBean()
        let shot = makeShot(bean: bean, rating: .good)

        let context = MessageContextBuilder.buildContext(
            from: [shot],
            beans: [bean],
            activeBean: bean
        )
        #expect(context.consecutiveBadShots == 0)
    }

    @Test("isFirstDialedIn is true when exactly one dialed_in shot")
    func isFirstDialedInTrueWhenOne() {
        let bean = makeBean()
        let shots = [
            makeShot(bean: bean, rating: .good),
            makeShot(bean: bean, rating: .dialedIn),
            makeShot(bean: bean, rating: .bad)
        ]

        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean
        )
        #expect(context.isFirstDialedIn == true)
    }

    @Test("isFirstDialedIn is false when multiple dialed_in shots")
    func isFirstDialedInFalseWhenMultiple() {
        let bean = makeBean()
        let shots = [
            makeShot(bean: bean, rating: .dialedIn),
            makeShot(bean: bean, rating: .dialedIn)
        ]

        let context = MessageContextBuilder.buildContext(
            from: shots,
            beans: [bean],
            activeBean: bean
        )
        #expect(context.isFirstDialedIn == false)
    }

    @Test("beanCount returns correct count")
    func beanCountReturnsCount() {
        let beans = [makeBean(name: "Bean 1"), makeBean(name: "Bean 2")]

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: beans,
            activeBean: nil
        )
        #expect(context.beanCount == 2)
    }

    @Test("activeBeanDisplayName is set from activeBean")
    func activeBeanDisplayNameSet() {
        let bean = makeBean(name: "Ethiopian")

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [bean],
            activeBean: bean
        )
        #expect(context.activeBeanDisplayName == "Ethiopian")
    }

    @Test("activeBeanRoastLevel includes roast suffix")
    func activeBeanRoastLevelIncludesSuffix() {
        let bean = makeBean(roastLevel: .dark)

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [bean],
            activeBean: bean
        )
        #expect(context.activeBeanRoastLevel == "Dark roast.")
    }

    @Test("dayOfWeek converts Sunday to 7")
    func dayOfWeekConvertsSunday() {
        var calendar = makeCalendar()
        let sunday = calendar.date(from: DateComponents(year: 2024, month: 1, day: 7))!

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil,
            currentDate: sunday,
            calendar: calendar
        )
        #expect(context.dayOfWeek == 7)
    }

    @Test("dayOfWeek converts Monday to 1")
    func dayOfWeekConvertsMonday() {
        var calendar = makeCalendar()
        let monday = calendar.date(from: DateComponents(year: 2024, month: 1, day: 8))!

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil,
            currentDate: monday,
            calendar: calendar
        )
        #expect(context.dayOfWeek == 1)
    }

    @Test("hour extracts correctly")
    func hourExtractsCorrectly() {
        var calendar = makeCalendar()
        let date = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1, hour: 14))!

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil,
            currentDate: date,
            calendar: calendar
        )
        #expect(context.hour == 14)
    }

    @Test("month extracts correctly")
    func monthExtractsCorrectly() {
        var calendar = makeCalendar()
        let date = calendar.date(from: DateComponents(year: 2024, month: 7, day: 1))!

        let context = MessageContextBuilder.buildContext(
            from: [],
            beans: [],
            activeBean: nil,
            currentDate: date,
            calendar: calendar
        )
        #expect(context.month == 7)
    }
}
