import SwiftData
import Foundation

@Model
class Shot {
    var date: Date
    var doseGrams: Double
    var yieldGrams: Double
    var timeSeconds: Int
    var grindSetting: Int
    var notes: String
    var bean: Bean
    var isFavorite: Bool = false

    var ratio: Double {
        guard doseGrams > 0 else { return 0 }
        return yieldGrams / doseGrams
    }

    var formattedRatio: String {
        String(format: "1:%.1f", ratio)
    }

    var formattedTime: String {
        String(format: "%d.%ds", timeSeconds / 10, timeSeconds % 10)
    }

    init(
        date: Date = .now,
        doseGrams: Double,
        yieldGrams: Double,
        timeSeconds: Int,
        grindSetting: Int,
        notes: String = "",
        bean: Bean,
        isFavorite: Bool = false
    ) {
        self.date = date
        self.doseGrams = doseGrams
        self.yieldGrams = yieldGrams
        self.timeSeconds = timeSeconds
        self.grindSetting = grindSetting
        self.notes = notes
        self.bean = bean
        self.isFavorite = isFavorite
    }
}
