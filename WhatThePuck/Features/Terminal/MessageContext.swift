import Foundation

struct MessageContext {
    let shotCount: Int
    let daysSinceLastShot: Int?
    let streakDays: Int
    let lastShotRating: String?
    let consecutiveBadShots: Int
    let isFirstDialedIn: Bool

    let beanCount: Int
    let activeBeanDisplayName: String?
    let activeBeanRoastAge: String?
    let activeBeanRoastLevel: String?

    let hour: Int
    let dayOfWeek: Int
    let month: Int

    func value(for conditionType: ConditionType) -> ContextValue? {
        switch conditionType {
        case .shotCount:
            return .int(shotCount)
        case .daysSinceLastShot:
            return daysSinceLastShot.map { .int($0) }
        case .streakDays:
            return .int(streakDays)
        case .lastShotRating:
            return lastShotRating.map { .string($0) }
        case .consecutiveBadShots:
            return .int(consecutiveBadShots)
        case .firstDialedIn:
            return .bool(isFirstDialedIn)
        case .hour:
            return .int(hour)
        case .dayOfWeek:
            return .int(dayOfWeek)
        case .month:
            return .int(month)
        case .always:
            return .bool(true)
        case .beanCount:
            return .int(beanCount)
        }
    }
}

enum ContextValue {
    case int(Int)
    case string(String)
    case bool(Bool)
}
