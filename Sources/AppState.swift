import SwiftUI
import SwiftData

@Observable
class AppState {
    var selectedDate: Date? = Date()
    var selectedTab: Int = 0

    // 今月の1日
    var initialMonth: Date = {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comps)!
    }()
}
