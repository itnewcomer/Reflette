import Foundation
import SwiftData

@Model
class Item {
    var timestamp: Date
    var rating: Int
    var memoText: String
    var timeSlot: String  // "morning", "afternoon", "evening"

    @Relationship(deleteRule: .cascade, inverse: \EmotionRecord.item)
    var emotionRecords: [EmotionRecord] = []

    // 後方互換: 感情名の配列
    var emotions: [String] {
        emotionRecords.map(\.emotionName)
    }

    // 後方互換: 感情ごとのメモ
    var emotionNotes: [String: String] {
        get {
            Dictionary(uniqueKeysWithValues: emotionRecords.map { ($0.emotionName, $0.note) })
        }
    }

    // 後方互換: 全タグ
    var tags: [String] {
        Array(Set(emotionRecords.flatMap(\.tags)))
    }

    // 後方互換: 感情ごとのタグ
    var emotionTags: [String: [String]] {
        Dictionary(uniqueKeysWithValues: emotionRecords.map { ($0.emotionName, $0.tags) })
    }

    init(timestamp: Date, rating: Int = 3, memoText: String = "", timeSlot: String = "") {
        self.timestamp = timestamp
        self.rating = rating
        self.memoText = memoText
        self.timeSlot = timeSlot.isEmpty ? TimeSlot.current.rawValue : timeSlot
    }

    // 後方互換イニシャライザ
    convenience init(
        timestamp: Date,
        rating: Int = 3,
        memoText: String = "",
        emotions: [String],
        emotionNotes: [String: String],
        tags: [String] = [],
        emotionTags: [String: [String]] = [:]
    ) {
        self.init(timestamp: timestamp, rating: rating, memoText: memoText)
        for emotion in emotions {
            let record = EmotionRecord(
                emotionName: emotion,
                note: emotionNotes[emotion] ?? ""
            )
            self.emotionRecords.append(record)
        }
    }
}

@Model
class EmotionRecord {
    var emotionName: String
    var note: String
    var item: Item?

    private static let tagRegex = try? NSRegularExpression(pattern: "#[\\p{L}0-9_]+")

    var tags: [String] {
        guard let regex = EmotionRecord.tagRegex else { return [] }
        let nsrange = NSRange(note.startIndex..., in: note)
        return regex.matches(in: note, range: nsrange).compactMap {
            Range($0.range, in: note).map { String(note[$0]) }
        }
    }

    init(emotionName: String, note: String = "") {
        self.emotionName = emotionName
        self.note = note
    }
}
