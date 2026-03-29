import SwiftUI
import Charts

let genkiColors: [Color] = AppColors.ratingColors

struct TagEmotionSelection: Identifiable, Equatable {
    let tag: String
    let emotion: String
    var id: String { "\(tag)_\(emotion)" }
}

struct ReportView: View {
    @Binding var selectedDate: Date?
    var ratingsForDates: [Date: Int]
    var items: [Item]
    @State private var reportType: ReportType = .monthly
    @State private var selectedDay: Int? = nil
    @State private var selectedTagEmotion: TagEmotionSelection? = nil

    enum ReportType: String, CaseIterable {
        case monthly, yearly
        var label: String {
            switch self {
            case .monthly: return L10n.monthly
            case .yearly: return L10n.yearly
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                // ヘッダー: 種別切り替え + 月セレクター
                VStack(spacing: 10) {
                    Picker(L10n.reportType, selection: $reportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Text(type.label).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)

                    if reportType == .monthly, let bindingDate = Binding($selectedDate) {
                        MonthSelector(selectedDate: bindingDate)
                    }
                }
                .card()

                // グラフ
                VStack(alignment: .leading, spacing: 8) {
                    Text(reportType == .monthly ? L10n.monthlyReport : L10n.yearlyReport)
                        .font(.subheadline).bold()
                        .foregroundColor(AppColors.textSecondary)

                    if reportType == .monthly {
                        MonthlyLineChartView(
                            selectedDate: selectedDate,
                            ratingsForDates: ratingsForDates,
                            selectedDay: $selectedDay
                        )
                        .frame(height: 180)

                        if let day = selectedDay, let value = monthlyRatings[safe: day-1] {
                            Text("\(day)日: \(value == 0 ? L10n.noData : String(value))")
                                .font(.caption).foregroundColor(AppColors.accent)
                        }
                    } else {
                        YearlyLineChartView(
                            selectedDate: selectedDate,
                            ratings: yearlyRatings,
                            onPointTap: { _ in }
                        )
                        .frame(height: 180)
                    }

                    // 分布バー（グラフカード内に統合）
                    DistributionBarView(
                        reportType: reportType,
                        selectedDate: selectedDate,
                        ratingsForDates: ratingsForDates
                    )
                }
                .card()

                // インサイト（最重要 → グラフの直後）
                InsightView(
                    items: items,
                    selectedDate: selectedDate,
                    reportType: reportType
                )

                // 感情マップ
                EmotionSummaryView(
                    items: items,
                    selectedDate: selectedDate,
                    reportType: reportType
                )

                // タグ×感情分布
                TagEmotionAnalysisView(
                    reportType: reportType,
                    selectedDate: selectedDate,
                    items: items,
                    emotionDict: emotionDict,
                    onDotTap: { tag, emotion in
                        selectedTagEmotion = TagEmotionSelection(tag: tag, emotion: emotion)
                    }
                )
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background.ignoresSafeArea())
        .sheet(item: $selectedTagEmotion) { selection in
            TagEmotionDetailSheet(selection: selection, items: items)
        }
    }

    // MARK: - 補助プロパティ
    private var monthlyRatings: [Int] {
        let calendar = Calendar.current
        guard let selectedDate = selectedDate,
              let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth)
        else { return [] }
        return range.compactMap { day in
            guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
            return ratingsForDates[calendar.startOfDay(for: date)] ?? 0
        }
    }

    private var yearlyRatings: [Int] {
        let calendar = Calendar.current
        guard let selectedDate = selectedDate else { return [] }
        let year = calendar.component(.year, from: selectedDate)
        return (1...12).map { month in
            let components = DateComponents(year: year, month: month)
            guard let startOfMonth = calendar.date(from: components) else { return 0 }
            let daysInMonth = calendar.range(of: .day, in: .month, for: startOfMonth)!
            let ratings = daysInMonth.compactMap { day -> Int? in
                guard let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) else { return nil }
                return ratingsForDates[calendar.startOfDay(for: date)]
            }
            guard !ratings.isEmpty else { return 0 }
            return ratings.reduce(0, +) / ratings.count
        }
    }
}

// MARK: - タグ×感情の詳細シート
private struct TagEmotionDetailSheet: View {
    let selection: TagEmotionSelection
    let items: [Item]

    private var filtered: [Item] {
        items.filter { $0.emotionTags[selection.emotion]?.contains(selection.tag) ?? false }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if filtered.isEmpty {
                        Text(L10n.current == .ja ? "該当するメモはありません" : "No matching notes")
                            .foregroundColor(AppColors.textSecondary)
                            .padding()
                    } else {
                        ForEach(filtered, id: \.id) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                if let note = item.emotionNotes[selection.emotion], !note.isEmpty {
                                    Text(note)
                                        .font(.body)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Text(item.timestamp, style: .date)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .card()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("\(selection.tag) × \(selection.emotion)")
            .navigationBarTitleDisplayMode(.inline)
            .screenBackground()
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - タグごとの感情分析
struct TagEmotionAnalysisView: View {
    var reportType: ReportView.ReportType
    var selectedDate: Date?
    var items: [Item]
    var emotionDict: [String: Emotion]
    var onDotTap: (String, String) -> Void

    var body: some View {
        let tagMap = tagEmotionMap()
        if !tagMap.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                Text(L10n.tagEmotionDistribution)
                    .font(.subheadline).bold()
                    .foregroundColor(AppColors.textSecondary)
                ForEach(tagMap.keys.sorted(), id: \.self) { tag in
                    HStack(spacing: 6) {
                        Text(tag)
                            .font(.caption).bold()
                            .foregroundColor(AppColors.textPrimary)
                            .frame(width: 70, alignment: .leading)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 4) {
                                ForEach(tagMap[tag] ?? [], id: \.id) { item in
                                    ForEach(item.emotions, id: \.self) { emotionName in
                                        if item.emotionTags[emotionName]?.contains(tag) == true {
                                            Circle()
                                                .fill(emotionDict[emotionName]?.color ?? .gray)
                                                .frame(width: 14, height: 14)
                                                .onTapGesture { onDotTap(tag, emotionName) }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .card()
        }
    }

    private func tagEmotionMap() -> [String: [Item]] {
        let filtered: [Item]
        let calendar = Calendar.current
        if reportType == .monthly, let selectedDate = selectedDate {
            let comps = calendar.dateComponents([.year, .month], from: selectedDate)
            filtered = items.filter {
                let c = calendar.dateComponents([.year, .month], from: $0.timestamp)
                return c.year == comps.year && c.month == comps.month
            }
        } else if reportType == .yearly, let selectedDate = selectedDate {
            let year = calendar.component(.year, from: selectedDate)
            filtered = items.filter { calendar.component(.year, from: $0.timestamp) == year }
        } else {
            filtered = []
        }
        var map: [String: [Item]] = [:]
        for item in filtered {
            for (_, tags) in item.emotionTags {
                for tag in tags { map[tag, default: []].append(item) }
            }
        }
        for key in map.keys { map[key] = Array(Set(map[key]!)) }
        return map
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
