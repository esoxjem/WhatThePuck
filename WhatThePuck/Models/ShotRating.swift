import Foundation

enum ShotRating: String, Codable, CaseIterable {
    case dialedIn
    case good
    case bad

    var jsonValue: String {
        switch self {
        case .dialedIn: return "dialed_in"
        case .good: return "good"
        case .bad: return "bad"
        }
    }

    var displayName: String {
        switch self {
        case .dialedIn: return "Dialed In"
        case .good: return "Good"
        case .bad: return "Bad"
        }
    }
}
