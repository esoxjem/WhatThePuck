import Testing
import Foundation
@testable import WhatThePuck

@Suite("Shot Date Formatting Tests")
struct ShotDateFormattingTests {

    @Test("formats today's date as Today")
    func formatsToday() {
        let today = Date.now
        let result = DateFormatting.formatShotDate(today)
        #expect(result == "Today")
    }

    @Test("formats yesterday's date as Yesterday")
    func formatsYesterday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date.now)!
        let result = DateFormatting.formatShotDate(yesterday, calendar: calendar)
        #expect(result == "Yesterday")
    }

    @Test("formats older date with abbreviated format")
    func formatsOlderDate() {
        let calendar = Calendar.current
        let twoDaysAgo = calendar.date(byAdding: .day, value: -2, to: Date.now)!
        let result = DateFormatting.formatShotDate(twoDaysAgo, calendar: calendar)
        #expect(result != "Today")
        #expect(result != "Yesterday")
        #expect(!result.isEmpty)
    }

    @Test("formats date from last week")
    func formatsLastWeek() {
        let calendar = Calendar.current
        let lastWeek = calendar.date(byAdding: .day, value: -7, to: Date.now)!
        let result = DateFormatting.formatShotDate(lastWeek, calendar: calendar)
        #expect(result != "Today")
        #expect(result != "Yesterday")
    }

    @Test("formats date from last month")
    func formatsLastMonth() {
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date.now)!
        let result = DateFormatting.formatShotDate(lastMonth, calendar: calendar)
        #expect(result != "Today")
        #expect(result != "Yesterday")
    }

    @Test("formats date from last year")
    func formatsLastYear() {
        let calendar = Calendar.current
        let lastYear = calendar.date(byAdding: .year, value: -1, to: Date.now)!
        let result = DateFormatting.formatShotDate(lastYear, calendar: calendar)
        #expect(result != "Today")
        #expect(result != "Yesterday")
    }
}

@Suite("Roast Age Description Tests")
struct RoastAgeDescriptionTests {

    @Test("returns nil for nil roast date")
    func returnsNilForNilDate() {
        let result = DateFormatting.roastAgeDescription(roastDate: nil)
        #expect(result == nil)
    }

    @Test("returns 0 days for today")
    func returnsZeroDaysForToday() {
        let result = DateFormatting.roastAgeDescription(roastDate: Date.now)
        #expect(result == "0 days off roast.")
    }

    @Test("returns 1 days for yesterday")
    func returnsOneDayForYesterday() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date.now)!
        let result = DateFormatting.roastAgeDescription(roastDate: yesterday, calendar: calendar)
        #expect(result == "1 days off roast.")
    }

    @Test("returns correct days for a week ago")
    func returnsSevenDaysForWeekAgo() {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date.now)!
        let result = DateFormatting.roastAgeDescription(roastDate: weekAgo, calendar: calendar)
        #expect(result == "7 days off roast.")
    }

    @Test("returns correct days for two weeks ago")
    func returnsFourteenDaysForTwoWeeksAgo() {
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date.now)!
        let result = DateFormatting.roastAgeDescription(roastDate: twoWeeksAgo, calendar: calendar)
        #expect(result == "14 days off roast.")
    }

    @Test("returns correct days for month ago")
    func returnsThirtyDaysForMonthAgo() {
        let calendar = Calendar.current
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date.now)!
        let result = DateFormatting.roastAgeDescription(roastDate: thirtyDaysAgo, calendar: calendar)
        #expect(result == "30 days off roast.")
    }

    @Test("handles different dates", arguments: [
        (0, "0 days off roast."),
        (-1, "1 days off roast."),
        (-5, "5 days off roast."),
        (-10, "10 days off roast."),
        (-21, "21 days off roast.")
    ])
    func parameterizedRoastAge(daysAgo: Int, expected: String) {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: daysAgo, to: Date.now)!
        let result = DateFormatting.roastAgeDescription(roastDate: date, calendar: calendar)
        #expect(result == expected)
    }
}
