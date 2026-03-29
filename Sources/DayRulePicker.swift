import SwiftUI

struct DayRulePicker: View {
    let label: String
    let key: String
    let defaultDay: Int

    @State private var mode: Int = 0  // 0=fixedDay, 1=nthWeekday
    @State private var fixedDay: Int = 1
    @State private var nth: Int = 1
    @State private var weekday: Int = 7 // 土曜

    private let weekdayNames: [String] = L10n.current == .ja
        ? ["日", "月", "火", "水", "木", "金", "土"]
        : ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)

            Picker("", selection: $mode) {
                Text(L10n.current == .ja ? "日付" : "Date").tag(0)
                Text(L10n.current == .ja ? "曜日" : "Weekday").tag(1)
            }
            .pickerStyle(.segmented)
            .onChange(of: mode) { _, _ in saveRule() }

            if mode == 0 {
                Picker("", selection: $fixedDay) {
                    ForEach(1...28, id: \.self) { Text(L10n.dayLabel($0)).tag($0) }
                }
                .pickerStyle(.menu)
                .onChange(of: fixedDay) { _, _ in saveRule() }
            } else {
                HStack {
                    Picker("", selection: $nth) {
                        ForEach(1...4, id: \.self) { n in
                            Text(L10n.current == .ja ? "第\(n)" : "\(n)\(ordinalSuffix(n))").tag(n)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: nth) { _, _ in saveRule() }

                    Picker("", selection: $weekday) {
                        ForEach(1...7, id: \.self) { w in
                            Text(weekdayNames[w - 1]).tag(w)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: weekday) { _, _ in saveRule() }
                }
            }
        }
        .onAppear { loadRule() }
    }

    private func loadRule() {
        let rule = DayRule.load(key: key, defaultDay: defaultDay)
        switch rule {
        case .fixedDay(let d):
            mode = 0; fixedDay = d
        case .nthWeekday(let n, let w):
            mode = 1; nth = n; weekday = w
        }
    }

    private func saveRule() {
        let rule: DayRule = mode == 0 ? .fixedDay(fixedDay) : .nthWeekday(nth: nth, weekday: weekday)
        rule.save(key: key)
    }

    private func ordinalSuffix(_ n: Int) -> String {
        switch n { case 1: return "st"; case 2: return "nd"; case 3: return "rd"; default: return "th" }
    }
}
