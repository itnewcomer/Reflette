import SwiftUI

struct RecordEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date?
    var items: [Item]
    var onComplete: () -> Void

    @State private var rating: Int = 3
    @State private var selectedEmotions: Set<String> = []
    @State private var emotionNotes: [String: String] = [:]
    @State private var saveError: String? = nil

    private var currentItem: Item? {
        guard let selectedDate = selectedDate else { return nil }
        return items.first { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    private func colorForEmotion(_ name: String) -> Color {
        for group in emotionGroups {
            if let emotion = group.emotions.first(where: { $0.name == name }) {
                return emotion.color
            }
        }
        return .gray
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // ヘッダー
                HStack {
                    if let selectedDate = selectedDate {
                        Text(selectedDate, style: .date).font(.headline)
                    } else {
                        Text(L10n.dateNotSelected).font(.headline)
                    }
                    Spacer()
                    Button(L10n.cancel) { dismiss() }
                }
                .padding(.horizontal)

                // 星評価
                VStack(spacing: 4) {
                    Text(L10n.current == .ja ? "今日はどんな日？" : "How was your day?")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    StarRatingView(rating: $rating)
                }
                .card()

                // 感情マトリクス
                EmotionMatrixView(
                    emotionRows: emotionRows,
                    emotionGroups: emotionGroups,
                    selectedEmotions: $selectedEmotions
                )

                // 選択された感情のメモ
                ForEach(Array(selectedEmotions.sorted()), id: \.self) { emotion in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Circle()
                                .fill(colorForEmotion(emotion))
                                .frame(width: 20, height: 20)
                            Text(L10n.emotionName(emotion))
                                .font(.subheadline).bold()
                        }

                        // 時間帯
                        TimeSlotTagView(noteText: Binding(
                            get: { emotionNotes[emotion] ?? "" },
                            set: { emotionNotes[emotion] = $0 }
                        ))

                        // 活動タグ
                        ActivityTagView(noteText: Binding(
                            get: { emotionNotes[emotion] ?? "" },
                            set: { emotionNotes[emotion] = $0 }
                        ))

                        TextEditor(text: Binding(
                            get: { emotionNotes[emotion] ?? "" },
                            set: { emotionNotes[emotion] = $0 }
                        ))
                        .frame(height: 60)
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(AppColors.cardBackground))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(colorForEmotion(emotion).opacity(0.5), lineWidth: 1)
                        )

                        let tags = tagsFromNote(emotionNotes[emotion] ?? "")
                        if !tags.isEmpty {
                            HStack {
                                ForEach(tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(colorForEmotion(emotion).opacity(0.2)))
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // 保存
                Button {
                    saveData()
                    if saveError == nil {
                        onComplete()
                        dismiss()
                    }
                } label: {
                    Text(currentItem != nil ? L10n.update : L10n.save)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .tint(AppColors.accent)
                .padding(.horizontal)
                .disabled(selectedDate == nil)

                Spacer(minLength: 20)
            }
            .padding(.top)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(AppColors.background.ignoresSafeArea())
        .errorAlert($saveError)
        .onAppear(perform: loadData)
        .onChange(of: selectedEmotions) { oldValue, newValue in
            for emotion in newValue.subtracting(oldValue) {
                emotionNotes[emotion] = currentItem?.emotionNotes[emotion] ?? ""
            }
            for emotion in oldValue.subtracting(newValue) {
                emotionNotes.removeValue(forKey: emotion)
            }
        }
    }

    private func loadData() {
        if let item = currentItem {
            rating = item.rating
            selectedEmotions = Set(item.emotions)
            emotionNotes = item.emotionNotes
        } else {
            rating = 3
            selectedEmotions = []
            emotionNotes = [:]
        }
    }

    private func tagsFromNote(_ text: String) -> [String] {
        let pattern = "#[\\p{L}0-9_]+"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        let nsrange = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: nsrange).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }

    private func saveData() {
        guard let selectedDate = selectedDate else { return }

        if let item = currentItem {
            item.rating = rating
            for record in item.emotionRecords {
                modelContext.delete(record)
            }
            item.emotionRecords = selectedEmotions.map { emotion in
                EmotionRecord(emotionName: emotion, note: emotionNotes[emotion] ?? "")
            }
        } else {
            let newItem = Item(
                timestamp: Calendar.current.startOfDay(for: selectedDate),
                rating: rating,
                timeSlot: TimeSlot.current.rawValue
            )
            newItem.emotionRecords = selectedEmotions.map { emotion in
                EmotionRecord(emotionName: emotion, note: emotionNotes[emotion] ?? "")
            }
            modelContext.insert(newItem)
        }

        do {
            try modelContext.save()
            // カスタムタグの頻度を記録
            registerCustomTags()
        } catch {
            saveError = "\(L10n.saveFailed): \(error.localizedDescription)"
        }
    }

    private func registerCustomTags() {
        var freq = UserDefaults.standard.dictionary(forKey: "tagFrequency") as? [String: Int] ?? [:]
        for (_, note) in emotionNotes {
            for tag in tagsFromNote(note) {
                if freq[tag] == nil {
                    freq[tag] = 1
                }
            }
        }
        UserDefaults.standard.set(freq, forKey: "tagFrequency")
    }
}
