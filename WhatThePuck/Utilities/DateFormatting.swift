import Foundation

enum DateFormatting {

    static func formatShotDate(_ date: Date, calendar: Calendar = .current) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
    }

    static func roastAgeDescription(roastDate: Date?, calendar: Calendar = .current) -> String? {
        guard let roastDate else { return nil }
        let days = calendar.dateComponents([.day], from: roastDate, to: .now).day ?? 0
        return "\(days) days off roast."
    }
}
