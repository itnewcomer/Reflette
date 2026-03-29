import XCTest
import SwiftData
@testable import Reflette

@MainActor
final class ItemTests: XCTestCase {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Item.self, EmotionRecord.self, configurations: config)
    }

    func testItemCreation() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(timestamp: Date(), rating: 4)
        context.insert(item)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let items = try context.fetch(descriptor)
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.rating, 4)
    }

    func testEmotionRecordRelationship() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(timestamp: Date(), rating: 3)
        let record1 = EmotionRecord(emotionName: "Happy", note: "良い日 #仕事")
        let record2 = EmotionRecord(emotionName: "Grateful", note: "#家族 に感謝")
        item.emotionRecords = [record1, record2]
        context.insert(item)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let items = try context.fetch(descriptor)
        let fetched = items.first!

        XCTAssertEqual(fetched.emotionRecords.count, 2)
        XCTAssertTrue(fetched.emotions.contains("Happy"))
        XCTAssertTrue(fetched.emotions.contains("Grateful"))
    }

    func testEmotionRecordTags() {
        let record = EmotionRecord(emotionName: "Stressed", note: "今日は #仕事 が大変で #残業 した")
        XCTAssertEqual(Set(record.tags), Set(["#仕事", "#残業"]))
    }

    func testEmotionRecordEmptyTags() {
        let record = EmotionRecord(emotionName: "Calm", note: "穏やかな日")
        XCTAssertTrue(record.tags.isEmpty)
    }

    func testItemEmotionNotes() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(timestamp: Date(), rating: 2)
        item.emotionRecords = [
            EmotionRecord(emotionName: "Sad", note: "つらい"),
            EmotionRecord(emotionName: "Tired", note: "疲れた"),
        ]
        context.insert(item)
        try context.save()

        let descriptor = FetchDescriptor<Item>()
        let fetched = try context.fetch(descriptor).first!

        XCTAssertEqual(fetched.emotionNotes["Sad"], "つらい")
        XCTAssertEqual(fetched.emotionNotes["Tired"], "疲れた")
    }

    func testItemEmotionTags() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(timestamp: Date(), rating: 3)
        item.emotionRecords = [
            EmotionRecord(emotionName: "Stressed", note: "#仕事 #締切"),
            EmotionRecord(emotionName: "Happy", note: "#趣味"),
        ]
        context.insert(item)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Item>()).first!
        XCTAssertEqual(Set(fetched.emotionTags["Stressed"]!), Set(["#仕事", "#締切"]))
        XCTAssertEqual(fetched.emotionTags["Happy"], ["#趣味"])
        XCTAssertTrue(fetched.tags.contains("#仕事"))
        XCTAssertTrue(fetched.tags.contains("#趣味"))
    }

    func testCascadeDelete() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let item = Item(timestamp: Date(), rating: 3)
        item.emotionRecords = [EmotionRecord(emotionName: "Joy", note: "")]
        context.insert(item)
        try context.save()

        context.delete(item)
        try context.save()

        let items = try context.fetch(FetchDescriptor<Item>())
        let records = try context.fetch(FetchDescriptor<EmotionRecord>())
        XCTAssertTrue(items.isEmpty)
        XCTAssertTrue(records.isEmpty)
    }
}
