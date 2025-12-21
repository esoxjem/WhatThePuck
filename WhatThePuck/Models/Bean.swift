import SwiftData
import Foundation

enum RoastLevel: String, Codable, CaseIterable {
    case light = "Light"
    case medium = "Medium"
    case mediumDark = "Medium-Dark"
    case dark = "Dark"
}

@Model
class Bean {
    var name: String
    var roaster: String
    var roastLevel: RoastLevel
    var roastDate: Date?
    var createdAt: Date
    @Relationship(deleteRule: .cascade, inverse: \Shot.bean)
    var shots: [Shot] = []

    var displayName: String {
        roaster.isEmpty ? name : "\(name) - \(roaster)"
    }

    var roastAgeDescription: String? {
        guard let roastDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: roastDate, to: .now).day ?? 0
        return "\(days) days off roast."
    }

    init(
        name: String,
        roaster: String = "",
        roastLevel: RoastLevel = .medium,
        roastDate: Date? = nil,
        createdAt: Date = .now
    ) {
        self.name = name
        self.roaster = roaster
        self.roastLevel = roastLevel
        self.roastDate = roastDate
        self.createdAt = createdAt
    }
}
