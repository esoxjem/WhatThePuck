import Testing
import Foundation
@testable import WhatThePuck

@Suite("Timer Display Formatting Tests")
struct TimerDisplayFormattingTests {

    @Test("formats zero as 00.0")
    func formatsZero() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 0)
        #expect(result == "00.0")
    }

    @Test("formats single tenths correctly")
    func formatsSingleTenths() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 1)
        #expect(result == "00.1")
    }

    @Test("formats nine tenths correctly")
    func formatsNineTenths() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 9)
        #expect(result == "00.9")
    }

    @Test("formats one second correctly")
    func formatsOneSecond() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 10)
        #expect(result == "01.0")
    }

    @Test("formats typical espresso shot time")
    func formatsTypicalShotTime() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 285)
        #expect(result == "28.5")
    }

    @Test("formats 30 seconds exactly")
    func formatsThirtySeconds() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 300)
        #expect(result == "30.0")
    }

    @Test("formats over one minute")
    func formatsOverOneMinute() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 650)
        #expect(result == "65.0")
    }

    @Test("formats with leading zero for single digit seconds")
    func formatsWithLeadingZero() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 55)
        #expect(result == "05.5")
    }

    @Test("formats two minutes")
    func formatsTwoMinutes() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 1200)
        #expect(result == "120.0")
    }

    @Test("formats boundary at 99 seconds")
    func formatsBoundaryAt99Seconds() {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: 999)
        #expect(result == "99.9")
    }
}

@Suite("Shot Time Formatting Tests")
struct ShotTimeFormattingTests {

    @Test("formats zero correctly")
    func formatsZero() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 0)
        #expect(result == "0.0s")
    }

    @Test("formats single tenth")
    func formatsSingleTenth() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 1)
        #expect(result == "0.1s")
    }

    @Test("formats typical shot time")
    func formatsTypicalShotTime() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 285)
        #expect(result == "28.5s")
    }

    @Test("formats exact seconds")
    func formatsExactSeconds() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 300)
        #expect(result == "30.0s")
    }

    @Test("formats long extraction")
    func formatsLongExtraction() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 450)
        #expect(result == "45.0s")
    }

    @Test("formats over one minute")
    func formatsOverOneMinute() {
        let result = TimeFormatting.formatShotTime(timeSeconds: 720)
        #expect(result == "72.0s")
    }
}

@Suite("Timer Display Edge Cases")
struct TimerDisplayEdgeCaseTests {

    @Test("different tenths values", arguments: [
        (0, "00.0"),
        (1, "00.1"),
        (5, "00.5"),
        (9, "00.9"),
        (10, "01.0"),
        (15, "01.5"),
        (99, "09.9"),
        (100, "10.0"),
        (255, "25.5"),
        (600, "60.0")
    ])
    func parameterizedTimerDisplay(tenths: Int, expected: String) {
        let result = TimeFormatting.formatTimerDisplay(elapsedTenths: tenths)
        #expect(result == expected)
    }
}
