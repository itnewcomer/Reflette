import XCTest
@testable import Reflette

final class MonthlyGoalCodableTests: XCTestCase {

    // MARK: - 後方互換: 古い JSON（dueDate 無し）からのデコード

    /// v1.0.x で保存された JSON は GoalTask に dueDate フィールドが無い。
    /// 1.1.x で dueDate Optional を追加しても、古いデータが nil dueDate で
    /// 正常にデコードできることを保証する。
    func testDecodeLegacyGoalTaskWithoutDueDate() throws {
        let legacyJSON = """
        {
            "id": "12345678-1234-1234-1234-123456789ABC",
            "title": "Read 5 books",
            "isCompleted": false
        }
        """
        let data = legacyJSON.data(using: .utf8)!
        let decoded = try JSONDecoder().decode(GoalTask.self, from: data)
        XCTAssertEqual(decoded.title, "Read 5 books")
        XCTAssertFalse(decoded.isCompleted)
        XCTAssertNil(decoded.dueDate)
    }

    func testDecodeLegacyMonthlyGoalArray() throws {
        let legacyJSON = """
        [
            {
                "id": "11111111-1111-1111-1111-111111111111",
                "year": 2025,
                "month": 1,
                "excitedGoals": [
                    {"id": "22222222-2222-2222-2222-222222222222", "title": "Learn Swift", "isCompleted": true}
                ],
                "stretchGoals": [],
                "tasks": [
                    {"id": "33333333-3333-3333-3333-333333333333", "title": "Daily journal", "isCompleted": false}
                ],
                "letterToSelf": "頑張った"
            }
        ]
        """
        let data = legacyJSON.data(using: .utf8)!
        let goals = try JSONDecoder().decode([MonthlyGoal].self, from: data)
        XCTAssertEqual(goals.count, 1)
        XCTAssertEqual(goals[0].year, 2025)
        XCTAssertEqual(goals[0].month, 1)
        XCTAssertEqual(goals[0].excitedGoals.count, 1)
        XCTAssertTrue(goals[0].excitedGoals[0].isCompleted)
        XCTAssertNil(goals[0].excitedGoals[0].dueDate)
        XCTAssertEqual(goals[0].letterToSelf, "頑張った")
    }

    // MARK: - 新形式 (dueDate あり) のラウンドトリップ

    func testGoalTaskWithDueDateRoundtrip() throws {
        let dueDate = Calendar.current.date(from: DateComponents(year: 2026, month: 6, day: 15))!
        let original = GoalTask(title: "Submit paper", isCompleted: false, dueDate: dueDate)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(GoalTask.self, from: data)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.dueDate, original.dueDate)
        XCTAssertEqual(decoded.id, original.id)
    }

    func testMonthlyGoalRoundtripWithMixedTasks() throws {
        let dueDate = Calendar.current.date(from: DateComponents(year: 2026, month: 5, day: 20))!
        let goal = MonthlyGoal(
            id: UUID(),
            year: 2026,
            month: 5,
            excitedGoals: [GoalTask(title: "A", isCompleted: false, dueDate: dueDate)],
            stretchGoals: [GoalTask(title: "B", isCompleted: true)],
            tasks: [
                GoalTask(title: "C", isCompleted: false),
                GoalTask(title: "D", isCompleted: false, dueDate: dueDate)
            ],
            letterToSelf: ""
        )
        let data = try JSONEncoder().encode(goal)
        let decoded = try JSONDecoder().decode(MonthlyGoal.self, from: data)
        XCTAssertEqual(decoded, goal)
    }
}
