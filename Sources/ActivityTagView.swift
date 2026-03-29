import SwiftUI

// 時間帯ボタン（アイコンのみ、コンパクト）
struct TimeSlotTagView: View {
    @Binding var noteText: String

    private let slots: [(icon: String, tagEn: String, tagJa: String, label: String)] = [
        ("🌅", "#morning", "#朝", "morning"),
        ("☀️", "#afternoon", "#昼", "afternoon"),
        ("🌙", "#evening", "#夜", "evening"),
    ]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(slots, id: \.tagEn) { slot in
                let tag = L10n.current == .ja ? slot.tagJa : slot.tagEn
                let isActive = noteText.contains(tag)
                Button {
                    toggleTag(tag)
                } label: {
                    HStack(spacing: 2) {
                        Text(slot.icon).font(.system(size: 11))
                        Text(L10n.current == .ja ? slot.tagJa : slot.label).font(.system(size: 9))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(isActive ? AppColors.accent.opacity(0.3) : AppColors.cardBackgroundElevated))
                    .foregroundColor(isActive ? AppColors.accent : AppColors.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggleTag(_ tag: String) {
        if noteText.contains(tag) {
            noteText = noteText.replacingOccurrences(of: " \(tag)", with: "")
            noteText = noteText.replacingOccurrences(of: tag, with: "")
            noteText = noteText.trimmingCharacters(in: .whitespaces)
        } else {
            noteText += noteText.isEmpty ? tag : " \(tag)"
        }
    }
}

// 活動タグ（プリセット + 過去のカスタムタグ、頻度順）
struct ActivityTagView: View {
    @Binding var noteText: String

    private let defaultPresets: [(icon: String, tagEn: String, tagJa: String)] = [
        ("💼", "#work", "#仕事"), ("👨‍👩‍👧", "#family", "#家族"), ("🏃", "#exercise", "#運動"),
        ("😴", "#sleep", "#睡眠"), ("🎮", "#hobby", "#趣味"), ("👫", "#friends", "#友人"),
        ("📚", "#study", "#勉強"), ("🍽️", "#food", "#食事"), ("🧘", "#relax", "#リラックス"),
    ]

    private var allTags: [(icon: String, tag: String)] {
        let freq = UserDefaults.standard.dictionary(forKey: "tagFrequency") as? [String: Int] ?? [:]

        // プリセットタグ
        let presets = defaultPresets.map {
            (icon: $0.icon, tag: L10n.current == .ja ? $0.tagJa : $0.tagEn)
        }
        let presetTagNames = Set(presets.map(\.tag))

        // カスタムタグ（プリセットにないもの）
        let customTags = freq.keys
            .filter { !presetTagNames.contains($0) }
            .filter { !isTimeTag($0) }
            .map { (icon: "🏷️", tag: $0) }

        // 全部まとめて頻度順
        return (presets + customTags).sorted { (freq[$0.tag] ?? 0) > (freq[$1.tag] ?? 0) }
    }

    private func isTimeTag(_ tag: String) -> Bool {
        ["#morning", "#afternoon", "#evening", "#朝", "#昼", "#夜"].contains(tag)
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(allTags, id: \.tag) { item in
                    let isActive = noteText.contains(item.tag)
                    Button {
                        toggleTag(item.tag)
                    } label: {
                        HStack(spacing: 2) {
                            Text(item.icon).font(.system(size: 11))
                            Text(item.tag).font(.system(size: 9))
                        }
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(isActive ? AppColors.accent.opacity(0.3) : AppColors.cardBackgroundElevated))
                        .foregroundColor(isActive ? AppColors.accent : AppColors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func toggleTag(_ tag: String) {
        if noteText.contains(tag) {
            noteText = noteText.replacingOccurrences(of: " \(tag)", with: "")
            noteText = noteText.replacingOccurrences(of: tag, with: "")
            noteText = noteText.trimmingCharacters(in: .whitespaces)
        } else {
            noteText += noteText.isEmpty ? tag : " \(tag)"
            // 頻度記録
            var freq = UserDefaults.standard.dictionary(forKey: "tagFrequency") as? [String: Int] ?? [:]
            freq[tag, default: 0] += 1
            UserDefaults.standard.set(freq, forKey: "tagFrequency")
        }
    }
}
