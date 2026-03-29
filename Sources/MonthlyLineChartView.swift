import SwiftUI
import Charts

struct DayRating: Identifiable {
    let id = UUID()
    let day: Int
    let value: Int
}

private let ratingEmojis = ["", "😞", "😕", "😐", "😊", "😆"]

struct MonthlyLineChartView: View {
    let selectedDate: Date?
    let ratingsForDates: [Date: Int]
    @Binding var selectedDay: Int?

    var body: some View {
        let data = monthlyData.filter { $0.value > 0 }
        Chart(data) { item in
            LineMark(
                x: .value("Day", item.day),
                y: .value("Rating", item.value)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(AppColors.accent)
            PointMark(
                x: .value("Day", item.day),
                y: .value("Rating", item.value)
            )
            .foregroundStyle(genkiColors[item.value - 1])
            .symbolSize(40)
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(ratingEmojis[v]).font(.system(size: 12))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 5)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text("\(v)").font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let day: Int = proxy.value(atX: x) {
                                    selectedDay = min(max(day, 1), monthlyData.count)
                                }
                            }
                    )
            }
        }
    }

    private var monthlyData: [DayRating] {
        let calendar = Calendar.current
        guard let selectedDate = selectedDate,
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }
        return range.map { day in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
            let value = ratingsForDates[calendar.startOfDay(for: date)] ?? 0
            return DayRating(day: day, value: value)
        }
    }
}
