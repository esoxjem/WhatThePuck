import Testing
import SwiftData
import Foundation
@testable import WhatThePuck

@Suite("Shot Model Tests")
struct ShotTests {

    private func makeTestBean() -> Bean {
        Bean(name: "Test Bean", roaster: "Test Roaster")
    }

    @Test("ratio calculates yield divided by dose")
    func ratioCalculation() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 2.0)
    }

    @Test("ratio returns 0 when dose is zero")
    func ratioWithZeroDose() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 0.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 0)
    }

    @Test("ratio returns 0 when dose is negative")
    func ratioWithNegativeDose() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: -18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 0)
    }

    @Test("ratio handles fractional values correctly")
    func ratioWithFractionalValues() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 17.5,
            yieldGrams: 38.5,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 2.2)
    }

    @Test("ratio handles ristretto ratio")
    func ratioRistretto() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 18.0,
            timeSeconds: 250,
            grindSetting: 12,
            bean: bean
        )
        #expect(shot.ratio == 1.0)
    }

    @Test("ratio handles lungo ratio")
    func ratioLungo() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 54.0,
            timeSeconds: 350,
            grindSetting: 18,
            bean: bean
        )
        #expect(shot.ratio == 3.0)
    }

    @Test("formattedRatio formats as 1:X.X")
    func formattedRatioStandard() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedRatio == "1:2.0")
    }

    @Test("formattedRatio rounds to one decimal place")
    func formattedRatioRounding() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 40.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedRatio == "1:2.2")
    }

    @Test("formattedRatio handles zero ratio")
    func formattedRatioZero() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 0.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedRatio == "1:0.0")
    }

    @Test("formattedRatio handles precise values")
    func formattedRatioPrecise() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 17.5,
            yieldGrams: 38.5,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedRatio == "1:2.2")
    }

    @Test("formattedTime converts tenths to seconds format")
    func formattedTimeStandard() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 285,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "28.5s")
    }

    @Test("formattedTime handles zero time")
    func formattedTimeZero() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 0,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "0.0s")
    }

    @Test("formattedTime handles single digit tenths")
    func formattedTimeSingleDigitTenths() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 9,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "0.9s")
    }

    @Test("formattedTime handles exact seconds")
    func formattedTimeExactSeconds() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 300,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "30.0s")
    }

    @Test("formattedTime handles over one minute")
    func formattedTimeOverOneMinute() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 650,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "65.0s")
    }

    @Test("formattedTime handles edge case at 10 tenths")
    func formattedTimeTenTenths() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 10,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.formattedTime == "1.0s")
    }

    @Test("isFavorite defaults to false")
    func isFavoriteDefaultsFalse() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.isFavorite == false)
    }

    @Test("isFavorite can be set to true on init")
    func isFavoriteCanBeSetTrue() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean,
            isFavorite: true
        )
        #expect(shot.isFavorite == true)
    }

    @Test("notes defaults to empty string")
    func notesDefaultsEmpty() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.notes == "")
    }

    @Test("notes can be set on init")
    func notesCanBeSet() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            notes: "Slightly channeled, tastes sour",
            bean: bean
        )
        #expect(shot.notes == "Slightly channeled, tastes sour")
    }

    @Test("date defaults to now")
    func dateDefaultsToNow() {
        let before = Date.now
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        let after = Date.now

        #expect(shot.date >= before)
        #expect(shot.date <= after)
    }

    @Test("bean relationship is required")
    func beanRelationshipIsRequired() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.bean === bean)
    }
}

@Suite("Shot Ratio Edge Cases")
struct ShotRatioEdgeCaseTests {

    private func makeTestBean() -> Bean {
        Bean(name: "Test Bean")
    }

    @Test("ratio with very small dose")
    func ratioWithVerySmallDose() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 0.001,
            yieldGrams: 36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 36000.0)
    }

    @Test("ratio with very large values")
    func ratioWithLargeValues() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 1000.0,
            yieldGrams: 2500.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 2.5)
    }

    @Test("ratio with zero yield")
    func ratioWithZeroYield() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: 0.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == 0.0)
    }

    @Test("ratio with negative yield")
    func ratioWithNegativeYield() {
        let bean = makeTestBean()
        let shot = Shot(
            doseGrams: 18.0,
            yieldGrams: -36.0,
            timeSeconds: 280,
            grindSetting: 15,
            bean: bean
        )
        #expect(shot.ratio == -2.0)
    }
}
