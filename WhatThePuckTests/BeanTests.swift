import Testing
import SwiftData
import Foundation
@testable import WhatThePuck

@Suite("Bean Model Tests")
struct BeanTests {

    @Test("displayName returns only name when roaster is empty")
    func displayNameWithEmptyRoaster() {
        let bean = Bean(name: "Ethiopian Yirgacheffe", roaster: "")
        #expect(bean.displayName == "Ethiopian Yirgacheffe")
    }

    @Test("displayName returns name and roaster when roaster is provided")
    func displayNameWithRoaster() {
        let bean = Bean(name: "Geisha", roaster: "Onyx Coffee Lab")
        #expect(bean.displayName == "Geisha - Onyx Coffee Lab")
    }

    @Test("displayName handles whitespace-only roaster as empty")
    func displayNameWithWhitespaceRoaster() {
        let bean = Bean(name: "Bourbon", roaster: "   ")
        #expect(bean.displayName == "Bourbon -    ")
    }

    @Test("roastAgeDescription returns nil when roastDate is nil")
    func roastAgeDescriptionWithNoRoastDate() {
        let bean = Bean(name: "Test Bean", roastDate: nil)
        #expect(bean.roastAgeDescription == nil)
    }

    @Test("roastAgeDescription calculates days correctly for today")
    func roastAgeDescriptionForToday() {
        let bean = Bean(name: "Test Bean", roastDate: Date.now)
        #expect(bean.roastAgeDescription == "0 days off roast.")
    }

    @Test("roastAgeDescription calculates days correctly for past dates")
    func roastAgeDescriptionForPastDates() {
        let calendar = Calendar.current
        let fiveDaysAgo = calendar.date(byAdding: .day, value: -5, to: Date.now)!
        let bean = Bean(name: "Test Bean", roastDate: fiveDaysAgo)
        #expect(bean.roastAgeDescription == "5 days off roast.")
    }

    @Test("roastAgeDescription handles one day old roast")
    func roastAgeDescriptionOneDayOld() {
        let calendar = Calendar.current
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date.now)!
        let bean = Bean(name: "Test Bean", roastDate: yesterday)
        #expect(bean.roastAgeDescription == "1 days off roast.")
    }

    @Test("roastAgeDescription handles weeks old roast")
    func roastAgeDescriptionWeeksOld() {
        let calendar = Calendar.current
        let twoWeeksAgo = calendar.date(byAdding: .day, value: -14, to: Date.now)!
        let bean = Bean(name: "Test Bean", roastDate: twoWeeksAgo)
        #expect(bean.roastAgeDescription == "14 days off roast.")
    }

    @Test("default roastLevel is medium")
    func defaultRoastLevel() {
        let bean = Bean(name: "Test Bean")
        #expect(bean.roastLevel == .medium)
    }

    @Test("all RoastLevel cases have correct raw values")
    func roastLevelRawValues() {
        #expect(RoastLevel.light.rawValue == "Light")
        #expect(RoastLevel.medium.rawValue == "Medium")
        #expect(RoastLevel.mediumDark.rawValue == "Medium-Dark")
        #expect(RoastLevel.dark.rawValue == "Dark")
    }

    @Test("RoastLevel is CaseIterable with correct count")
    func roastLevelCaseIterable() {
        #expect(RoastLevel.allCases.count == 4)
    }

    @Test("bean initializer sets createdAt to now by default")
    func defaultCreatedAt() {
        let before = Date.now
        let bean = Bean(name: "Test Bean")
        let after = Date.now

        #expect(bean.createdAt >= before)
        #expect(bean.createdAt <= after)
    }

    @Test("bean initializer accepts custom createdAt")
    func customCreatedAt() {
        let customDate = Date(timeIntervalSince1970: 1000000)
        let bean = Bean(name: "Test Bean", createdAt: customDate)
        #expect(bean.createdAt == customDate)
    }

    @Test("shots array initializes as empty")
    func shotsArrayInitializesEmpty() {
        let bean = Bean(name: "Test Bean")
        #expect(bean.shots.isEmpty)
    }
}

@Suite("RoastLevel Codable Tests")
struct RoastLevelCodableTests {

    @Test("RoastLevel encodes and decodes correctly", arguments: RoastLevel.allCases)
    func roastLevelCodable(level: RoastLevel) throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let encoded = try encoder.encode(level)
        let decoded = try decoder.decode(RoastLevel.self, from: encoded)

        #expect(decoded == level)
    }

    @Test("RoastLevel decodes from raw string value")
    func roastLevelDecodesFromString() throws {
        let decoder = JSONDecoder()

        let lightData = "\"Light\"".data(using: .utf8)!
        let light = try decoder.decode(RoastLevel.self, from: lightData)
        #expect(light == .light)

        let darkData = "\"Dark\"".data(using: .utf8)!
        let dark = try decoder.decode(RoastLevel.self, from: darkData)
        #expect(dark == .dark)
    }
}
