import SwiftUI

struct InsightView: View {
    var items: [Item]
    var selectedDate: Date?
    var reportType: ReportView.ReportType

    private let calendar = Calendar.current

    private var currentItems: [Item] {
        guard let selectedDate = selectedDate else { return [] }
        if reportType == .monthly {
            let comps = calendar.dateComponents([.year, .month], from: selectedDate)
            return items.filter {
                let c = calendar.dateComponents([.year, .month], from: $0.timestamp)
                return c.year == comps.year && c.month == comps.month
            }
        } else {
            let year = calendar.component(.year, from: selectedDate)
            return items.filter { calendar.component(.year, from: $0.timestamp) == year }
        }
    }

    private var previousItems: [Item] {
        guard let selectedDate = selectedDate else { return [] }
        let offset: Calendar.Component = reportType == .monthly ? .month : .year
        guard let prevDate = calendar.date(byAdding: offset, value: -1, to: selectedDate) else { return [] }
        if reportType == .monthly {
            let comps = calendar.dateComponents([.year, .month], from: prevDate)
            return items.filter {
                let c = calendar.dateComponents([.year, .month], from: $0.timestamp)
                return c.year == comps.year && c.month == comps.month
            }
        } else {
            let year = calendar.component(.year, from: prevDate)
            return items.filter { calendar.component(.year, from: $0.timestamp) == year }
        }
    }

    private var insights: [Insight] {
        var result: [Insight] = []

        guard !currentItems.isEmpty else {
            return [Insight(icon: "📝", text: L10n.noDataYet)]
        }

        // 1. 平均気分の変化
        let currentAvg = Double(currentItems.map(\.rating).reduce(0, +)) / Double(currentItems.count)
        if !previousItems.isEmpty {
            let prevAvg = Double(previousItems.map(\.rating).reduce(0, +)) / Double(previousItems.count)
            let diff = currentAvg - prevAvg
            if abs(diff) >= 0.3 {
                let arrow = diff > 0 ? "📈" : "📉"
                let direction = diff > 0 ? (L10n.current == .ja ? "上昇" : "increased") : (L10n.current == .ja ? "低下" : "decreased")
                result.append(Insight(
                    icon: arrow,
                    text: String(format: L10n.current == .ja ? "平均気分が %.1f → %.1f に%@しています" : "Average mood %@ from %.1f to %.1f", prevAvg, currentAvg, direction)
                ))
            }
        }

        // 2. 4象限の分布
        let allEmotions = currentItems.flatMap(\.emotions)
        var zoneCounts = [0, 0, 0, 0] // calm, active, down, upset
        for name in allEmotions {
            for (i, group) in emotionGroups.enumerated() {
                if group.emotions.contains(where: { $0.name == name }) {
                    zoneCounts[i] += 1
                    break
                }
            }
        }
        let total = zoneCounts.reduce(0, +)
        if total > 0 {
            let zoneNames = ["calm", "active", "down", "upset"]
            let zoneIcons = ["🟢", "🟡", "🔵", "🔴"]
            // 最も多いゾーン
            if let maxIdx = zoneCounts.enumerated().max(by: { $0.element < $1.element })?.offset {
                let pct = Int(Double(zoneCounts[maxIdx]) / Double(total) * 100)
                let zoneName = L10n.groupName(zoneNames[maxIdx])
                result.append(Insight(
                    icon: zoneIcons[maxIdx],
                    text: L10n.current == .ja
                        ? "「\(zoneName)」が\(pct)%（\(zoneCounts[maxIdx])回）で最多"
                        : "\"\(zoneName)\" was dominant at \(pct)% (\(zoneCounts[maxIdx]) times)"
                ))
            }
            // ポジティブ vs ネガティブ比率
            let positive = zoneCounts[0] + zoneCounts[1]
            let negative = zoneCounts[2] + zoneCounts[3]
            if positive > negative {
                let ratio = Int(Double(positive) / Double(total) * 100)
                result.append(Insight(
                    icon: "✨",
                    text: L10n.current == .ja
                        ? "ポジティブな感情が\(ratio)%。いい月ですね！"
                        : "Positive emotions at \(ratio)%. Great month!"
                ))
            } else if negative > positive {
                let ratio = Int(Double(negative) / Double(total) * 100)
                result.append(Insight(
                    icon: "💙",
                    text: L10n.current == .ja
                        ? "ネガティブな感情が\(ratio)%。自分を労ってあげてください"
                        : "Negative emotions at \(ratio)%. Be kind to yourself"
                ))
            }
        }

        // 3. 最も多い個別感情
        let emotionCounts = allEmotions
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
        if let top = emotionCounts.max(by: { $0.value < $1.value }) {
            result.append(Insight(
                icon: "🎭",
                text: L10n.topEmotion(top.key, count: top.value),
                emotionName: top.key
            ))
        }

        // 3. 感情の増減（前期比）
        if !previousItems.isEmpty {
            let prevCounts = previousItems.flatMap(\.emotions)
                .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
            for (emotion, count) in emotionCounts {
                let prev = prevCounts[emotion] ?? 0
                guard prev > 0 else { continue }
                let change = Double(count - prev) / Double(prev) * 100
                if change >= 40 {
                    let isNegative = emotionGroups[2...3].flatMap(\.emotions).contains { $0.name == emotion }
                    if isNegative {
                        result.append(Insight(
                            icon: "⚠️",
                            text: L10n.emotionIncrease(emotion, pct: Int(change)),
                            emotionName: emotion
                        ))
                    }
                }
            }
        }

        // 4. タグ別の平均気分
        var tagRatings: [String: [Int]] = [:]
        for item in currentItems {
            let allTags = Set(item.emotionTags.values.flatMap { $0 })
            for tag in allTags {
                tagRatings[tag, default: []].append(item.rating)
            }
        }
        // 最もポジティブなタグ
        let tagAvgs = tagRatings.mapValues { Double($0.reduce(0, +)) / Double($0.count) }
        if let best = tagAvgs.max(by: { $0.value < $1.value }), best.value >= 3.5 {
            result.append(Insight(
                icon: "✨",
                text: L10n.bestTag(best.key, avg: best.value)
            ))
        }
        // 最もネガティブなタグ
        if let worst = tagAvgs.min(by: { $0.value < $1.value }), worst.value <= 2.5, tagAvgs.count >= 2 {
            result.append(Insight(
                icon: "💡",
                text: L10n.worstTag(worst.key, avg: worst.value)
            ))
        }

        // 5. タグ×感情の前期比（ネガティブ増加警告）
        if !previousItems.isEmpty {
            var prevTagEmotions: [String: [String]] = [:]
            for item in previousItems {
                for (emotion, tags) in item.emotionTags {
                    for tag in tags { prevTagEmotions[tag, default: []].append(emotion) }
                }
            }
            var curTagEmotions: [String: [String]] = [:]
            for item in currentItems {
                for (emotion, tags) in item.emotionTags {
                    for tag in tags { curTagEmotions[tag, default: []].append(emotion) }
                }
            }
            let negativeEmotions = Set(emotionGroups[2...3].flatMap { $0.emotions.map(\.name) })
            for (tag, emotions) in curTagEmotions {
                let curNeg = emotions.filter { negativeEmotions.contains($0) }.count
                let prevNeg = (prevTagEmotions[tag] ?? []).filter { negativeEmotions.contains($0) }.count
                if curNeg >= 3 && curNeg > prevNeg * 2 && prevNeg > 0 {
                    result.append(Insight(
                        icon: "🔔",
                        text: L10n.negativeTagIncrease(tag)
                    ))
                }
            }
        }

        // 5. 時間帯別の感情傾向
        let timeTagsJa = ["#朝", "#昼", "#夜"]
        let timeTagsEn = ["#morning", "#afternoon", "#evening"]
        let timeIcons = ["🌅", "☀️", "🌙"]
        let timeTags = L10n.current == .ja ? timeTagsJa : timeTagsEn
        let negativeEmotionNames = Set(emotionGroups[2...3].flatMap { $0.emotions.map(\.name) })
        let positiveEmotionNames = Set(emotionGroups[0...1].flatMap { $0.emotions.map(\.name) })

        var timeNeg: [Int] = [0, 0, 0]
        var timePos: [Int] = [0, 0, 0]
        var timeTotal: [Int] = [0, 0, 0]
        for item in currentItems {
            for record in item.emotionRecords {
                let note = record.note
                for (i, tag) in timeTags.enumerated() {
                    if note.contains(tag) {
                        timeTotal[i] += 1
                        if negativeEmotionNames.contains(record.emotionName) { timeNeg[i] += 1 }
                        if positiveEmotionNames.contains(record.emotionName) { timePos[i] += 1 }
                    }
                }
            }
        }
        // 最もネガティブな時間帯
        if let worstIdx = timeNeg.enumerated().filter({ $0.element >= 2 }).max(by: { $0.element < $1.element })?.offset {
            let timeLabel = L10n.current == .ja
                ? ["朝", "昼", "夜"][worstIdx]
                : ["morning", "afternoon", "evening"][worstIdx]
            result.append(Insight(
                icon: timeIcons[worstIdx],
                text: L10n.current == .ja
                    ? "\(timeLabel)にネガティブな感情が集中しています（\(timeNeg[worstIdx])回）"
                    : "Negative emotions concentrate in the \(timeLabel) (\(timeNeg[worstIdx]) times)"
            ))
        }
        // 最もポジティブな時間帯
        if let bestIdx = timePos.enumerated().filter({ $0.element >= 2 }).max(by: { $0.element < $1.element })?.offset {
            let timeLabel = L10n.current == .ja
                ? ["朝", "昼", "夜"][bestIdx]
                : ["morning", "afternoon", "evening"][bestIdx]
            result.append(Insight(
                icon: timeIcons[bestIdx],
                text: L10n.current == .ja
                    ? "\(timeLabel)はポジティブな時間帯です（\(timePos[bestIdx])回）"
                    : "Your \(timeLabel) tends to be positive (\(timePos[bestIdx]) times)"
            ))
        }

        return result.isEmpty
            ? [Insight(icon: "👍", text: L10n.allGood(currentAvg))]
            : result
    }

    var body: some View {
        let top3 = Array(insights.prefix(6))
        if !top3.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.insights)
                    .font(.subheadline).bold()
                    .foregroundColor(AppColors.textSecondary)
                ForEach(top3) { insight in
                    HStack(alignment: .top, spacing: 8) {
                        Text(insight.icon)
                        if let emotionName = insight.emotionName,
                           let color = emotionDict[emotionName]?.color {
                            (Text(L10n.emotionName(emotionName)).foregroundColor(color).bold() + Text(" " + insight.text).foregroundColor(AppColors.textPrimary))
                                .font(.subheadline)
                        } else {
                            Text(insight.text)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }
            .card()
        }
    }
}

private struct Insight: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    let emotionName: String?

    init(icon: String, text: String, emotionName: String? = nil) {
        self.icon = icon
        self.text = text
        self.emotionName = emotionName
    }
}
