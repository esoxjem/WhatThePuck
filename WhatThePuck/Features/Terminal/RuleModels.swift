import Foundation

struct RuleSchema: Codable {
    let version: Int
    let fallbackPoolId: String
    let conditionTypes: [String: String]
    let operators: [String]
    let rules: [Rule]
}

struct Rule: Codable {
    let id: String
    let priority: Int
    let condition: Condition
    let messages: [String]
}

indirect enum Condition: Codable {
    case simple(SimpleCondition)
    case and([Condition])
    case or([Condition])

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CompoundConditionKeys.self)

        if let conditions = try container.decodeIfPresent([Condition].self, forKey: .and) {
            self = .and(conditions)
            return
        }

        if let conditions = try container.decodeIfPresent([Condition].self, forKey: .or) {
            self = .or(conditions)
            return
        }

        let simpleCondition = try SimpleCondition(from: decoder)
        self = .simple(simpleCondition)
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .simple(let condition):
            try condition.encode(to: encoder)
        case .and(let conditions):
            var container = encoder.container(keyedBy: CompoundConditionKeys.self)
            try container.encode(conditions, forKey: .and)
        case .or(let conditions):
            var container = encoder.container(keyedBy: CompoundConditionKeys.self)
            try container.encode(conditions, forKey: .or)
        }
    }

    private enum CompoundConditionKeys: String, CodingKey {
        case and
        case or
    }
}

struct SimpleCondition: Codable {
    let type: ConditionType
    let `operator`: ComparisonOperator
    let value: ConditionValue

    private enum CodingKeys: String, CodingKey {
        case type
        case `operator`
        case value
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(ConditionType.self, forKey: .type)
        `operator` = try container.decode(ComparisonOperator.self, forKey: .operator)
        value = try container.decode(ConditionValue.self, forKey: .value)
    }
}

enum ConditionType: String, Codable {
    case shotCount = "shot_count"
    case daysSinceLastShot = "days_since_last_shot"
    case streakDays = "streak_days"
    case lastShotRating = "last_shot_rating"
    case consecutiveBadShots = "consecutive_bad_shots"
    case firstDialedIn = "first_dialed_in"
    case hour
    case dayOfWeek = "day_of_week"
    case month
    case always
    case beanCount = "bean_count"
}

enum ComparisonOperator: String, Codable {
    case eq
    case neq
    case gt
    case gte
    case lt
    case lte
    case between
    case `in`
}

enum ConditionValue: Codable, Equatable {
    case int(Int)
    case string(String)
    case bool(Bool)
    case intArray([Int])
    case stringArray([String])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
            return
        }

        if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
            return
        }

        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
            return
        }

        if let intArray = try? container.decode([Int].self) {
            self = .intArray(intArray)
            return
        }

        if let stringArray = try? container.decode([String].self) {
            self = .stringArray(stringArray)
            return
        }

        throw DecodingError.typeMismatch(
            ConditionValue.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "Expected Int, String, Bool, [Int], or [String]"
            )
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .intArray(let value):
            try container.encode(value)
        case .stringArray(let value):
            try container.encode(value)
        }
    }

    var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }

    var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }

    var intArrayValue: [Int]? {
        if case .intArray(let value) = self { return value }
        return nil
    }

    var stringArrayValue: [String]? {
        if case .stringArray(let value) = self { return value }
        return nil
    }
}
