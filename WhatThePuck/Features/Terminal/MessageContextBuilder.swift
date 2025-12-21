import Foundation

enum MessageContextBuilder {
    static func buildContext(
        from shots: [Shot],
        beans: [Bean],
        activeBean: Bean?,
        currentDate: Date = .now,
        calendar: Calendar = .current
    ) -> MessageContext {
        let sortedShots = shots.sorted { $0.date > $1.date }

        return MessageContext(
            shotCount: shots.count,
            daysSinceLastShot: calculateDaysSinceLastShot(shots: sortedShots, currentDate: currentDate, calendar: calendar),
            streakDays: calculateStreakDays(shots: sortedShots, currentDate: currentDate, calendar: calendar),
            lastShotRating: extractLastShotRating(shots: sortedShots),
            consecutiveBadShots: countConsecutiveBadShots(shots: sortedShots),
            isFirstDialedIn: checkIsFirstDialedIn(shots: shots),
            beanCount: beans.count,
            activeBeanDisplayName: activeBean?.displayName,
            activeBeanRoastAge: activeBean?.roastAgeDescription,
            activeBeanRoastLevel: activeBean.map { "\($0.roastLevel.rawValue) roast." },
            hour: calendar.component(.hour, from: currentDate),
            dayOfWeek: convertToISOWeekday(calendar.component(.weekday, from: currentDate)),
            month: calendar.component(.month, from: currentDate)
        )
    }

    private static func calculateDaysSinceLastShot(shots: [Shot], currentDate: Date, calendar: Calendar) -> Int? {
        guard let lastShot = shots.first else { return nil }
        return calendar.dateComponents([.day], from: lastShot.date, to: currentDate).day
    }

    private static func calculateStreakDays(shots: [Shot], currentDate: Date, calendar: Calendar) -> Int {
        guard !shots.isEmpty else { return 0 }

        let shotDays = Set(shots.map { calendar.startOfDay(for: $0.date) })
        var streakCount = 0
        var checkDate = calendar.startOfDay(for: currentDate)

        while shotDays.contains(checkDate) {
            streakCount += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streakCount
    }

    private static func extractLastShotRating(shots: [Shot]) -> String? {
        shots.first?.rating?.jsonValue
    }

    private static func countConsecutiveBadShots(shots: [Shot]) -> Int {
        var count = 0
        for shot in shots {
            guard shot.rating == .bad else { break }
            count += 1
        }
        return count
    }

    private static func checkIsFirstDialedIn(shots: [Shot]) -> Bool {
        shots.filter { $0.rating == .dialedIn }.count == 1
    }

    private static func convertToISOWeekday(_ calendarWeekday: Int) -> Int {
        (calendarWeekday + 5) % 7 + 1
    }
}
