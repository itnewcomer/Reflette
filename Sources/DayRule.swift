import Foundation

enum DayRule: Codable, Equatable {
    case fixedDay(Int)                    // 毎月○日
    case nthWeekday(nth: Int, weekday: Int) // 第N○曜日 (weekday: 1=日,2=月...7=土)

    /// 指定月の該当日を計算
    func date(in month: Date) -> Date? {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: month)

        switch self {
        case .fixedDay(let day):
            guard let range = calendar.range(of: .day, in: .month, for: month) else { return nil }
            let clamped = Swift.min(day, range.upperBound - 1)
            return calendar.date(from: DateComponents(year: comps.year, month: comps.month, day: clamped))

        case .nthWeekday(let nth, let weekday):
            var dc = DateComponents(year: comps.year, month: comps.month, weekday: weekday, weekdayOrdinal: nth)
            return calendar.date(from: dc)
        }
    }

    /// 指定月の該当日（日にち）を返す
    func dayOfMonth(in month: Date) -> Int? {
        guard let d = date(in: month) else { return nil }
        return Calendar.current.component(.day, from: d)
    }

    // MARK: - 表示用
    var displayText: String {
        switch self {
        case .fixedDay(let day):
            return L10n.current == .ja ? "\(day)日" : "Day \(day)"
        case .nthWeekday(let nth, let weekday):
            let ordinals = L10n.current == .ja
                ? ["", "第1", "第2", "第3", "第4"]
                : ["", "1st", "2nd", "3rd", "4th"]
            let days = L10n.current == .ja
                ? ["", "日", "月", "火", "水", "木", "金", "土"]
                : ["", "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
            return "\(ordinals[nth]) \(days[weekday])"
        }
    }

    // MARK: - UserDefaults保存
    static func load(key: String, defaultDay: Int) -> DayRule {
        guard let data = UserDefaults.standard.data(forKey: key),
              let rule = try? JSONDecoder().decode(DayRule.self, from: data)
        else { return .fixedDay(defaultDay) }
        return rule
    }

    func save(key: String) {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
