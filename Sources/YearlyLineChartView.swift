import SwiftUI
import Charts

private let ratingEmojisY = ["", "😞", "😕", "😐", "😊", "😆"]

struct YearlyLineChartView: View {
    var selectedDate: Date?
    var ratings: [Int]
    var onPointTap: (Int) -> Void

    var body: some View {
        let data = ratings.enumerated()
            .map { (month: $0.offset + 1, rating: $0.element) }
            .filter { $0.rating > 0 }

        Chart(data, id: \.month) { item in
            LineMark(
                x: .value("Month", item.month),
                y: .value("Rating", item.rating)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(AppColors.accent)

            PointMark(
                x: .value("Month", item.month),
                y: .value("Rating", item.rating)
            )
            .foregroundStyle(genkiColors[item.rating - 1])
            .symbolSize(60)
        }
        .chartYScale(domain: 1...5)
        .chartYAxis {
            AxisMarks(position: .leading, values: [1, 2, 3, 4, 5]) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(ratingEmojisY[v]).font(.system(size: 12))
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: 1)) { value in
                AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    .foregroundStyle(AppColors.textSecondary.opacity(0.3))
                AxisValueLabel {
                    if let v = value.as(Int.self) {
                        Text(L10n.current == .ja ? "\(v)月" : "\(v)")
                            .font(.system(size: 9))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(Color.clear).contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                let x = value.location.x - geo[proxy.plotAreaFrame].origin.x
                                if let month: Int = proxy.value(atX: x) {
                                    onPointTap(month)
                                }
                            }
                    )
            }
        }
        .frame(height: 180)
    }
}
