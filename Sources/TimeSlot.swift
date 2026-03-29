import Foundation

enum TimeSlot: String, CaseIterable, Codable {
    case morning, afternoon, evening

    var icon: String {
        switch self {
        case .morning: return "🌅"
        case .afternoon: return "☀️"
        case .evening: return "🌙"
        }
    }

    var label: String {
        switch self {
        case .morning: return L10n.current == .ja ? "朝" : "Morning"
        case .afternoon: return L10n.current == .ja ? "昼" : "Afternoon"
        case .evening: return L10n.current == .ja ? "夜" : "Evening"
        }
    }

    /// 現在時刻から自動判定（設定でカスタマイズ可能）
    static var current: TimeSlot {
        let hour = Calendar.current.component(.hour, from: Date())
        let morningEnd = UserDefaults.standard.object(forKey: "morningEnd") as? Int ?? 11
        let afternoonEnd = UserDefaults.standard.object(forKey: "afternoonEnd") as? Int ?? 17
        if hour < morningEnd { return .morning }
        if hour < afternoonEnd { return .afternoon }
        return .evening
    }
}
