import SwiftUI

struct EmotionBubble: Identifiable {
    let name: String
    let count: Int
    let color: Color
    let zone: Int
    let scale: CGFloat
    var id: String { name }
}

struct EmotionSummaryView: View {
    var items: [Item]
    var selectedDate: Date?
    var reportType: ReportView.ReportType
    @State private var selectedEmotion: EmotionBubble? = nil

    private var filteredItems: [Item] {
        let calendar = Calendar.current
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

    private var bubbles: [EmotionBubble] {
        let counts = filteredItems.flatMap(\.emotions)
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
        guard let maxCount = counts.values.max(), maxCount > 0 else { return [] }
        return counts
            .sorted { $0.value > $1.value }
            .map { (name, count) -> EmotionBubble in
                let color = emotionDict[name]?.color ?? .gray
                let zone = zoneIndex(for: name)
                return EmotionBubble(name: name, count: count, color: color, zone: zone,
                                     scale: CGFloat(count) / CGFloat(maxCount))
            }
    }

    private func zoneIndex(for name: String) -> Int {
        for (i, group) in emotionGroups.enumerated() {
            if group.emotions.contains(where: { $0.name == name }) { return i }
        }
        return 0
    }

    var body: some View {
        if !bubbles.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(L10n.current == .ja ? "感情バブル" : "Emotion Bubbles")
                    .font(.subheadline).bold()
                    .foregroundColor(AppColors.textSecondary)

                GeometryReader { geo in
                    let w = geo.size.width
                    let h = geo.size.height
                    let zones = groupByZone()

                    ForEach(0..<4, id: \.self) { zone in
                        let originX = zone % 2 == 0 ? CGFloat(0) : w / 2
                        let originY = zone < 2 ? CGFloat(0) : h / 2
                        let zoneW = w / 2
                        let zoneH = h / 2

                        RoundedRectangle(cornerRadius: 6)
                            .stroke(AppColors.zoneColors[zone].opacity(0.2), lineWidth: 0.5)
                            .frame(width: zoneW - 2, height: zoneH - 2)
                            .position(x: originX + zoneW / 2, y: originY + zoneH / 2)

                        ForEach(Array(zones[zone].enumerated()), id: \.element.name) { idx, bubble in
                            let pos = bubblePosition(index: idx, total: zones[zone].count,
                                in: CGRect(x: originX + 8, y: originY + 8, width: zoneW - 16, height: zoneH - 16))
                            let size = max(18, 44 * bubble.scale)

                            VStack(spacing: 0) {
                                Circle()
                                    .fill(bubble.color.opacity(0.8))
                                    .frame(width: size, height: size)
                                    .overlay(
                                        Text("\(bubble.count)")
                                            .font(.system(size: max(8, size * 0.3), weight: .bold))
                                            .foregroundColor(.white)
                                    )
                                Text(L10n.emotionName(bubble.name))
                                    .font(.system(size: 7))
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(1)
                            }
                            .position(pos)
                            .onTapGesture { selectedEmotion = bubble }
                        }
                    }
                }
                .frame(height: 200)

                HStack {
                    Text(L10n.groupName("calm")).font(.system(size: 8)).foregroundColor(AppColors.zoneColors[0])
                    Spacer()
                    Text(L10n.groupName("active")).font(.system(size: 8)).foregroundColor(AppColors.zoneColors[1])
                }
                HStack {
                    Text(L10n.groupName("down")).font(.system(size: 8)).foregroundColor(AppColors.zoneColors[2])
                    Spacer()
                    Text(L10n.groupName("upset")).font(.system(size: 8)).foregroundColor(AppColors.zoneColors[3])
                }
            }
            .card()
            .sheet(item: $selectedEmotion) { bubble in
                EmotionNotesSheet(emotionName: bubble.name, color: bubble.color, items: filteredItems)
            }
        }
    }

    private func groupByZone() -> [[EmotionBubble]] {
        var zones: [[EmotionBubble]] = [[], [], [], []]
        for b in bubbles { zones[b.zone].append(b) }
        return zones
    }

    private func bubblePosition(index: Int, total: Int, in rect: CGRect) -> CGPoint {
        guard total > 0 else { return CGPoint(x: rect.midX, y: rect.midY) }
        if total == 1 { return CGPoint(x: rect.midX, y: rect.midY) }
        let cols = min(total, 3)
        let row = index / cols
        let col = index % cols
        let spacingX = rect.width / CGFloat(cols)
        let rows = (total + cols - 1) / cols
        let spacingY = rect.height / CGFloat(max(rows, 1))
        return CGPoint(
            x: rect.minX + spacingX * (CGFloat(col) + 0.5),
            y: rect.minY + spacingY * (CGFloat(row) + 0.5)
        )
    }
}

// MARK: - 感情メモ一覧シート
private struct EmotionNotesSheet: View {
    let emotionName: String
    let color: Color
    let items: [Item]

    private var matchingItems: [(date: Date, note: String)] {
        items.compactMap { item in
            guard item.emotions.contains(emotionName) else { return nil }
            let note = item.emotionNotes[emotionName] ?? ""
            return (date: item.timestamp, note: note)
        }
        .sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    if matchingItems.isEmpty {
                        Text(L10n.current == .ja ? "メモはありません" : "No notes")
                            .foregroundColor(AppColors.textSecondary)
                            .padding()
                    } else {
                        ForEach(matchingItems, id: \.date) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                if !item.note.isEmpty {
                                    Text(item.note)
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Text(item.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .card()
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(L10n.emotionName(emotionName))
            .navigationBarTitleDisplayMode(.inline)
            .screenBackground()
        }
        .presentationDetents([.medium, .large])
    }
}
