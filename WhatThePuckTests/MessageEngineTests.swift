import Testing
import Foundation
@testable import WhatThePuck

@Suite("MessageEngine Tests")
struct MessageEngineTests {

    private func makeContext(
        shotCount: Int = 0,
        daysSinceLastShot: Int? = nil,
        streakDays: Int = 0,
        lastShotRating: String? = nil,
        consecutiveBadShots: Int = 0,
        isFirstDialedIn: Bool = false,
        beanCount: Int = 0,
        activeBeanDisplayName: String? = nil,
        activeBeanRoastAge: String? = nil,
        activeBeanRoastLevel: String? = nil,
        hour: Int = 12,
        dayOfWeek: Int = 1,
        month: Int = 6,
        uniqueBeansUsed: Int = 0,
        grindSettingsUsed: Int = 0,
        recentlyUnlockedAchievement: String? = nil,
        closestAchievementProgressPercent: Int? = nil,
        retroactiveUnlockCount: Int = 0
    ) -> MessageContext {
        MessageContext(
            shotCount: shotCount,
            daysSinceLastShot: daysSinceLastShot,
            streakDays: streakDays,
            lastShotRating: lastShotRating,
            consecutiveBadShots: consecutiveBadShots,
            isFirstDialedIn: isFirstDialedIn,
            beanCount: beanCount,
            activeBeanDisplayName: activeBeanDisplayName,
            activeBeanRoastAge: activeBeanRoastAge,
            activeBeanRoastLevel: activeBeanRoastLevel,
            hour: hour,
            dayOfWeek: dayOfWeek,
            month: month,
            uniqueBeansUsed: uniqueBeansUsed,
            grindSettingsUsed: grindSettingsUsed,
            recentlyUnlockedAchievement: recentlyUnlockedAchievement,
            closestAchievementProgressPercent: closestAchievementProgressPercent,
            retroactiveUnlockCount: retroactiveUnlockCount
        )
    }

    @Test("parses valid JSON schema")
    func parsesValidSchema() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Hello"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let message = engine.getMessage(context: makeContext())
        #expect(message == ["Hello"])
    }

    @Test("returns fallback when no rules match")
    func returnsFallbackWhenNoMatch() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "never",
                    "priority": 100,
                    "condition": { "type": "shot_count", "operator": "eq", "value": 999 },
                    "messages": [["Never shown"]]
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback message"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(shotCount: 0)
        let message = engine.getMessage(context: context)
        #expect(message == ["Fallback message"])
    }

    @Test("higher priority rule wins")
    func higherPriorityWins() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "low",
                    "priority": 10,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Low priority"]]
                },
                {
                    "id": "high",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["High priority"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let message = engine.getMessage(context: makeContext())
        #expect(message == ["High priority"])
    }

    @Test("AND condition requires all to match")
    func andConditionRequiresAll() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "both",
                    "priority": 100,
                    "condition": {
                        "and": [
                            { "type": "shot_count", "operator": "eq", "value": 5 },
                            { "type": "streak_days", "operator": "eq", "value": 3 }
                        ]
                    },
                    "messages": [["Both match"]]
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))

        let matchingContext = makeContext(shotCount: 5, streakDays: 3)
        #expect(engine.getMessage(context: matchingContext) == ["Both match"])

        let partialContext = makeContext(shotCount: 5, streakDays: 0)
        #expect(engine.getMessage(context: partialContext) == ["Fallback"])
    }

    @Test("OR condition matches any")
    func orConditionMatchesAny() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "either",
                    "priority": 100,
                    "condition": {
                        "or": [
                            { "type": "shot_count", "operator": "eq", "value": 5 },
                            { "type": "streak_days", "operator": "eq", "value": 3 }
                        ]
                    },
                    "messages": [["Either match"]]
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))

        let firstContext = makeContext(shotCount: 5, streakDays: 0)
        #expect(engine.getMessage(context: firstContext) == ["Either match"])

        let secondContext = makeContext(shotCount: 0, streakDays: 3)
        #expect(engine.getMessage(context: secondContext) == ["Either match"])

        let neitherContext = makeContext(shotCount: 0, streakDays: 0)
        #expect(engine.getMessage(context: neitherContext) == ["Fallback"])
    }

    @Test("skips rule when nil context field is required")
    func skipsRuleWhenNilContextField() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "needs_days",
                    "priority": 100,
                    "condition": { "type": "days_since_last_shot", "operator": "gte", "value": 7 },
                    "messages": [["Has days"]]
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(daysSinceLastShot: nil)
        #expect(engine.getMessage(context: context) == ["Fallback"])
    }

    @Test("processes bean displayName template")
    func processesBeanDisplayNameTemplate() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["{{bean.displayName}} loaded."]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(activeBeanDisplayName: "Ethiopian Yirgacheffe")
        #expect(engine.getMessage(context: context) == ["Ethiopian Yirgacheffe loaded."])
    }

    @Test("processes multiple templates in same line")
    func processesMultipleTemplates() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["{{bean.displayName}} - {{bean.roastLevel}}"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(activeBeanDisplayName: "Test Bean", activeBeanRoastLevel: "Dark roast.")
        #expect(engine.getMessage(context: context) == ["Test Bean - Dark roast."])
    }

    @Test("skips line when template value is nil")
    func skipsLineWhenTemplateValueIsNil() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["{{bean.displayName}} loaded."]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(activeBeanDisplayName: nil)
        #expect(engine.getMessage(context: context) == [])
    }

    @Test("skips only the line with nil value in multi-line message")
    func skipsOnlyLineWithNilValue() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Line 1.", "{{bean.roastAge}}", "Line 3."]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(activeBeanRoastAge: nil)
        #expect(engine.getMessage(context: context) == ["Line 1.", "Line 3."])
    }

    @Test("skips line when any placeholder on line has nil value")
    func skipsLineWhenAnyPlaceholderIsNil() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["{{bean.displayName}} - {{bean.roastAge}}"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        let context = makeContext(activeBeanDisplayName: "Test Bean", activeBeanRoastAge: nil)
        #expect(engine.getMessage(context: context) == [])
    }

    @Test("skips rules with empty messages")
    func skipsRulesWithEmptyMessages() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "empty",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": []
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))
        #expect(engine.getMessage(context: makeContext()) == ["Fallback"])
    }

    @Test("handles nested AND/OR conditions")
    func handlesNestedConditions() throws {
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "nested",
                    "priority": 100,
                    "condition": {
                        "and": [
                            { "type": "shot_count", "operator": "gte", "value": 10 },
                            {
                                "or": [
                                    { "type": "streak_days", "operator": "eq", "value": 7 },
                                    { "type": "streak_days", "operator": "eq", "value": 30 }
                                ]
                            }
                        ]
                    },
                    "messages": [["Nested match"]]
                },
                {
                    "id": "general",
                    "priority": 0,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [["Fallback"]]
                }
            ]
        }
        """
        let engine = try MessageEngine(jsonData: Data(json.utf8))

        let matchingContext = makeContext(shotCount: 50, streakDays: 7)
        #expect(engine.getMessage(context: matchingContext) == ["Nested match"])

        let noMatchContext = makeContext(shotCount: 50, streakDays: 5)
        #expect(engine.getMessage(context: noMatchContext) == ["Fallback"])
    }
}

@Suite("MessageEngine Template Processing Tests")
struct MessageEngineTemplateTests {

    private func makeEngineWithTemplate(_ lines: [String]) throws -> MessageEngine {
        let linesJson = lines.map { "\"\($0)\"" }.joined(separator: ", ")
        let json = """
        {
            "version": 2,
            "fallbackPoolId": "general",
            "conditionTypes": {},
            "operators": [],
            "rules": [
                {
                    "id": "template",
                    "priority": 100,
                    "condition": { "type": "always", "operator": "eq", "value": true },
                    "messages": [[\(linesJson)]]
                }
            ]
        }
        """
        return try MessageEngine(jsonData: Data(json.utf8))
    }

    @Test("shotCount template replacement")
    func shotCountTemplate() throws {
        let engine = try makeEngineWithTemplate(["You have {{shotCount}} shots."])
        let context = MessageContext(
            shotCount: 42,
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
            dayOfWeek: 1,
            month: 6,
            uniqueBeansUsed: 0,
            grindSettingsUsed: 0,
            recentlyUnlockedAchievement: nil,
            closestAchievementProgressPercent: nil,
            retroactiveUnlockCount: 0
        )
        #expect(engine.getMessage(context: context) == ["You have 42 shots."])
    }

    @Test("streakDays template replacement")
    func streakDaysTemplate() throws {
        let engine = try makeEngineWithTemplate(["{{streakDays}} day streak!"])
        let context = MessageContext(
            shotCount: 0,
            daysSinceLastShot: nil,
            streakDays: 7,
            lastShotRating: nil,
            consecutiveBadShots: 0,
            isFirstDialedIn: false,
            beanCount: 0,
            activeBeanDisplayName: nil,
            activeBeanRoastAge: nil,
            activeBeanRoastLevel: nil,
            hour: 12,
            dayOfWeek: 1,
            month: 6,
            uniqueBeansUsed: 0,
            grindSettingsUsed: 0,
            recentlyUnlockedAchievement: nil,
            closestAchievementProgressPercent: nil,
            retroactiveUnlockCount: 0
        )
        #expect(engine.getMessage(context: context) == ["7 day streak!"])
    }

    @Test("bean.roastAge template replacement")
    func beanRoastAgeTemplate() throws {
        let engine = try makeEngineWithTemplate(["{{bean.roastAge}}"])
        let context = MessageContext(
            shotCount: 0,
            daysSinceLastShot: nil,
            streakDays: 0,
            lastShotRating: nil,
            consecutiveBadShots: 0,
            isFirstDialedIn: false,
            beanCount: 1,
            activeBeanDisplayName: "Test",
            activeBeanRoastAge: "5 days off roast.",
            activeBeanRoastLevel: nil,
            hour: 12,
            dayOfWeek: 1,
            month: 6,
            uniqueBeansUsed: 0,
            grindSettingsUsed: 0,
            recentlyUnlockedAchievement: nil,
            closestAchievementProgressPercent: nil,
            retroactiveUnlockCount: 0
        )
        #expect(engine.getMessage(context: context) == ["5 days off roast."])
    }
}
