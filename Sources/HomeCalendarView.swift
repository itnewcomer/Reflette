import SwiftUI
import SwiftData

struct HomeCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    var appState: AppState
    var ratingsForDates: [Date: Int]
    var items: [Item]

    @State private var showEditor = false
    @State private var showDeleteAlert = false
    @State private var selectedEmotion: String? = nil
    @State private var deleteError: String? = nil

    // 月初10日以内で目標未設定ならリマインド
    private var shouldShowGoalReminder: Bool {
        let calendar = Calendar.current
        let today = Date()
        let day = calendar.component(.day, from: today)
        let goalDay = DayRule.load(key: "goalDayRule", defaultDay: 1).dayOfMonth(in: today) ?? 1
        guard day >= goalDay && day <= goalDay + 7 else { return false }
        let data = UserDefaults.standard.data(forKey: "monthlyGoals") ?? Data()
        guard let goals = try? JSONDecoder().decode([MonthlyGoal].self, from: data) else { return true }
        let comps = calendar.dateComponents([.year, .month], from: today)
        return !goals.contains { $0.year == comps.year && $0.month == comps.month }
    }

    private var shouldShowReflectReminder: Bool {
        let calendar = Calendar.current
        let today = Date()
        let day = calendar.component(.day, from: today)
        let reflectDay = DayRule.load(key: "reflectDayRule", defaultDay: 25).dayOfMonth(in: today) ?? 25
        guard day >= reflectDay else { return false }
        let data = UserDefaults.standard.data(forKey: "monthlyGoals") ?? Data()
        guard let goals = try? JSONDecoder().decode([MonthlyGoal].self, from: data) else { return false }
        let comps = calendar.dateComponents([.year, .month], from: today)
        guard let goal = goals.first(where: { $0.year == comps.year && $0.month == comps.month }) else { return false }
        return goal.letterToSelf.isEmpty
    }

    private var selectedItem: Item? {
        guard let selectedDate = appState.selectedDate else { return nil }
        return items.first { Calendar.current.isDate($0.timestamp, inSameDayAs: selectedDate) }
    }

    private func emotionColor(for name: String) -> Color {
        for group in emotionGroups {
            if let emotion = group.emotions.first(where: { $0.name == name }) {
                return emotion.color
            }
        }
        return .gray
    }

    private func ratingEmoji(for rating: Int) -> String {
        switch rating {
        case 1: return "😞"
        case 2: return "😕"
        case 3: return "😑"
        case 4: return "😊"
        case 5: return "😆"
        default: return "？"
        }
    }

    private var groupMatrix: [[EmotionGroup]] {
        [
            [emotionGroups[0], emotionGroups[1]],
            [emotionGroups[2], emotionGroups[3]]
        ]
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RatingScaleView()
                    .padding(.top, 2)                // カレンダー表示
                RefletteCalendarView(
                    selectedDate: Binding(
                        get: { appState.selectedDate },
                        set: { appState.selectedDate = $0 }
                    ),
                    displayedMonth: Binding(
                        get: { appState.initialMonth },
                        set: { appState.initialMonth = $0 }
                    ),
                    ratingsForDates: ratingsForDates,
                    onDoubleTap: { showEditor = true }
                )

                // セルフコンパッション
                SelfCompassionView(items: items, selectedDate: appState.selectedDate)

                // 月初リマインド: 目標未設定
                if shouldShowGoalReminder {
                    Button {
                        appState.selectedTab = 2
                    } label: {
                        HStack(spacing: 8) {
                            Text("🎯")
                            Text(L10n.current == .ja ? "今月の目標を設定しましょう" : "Set this month's goals")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .card()
                }

                // 月末リマインド: 振り返り
                if shouldShowReflectReminder {
                    Button {
                        appState.selectedTab = 2
                    } label: {
                        HStack(spacing: 8) {
                            Text("💛")
                            Text(L10n.current == .ja ? "今月を振り返って、自分に手紙を書きませんか？" : "Reflect on this month and write yourself a letter")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .card()
                }

                // 日付タップで記録ボタン or 詳細表示
                if let item = selectedItem {
                    CalendarDetailView(
                        item: item,
                        selectedEmotion: $selectedEmotion,
                        groupMatrix: groupMatrix,
                        emotionColor: emotionColor,
                        ratingEmoji: ratingEmoji,
                        showEditor: $showEditor,
                        showDeleteAlert: $showDeleteAlert
                    )
                    .card()
                } else if appState.selectedDate != nil {
                    VStack(spacing: 8) {
                        Text(L10n.current == .ja ? "この日の記録はまだありません" : "No record for this day")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                        Button {
                            showEditor = true
                        } label: {
                            Label(
                                L10n.current == .ja ? "記録する" : "Record",
                                systemImage: "plus.circle.fill"
                            )
                            .font(.subheadline)
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.accent)
                    }
                    .card()
                }
            }
            .padding(.horizontal)
            .macContentFrame()
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background(AppColors.background.ignoresSafeArea())
        .ignoresSafeArea(.keyboard, edges: .bottom)
        // 編集シート
        .sheet(isPresented: $showEditor) {
            NavigationStack {
                RecordEditorView(
                    selectedDate: Binding(
                        get: { appState.selectedDate },
                        set: { appState.selectedDate = $0 }
                    ),
                    items: items,
                    onComplete: { showEditor = false }
                )
                .environment(\.modelContext, modelContext)
            }
        }
        // 削除アラート
        .alert(L10n.deleteConfirmTitle, isPresented: $showDeleteAlert) {
            Button(L10n.delete, role: .destructive) {
                if let item = selectedItem {
                    modelContext.delete(item)
                    do {
                        try modelContext.save()
                    } catch {
                        deleteError = "\(L10n.current == .ja ? "削除に失敗" : "Delete failed"): \(error.localizedDescription)"
                    }
                }
            }
            Button(L10n.cancel, role: .cancel) {}
        } message: {
            Text(L10n.deleteConfirmMessage)
        }
        .errorAlert($deleteError)
    }
}

// MARK: - データあり用サブView

struct CalendarDetailView: View {
    let item: Item
    @Binding var selectedEmotion: String?
    let groupMatrix: [[EmotionGroup]]
    let emotionColor: (String) -> Color
    let ratingEmoji: (Int) -> String
    @Binding var showEditor: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(ratingEmoji(item.rating))
                    .font(.system(size: 36))
                    .frame(width: 60)
                Spacer()
                HStack(spacing: 20) {
                    Button(action: { showEditor = true }) {
                        Image(systemName: "pencil").font(.title2)
                    }
                    Button(action: { showDeleteAlert = true }) {
                        Image(systemName: "trash")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                }
            }
            VStack(spacing: 6) {
                ForEach(0..<groupMatrix.count, id: \.self) { row in
                    HStack(spacing: 12) {
                        ForEach(0..<groupMatrix[row].count, id: \.self) { col in
                            let group = groupMatrix[row][col]
                            EmotionGridView(
                                group: group,
                                item: item,
                                selectedEmotion: $selectedEmotion
                            )
                        }
                    }
                }
                .padding(.top, 4)
            }
            if let emotion = selectedEmotion,
               let note = item.emotionNotes[emotion],
               !note.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(emotionColor(emotion))
                            .frame(width: 20, height: 20)
                        Text(L10n.emotionName(emotion))
                            .font(.headline)
                            .foregroundColor(emotionColor(emotion))
                    }
                    Text(note)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding(.top, 2)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(AppColors.cardBackgroundElevated))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

private var monthYearFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateFormat = L10n.current == .ja ? "yyyy年 M月" : "MMMM yyyy"
    return formatter
}
