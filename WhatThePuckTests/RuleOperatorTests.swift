import Testing
import Foundation
@testable import WhatThePuck

@Suite("Rule Operator Tests")
struct RuleOperatorTests {

    private func makeEngine(ruleJson: String) throws -> MessageEngine {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "fallback",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                \(ruleJson),
                {
                    "id": "fallback",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["fallback"]]
                }
            ]
        }
        """
        return try MessageEngine(jsonData: Data(json.utf8))
    }

    private func makeContext(shotCount: Int = 0, dayOfWeek: Int = 1) -> MessageContext {
        MessageContext(
            shotCount: shotCount,
            daysSinceLastShot: nil,
            streakDays: 0,
            lastShotRating: nil,
            consecutiveBadShots: 0,
            isFirstDialedIn: false,
            beanCount: 0,
            activeBeanDisplayName: nil,
            activeBeanRoastAge: nil,
            activeBeanRoastLevel: nil,
            hour: 12,
            dayOfWeek: dayOfWeek,
            month: 6
        )
    }

    @Test("eq matches when values are equal")
    func eqMatches() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "eq", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["matched"])
    }

    @Test("eq does not match when values differ")
    func eqDoesNotMatch() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "eq", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 10)) == ["fallback"])
    }

    @Test("neq matches when values differ")
    func neqMatches() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "neq", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 10)) == ["matched"])
    }

    @Test("neq does not match when values are equal")
    func neqDoesNotMatch() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "neq", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["fallback"])
    }

    @Test("gt matches when context is greater")
    func gtMatches() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "gt", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 10)) == ["matched"])
    }

    @Test("gt does not match when context is equal")
    func gtDoesNotMatchEqual() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "gt", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["fallback"])
    }

    @Test("gte matches when context is greater")
    func gteMatchesGreater() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "gte", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 10)) == ["matched"])
    }

    @Test("gte matches when context is equal")
    func gteMatchesEqual() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "gte", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["matched"])
    }

    @Test("lt matches when context is less")
    func ltMatches() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "lt", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 3)) == ["matched"])
    }

    @Test("lt does not match when context is equal")
    func ltDoesNotMatchEqual() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "lt", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["fallback"])
    }

    @Test("lte matches when context is less")
    func lteMatchesLess() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "lte", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 3)) == ["matched"])
    }

    @Test("lte matches when context is equal")
    func lteMatchesEqual() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "lte", "value": 5 },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["matched"])
    }

    @Test("between matches when value is in range")
    func betweenMatchesInRange() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "between", "value": [5, 10] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 7)) == ["matched"])
    }

    @Test("between matches at lower bound")
    func betweenMatchesLowerBound() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "between", "value": [5, 10] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 5)) == ["matched"])
    }

    @Test("between matches at upper bound")
    func betweenMatchesUpperBound() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "between", "value": [5, 10] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 10)) == ["matched"])
    }

    @Test("between does not match below range")
    func betweenDoesNotMatchBelow() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "between", "value": [5, 10] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 4)) == ["fallback"])
    }

    @Test("between does not match above range")
    func betweenDoesNotMatchAbove() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "shot_count", "operator": "between", "value": [5, 10] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(shotCount: 11)) == ["fallback"])
    }

    @Test("in matches when value is in array")
    func inMatchesInArray() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "day_of_week", "operator": "in", "value": [1, 3, 5] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(dayOfWeek: 3)) == ["matched"])
    }

    @Test("in does not match when value is not in array")
    func inDoesNotMatch() throws {
        let ruleJson = """
        {
            "id": "test",
            "priority": 100,
            "condition": { "type": "day_of_week", "operator": "in", "value": [1, 3, 5] },
            "messages": [["matched"]]
        }
        """
        let engine = try makeEngine(ruleJson: ruleJson)
        #expect(engine.getMessage(context: makeContext(dayOfWeek: 2)) == ["fallback"])
    }
}
