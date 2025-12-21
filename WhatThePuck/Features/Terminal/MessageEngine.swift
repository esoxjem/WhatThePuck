import Foundation

struct MessageEngine {
    private let rules: [Rule]
    private let fallbackMessages: [String]

    private static let defaultFallback = "Let's pull a shot."

    init(jsonData: Data) throws {
        let schema = try JSONDecoder().decode(RuleSchema.self, from: jsonData)
        self.rules = schema.rules.sorted { $0.priority > $1.priority }
        self.fallbackMessages = schema.rules
            .first { $0.id == schema.fallbackPoolId }?
            .messages ?? []
    }

    func getMessage(context: MessageContext) -> String {
        let matchingRule = rules.first { rule in
            !rule.messages.isEmpty && evaluate(condition: rule.condition, context: context)
        }

        let rawMessage = selectRandomMessage(from: matchingRule?.messages)
        return processTemplate(rawMessage, context: context)
    }

    private func selectRandomMessage(from messages: [String]?) -> String {
        guard let messages = messages, !messages.isEmpty else {
            return fallbackMessages.randomElement() ?? Self.defaultFallback
        }
        return messages.randomElement() ?? Self.defaultFallback
    }

    private func evaluate(condition: Condition, context: MessageContext) -> Bool {
        switch condition {
        case .simple(let simpleCondition):
            return evaluateSimple(simpleCondition, context: context)
        case .and(let conditions):
            return conditions.allSatisfy { evaluate(condition: $0, context: context) }
        case .or(let conditions):
            return conditions.contains { evaluate(condition: $0, context: context) }
        }
    }

    private func evaluateSimple(_ condition: SimpleCondition, context: MessageContext) -> Bool {
        guard let contextValue = context.value(for: condition.type) else {
            return false
        }

        return applyOperator(condition.operator, contextValue: contextValue, ruleValue: condition.value)
    }

    private func applyOperator(_ op: ComparisonOperator, contextValue: ContextValue, ruleValue: ConditionValue) -> Bool {
        switch op {
        case .eq:
            return applyEquals(contextValue: contextValue, ruleValue: ruleValue)
        case .neq:
            return !applyEquals(contextValue: contextValue, ruleValue: ruleValue)
        case .gt:
            return applyComparison(contextValue: contextValue, ruleValue: ruleValue) { $0 > $1 }
        case .gte:
            return applyComparison(contextValue: contextValue, ruleValue: ruleValue) { $0 >= $1 }
        case .lt:
            return applyComparison(contextValue: contextValue, ruleValue: ruleValue) { $0 < $1 }
        case .lte:
            return applyComparison(contextValue: contextValue, ruleValue: ruleValue) { $0 <= $1 }
        case .between:
            return applyBetween(contextValue: contextValue, ruleValue: ruleValue)
        case .in:
            return applyIn(contextValue: contextValue, ruleValue: ruleValue)
        }
    }

    private func applyEquals(contextValue: ContextValue, ruleValue: ConditionValue) -> Bool {
        switch (contextValue, ruleValue) {
        case (.int(let ctx), .int(let rule)):
            return ctx == rule
        case (.string(let ctx), .string(let rule)):
            return ctx == rule
        case (.bool(let ctx), .bool(let rule)):
            return ctx == rule
        default:
            return false
        }
    }

    private func applyComparison(contextValue: ContextValue, ruleValue: ConditionValue, comparator: (Int, Int) -> Bool) -> Bool {
        guard case .int(let ctx) = contextValue,
              case .int(let rule) = ruleValue else {
            return false
        }
        return comparator(ctx, rule)
    }

    private func applyBetween(contextValue: ContextValue, ruleValue: ConditionValue) -> Bool {
        guard case .int(let ctx) = contextValue,
              case .intArray(let range) = ruleValue,
              range.count == 2 else {
            return false
        }
        return ctx >= range[0] && ctx <= range[1]
    }

    private func applyIn(contextValue: ContextValue, ruleValue: ConditionValue) -> Bool {
        switch (contextValue, ruleValue) {
        case (.int(let ctx), .intArray(let array)):
            return array.contains(ctx)
        case (.string(let ctx), .stringArray(let array)):
            return array.contains(ctx)
        default:
            return false
        }
    }

    private func processTemplate(_ message: String, context: MessageContext) -> String {
        let placeholderValues: [(String, String?)] = [
            ("{{bean.displayName}}", context.activeBeanDisplayName),
            ("{{bean.roastAge}}", context.activeBeanRoastAge),
            ("{{bean.roastLevel}}", context.activeBeanRoastLevel),
            ("{{shotCount}}", String(context.shotCount)),
            ("{{streakDays}}", String(context.streakDays))
        ]

        let lines = message.components(separatedBy: "\n")
        let processedLines = lines.compactMap { line in
            processLine(line, placeholderValues: placeholderValues)
        }

        return processedLines.joined(separator: "\n")
    }

    private func processLine(_ line: String, placeholderValues: [(String, String?)]) -> String? {
        var result = line

        for (placeholder, value) in placeholderValues {
            guard line.contains(placeholder) else { continue }
            guard let value = value else { return nil }
            result = result.replacingOccurrences(of: placeholder, with: value)
        }

        return result
    }
}
