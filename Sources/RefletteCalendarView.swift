import SwiftUI

struct RefletteCalendarView: View {
    @Binding var selectedDate: Date?
    @Binding var displayedMonth: Date
    let ratingsForDates: [Date: Int]
    var onDoubleTap: (() -> Void)? = nil

    private let calendar = Calendar.current
    private let weekdaySymbols = Calendar.current.shortWeekdaySymbols
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var goalDay: Int { DayRule.load(key: "goalDayRule", defaultDay: 1).dayOfMonth(in: displayedMonth) ?? 1 }
    private var reflectDay: Int { DayRule.load(key: "reflectDayRule", defaultDay: 25).dayOfMonth(in: displayedMonth) ?? 25 }

    var body: some View {
        VStack(spacing: 6) {
            // 月ナビゲーション
            HStack {
                Button { changeMonth(-1) } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.accent)
                }
                Spacer()
                Text(monthYearString)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Button { changeMonth(1) } label: {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.accent)
                }
            }
            .padding(.horizontal, 8)

            // 曜日ヘッダー
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 日付グリッド
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(daysInMonth, id: \.self) { item in
                    if let date = item.date {
                        DayCellView(
                            date: date,
                            day: item.day,
                            isSelected: isSelected(date),
                            isToday: calendar.isDateInToday(date),
                            rating: ratingsForDates[calendar.startOfDay(for: date)],
                            isFirstDay: item.day == goalDay,
                            isLastDay: item.day == reflectDay
                        )
                        .onTapGesture(count: 2) {
                            // ダブルタップ: 選択 + 記録画面を開く
                            selectedDate = date
                            onDoubleTap?()
                        }
                        .onTapGesture(count: 1) {
                            // シングルタップ: 選択のみ
                            selectedDate = date
                        }
                    } else {
                        Color.clear.frame(height: 38)
                    }
                }
            }

            // 凡例
            HStack(spacing: 12) {
                legendItem(color: AppColors.zoneActive, text: L10n.current == .ja ? "\(goalDay)日 = 目標設定" : "\(goalDay)th = Set goals")
                legendItem(color: AppColors.zoneCalm, text: L10n.current == .ja ? "\(reflectDay)日 = 振り返り" : "\(reflectDay)th = Reflect")
            }
            .padding(.top, 2)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.width < -50 { changeMonth(1) }
                    else if value.translation.width > 50 { changeMonth(-1) }
                }
        )
    }

    // MARK: - Helpers

    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 3) {
            Circle().fill(color).frame(width: 6, height: 6)
            Text(text).font(.system(size: 8)).foregroundColor(AppColors.textSecondary)
        }
    }

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = L10n.current == .ja ? "yyyy年 M月" : "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }

    private func changeMonth(_ delta: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if let newMonth = calendar.date(byAdding: .month, value: delta, to: displayedMonth) {
                displayedMonth = newMonth
            }
        }
    }

    private func isSelected(_ date: Date) -> Bool {
        guard let selected = selectedDate else { return false }
        return calendar.isDate(date, inSameDayAs: selected)
    }

    private var daysInMonth: [DayItem] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstOfMonth = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth) else { return [] }

        let firstWeekday = calendar.component(.weekday, from: firstOfMonth)
        let offset = (firstWeekday - calendar.firstWeekday + 7) % 7

        var items: [DayItem] = (0..<offset).map { _ in DayItem(day: 0, date: nil) }

        for day in range {
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstOfMonth) else { continue }
            items.append(DayItem(day: day, date: date))
        }
        return items
    }
}

private struct DayItem: Hashable {
    let day: Int
    let date: Date?
}

private struct DayCellView: View {
    let date: Date
    let day: Int
    let isSelected: Bool
    let isToday: Bool
    let rating: Int?
    let isFirstDay: Bool
    let isLastDay: Bool

    private var textColor: Color {
        if isSelected { return .white }
        if isToday && rating == nil { return AppColors.today }
        if isFirstDay { return AppColors.zoneActive }
        if isLastDay { return AppColors.zoneCalm }
        // 明るい背景色（星3-4）の時は暗い文字
        if let rating, (3...4).contains(rating) {
            return Color(red: 0.15, green: 0.15, blue: 0.20)
        }
        return AppColors.textPrimary
    }

    private var fontWeight: Font.Weight {
        (isSelected || isFirstDay || isLastDay) ? .bold : .regular
    }

    var body: some View {
        Text("\(day)")
            .font(.system(size: 16, weight: fontWeight))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity, minHeight: 38)
            .background(
                ZStack {
                    if let rating, (1...5).contains(rating) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.ratingColors[rating - 1])
                    }
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.accent.opacity(0.4))
                    }
                    if isToday {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(AppColors.today, lineWidth: 2)
                    }
                }
            )
        .contentShape(Rectangle())
    }
}
