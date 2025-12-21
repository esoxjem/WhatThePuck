import Foundation

enum TimeFormatting {

    static func formatTimerDisplay(elapsedTenths: Int) -> String {
        let seconds = elapsedTenths / 10
        let tenths = elapsedTenths % 10
        return String(format: "%02d.%d", seconds, tenths)
    }

    static func formatShotTime(timeSeconds: Int) -> String {
        String(format: "%d.%ds", timeSeconds / 10, timeSeconds % 10)
    }
}
