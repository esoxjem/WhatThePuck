import Testing
import Foundation
@testable import WhatThePuck

@Suite("ShotRating Tests")
struct ShotRatingTests {

    @Test("dialedIn jsonValue returns dialed_in")
    func dialedInJsonValue() {
        #expect(ShotRating.dialedIn.jsonValue == "dialed_in")
    }

    @Test("good jsonValue returns good")
    func goodJsonValue() {
        #expect(ShotRating.good.jsonValue == "good")
    }

    @Test("bad jsonValue returns bad")
    func badJsonValue() {
        #expect(ShotRating.bad.jsonValue == "bad")
    }

    @Test("dialedIn displayName returns Dialed In")
    func dialedInDisplayName() {
        #expect(ShotRating.dialedIn.displayName == "Dialed In")
    }

    @Test("good displayName returns Good")
    func goodDisplayName() {
        #expect(ShotRating.good.displayName == "Good")
    }

    @Test("bad displayName returns Bad")
    func badDisplayName() {
        #expect(ShotRating.bad.displayName == "Bad")
    }

    @Test("encodes and decodes correctly")
    func codableRoundTrip() throws {
        let original = ShotRating.dialedIn
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ShotRating.self, from: data)
        #expect(decoded == original)
    }

    @Test("all cases are iterable")
    func allCasesCount() {
        #expect(ShotRating.allCases.count == 3)
    }
}
