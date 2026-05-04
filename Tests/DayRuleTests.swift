import XCTest
@testable import Reflette

final class DayRuleTests: XCTestCase {

    private let calendar = Calendar.current

    private func date(year: Int, month: Int, day: Int = 1) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day))!
    }

    // MARK: - .fixedDay

    func testFixedDayInNormalMonth() {
        let rule = DayRule.fixedDay(15)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 3)), 15)
    }

    func testFixedDayClampedInShortMonth() {
        // 4月は30日まで → 31を指定すると30に丸める
        let rule = DayRule.fixedDay(31)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 4)), 30)
    }

    func testFixedDayClampedInFebruaryLeapYear() {
        // 2024 は閏年（29日）
        let rule = DayRule.fixedDay(31)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2024, month: 2)), 29)
    }

    func testFixedDayClampedInFebruaryNonLeap() {
        // 2026 は平年（28日）
        let rule = DayRule.fixedDay(31)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 2)), 28)
    }

    func testFixedDay31InJanuary() {
        let rule = DayRule.fixedDay(31)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 1)), 31)
    }

    // MARK: - .nthWeekday

    func testNthWeekdaySecondMonday() {
        // 2026年3月の第2月曜は3月9日
        let rule = DayRule.nthWeekday(nth: 2, weekday: 2)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 3)), 9)
    }

    func testNthWeekdayFirstSunday() {
        // 2026年3月の第1日曜は3月1日
        let rule = DayRule.nthWeekday(nth: 1, weekday: 1)
        XCTAssertEqual(rule.dayOfMonth(in: date(year: 2026, month: 3)), 1)
    }

    // MARK: - Codable

    func testFixedDayCodableRoundtrip() throws {
        let original = DayRule.fixedDay(15)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DayRule.self, from: data)
        XCTAssertEqual(original, decoded)
    }

    func testNthWeekdayCodableRoundtrip() throws {
        let original = DayRule.nthWeekday(nth: 3, weekday: 5)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DayRule.self, from: data)
        XCTAssertEqual(original, decoded)
    }
}
