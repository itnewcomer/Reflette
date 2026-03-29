import SwiftUI

// --- モデル定義 ---

struct MonthlyGoal: Identifiable, Codable, Equatable {
    let id: UUID
    let year: Int
    let month: Int
    var excitedGoals: [GoalTask]
    var stretchGoals: [GoalTask]
    var tasks: [GoalTask]
    var letterToSelf: String
}

struct GoalTask: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
}

// --- GoalMonthSelector (Date?対応) ---

struct GoalMonthSelector: View {
    @Binding var selectedDate: Date?

    private let calendar = Calendar.current
    private let years: [Int]
    private let months: [Int] = Array(1...12)

    init(selectedDate: Binding<Date?>) {
        self._selectedDate = selectedDate
        let currentYear = calendar.component(.year, from: Date())
        self.years = Array((currentYear-5)...(currentYear+2))
    }

    var body: some View {
        HStack {
            Picker(L10n.year, selection: yearBinding) {
                ForEach(years, id: \.self) { year in
                    Text(L10n.yearLabel(year)).tag(year)
                }
            }
            .pickerStyle(.menu)

            Picker(L10n.month, selection: monthBinding) {
                ForEach(months, id: \.self) { month in
                    Text(L10n.monthLabel(month)).tag(month)
                }
            }
            .pickerStyle(.menu)
        }
    }

    private var yearBinding: Binding<Int> {
        Binding<Int>(
            get: {
                if let selectedDate = selectedDate {
                    return calendar.component(.year, from: selectedDate)
                } else {
                    return calendar.component(.year, from: Date())
                }
            },
            set: { newYear in
                let month = selectedDate.flatMap { calendar.component(.month, from: $0) } ?? 1
                if let newDate = calendar.date(from: DateComponents(year: newYear, month: month, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
    private var monthBinding: Binding<Int> {
        Binding<Int>(
            get: {
                if let selectedDate = selectedDate {
                    return calendar.component(.month, from: selectedDate)
                } else {
                    return 1
                }
            },
            set: { newMonth in
                let year = selectedDate.flatMap { calendar.component(.year, from: $0) } ?? calendar.component(.year, from: Date())
                if let newDate = calendar.date(from: DateComponents(year: year, month: newMonth, day: 1)) {
                    selectedDate = newDate
                }
            }
        )
    }
}

// --- 目標編集サブビュー ---

struct GoalEditor: View {
    @Binding var goal: MonthlyGoal
    @Binding var showLetterSheet: Bool

    var ratingsForDates: [Date: Int]
    var items: [Item]
    var emotionDict: [String: Emotion]

    @State private var newExcitedGoal = ""
    @State private var newStretchGoal = ""
    @State private var newTaskTitle = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Excited Goals
            Text(L10n.excitedGoals).font(.headline)
            ForEach($goal.excitedGoals) { $goalTask in
                HStack {
                    Button(action: { goalTask.isCompleted.toggle() }) {
                        Image(systemName: goalTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goalTask.isCompleted ? .green : .gray)
                    }
                    Text(goalTask.title)
                        .strikethrough(goalTask.isCompleted)
                        .foregroundColor(goalTask.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.excitedGoals.removeAll { $0.id == goalTask.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.excitedGoals.count < 5 {
                HStack {
                    TextField(L10n.newExcitedGoal, text: $newExcitedGoal)
                        .textFieldStyle(.roundedBorder)
                    Button(L10n.add) {
                        let trimmed = newExcitedGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.excitedGoals.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newExcitedGoal = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            // Stretch Goals
            Text(L10n.stretchGoals).font(.headline)
            ForEach($goal.stretchGoals) { $goalTask in
                HStack {
                    Button(action: { goalTask.isCompleted.toggle() }) {
                        Image(systemName: goalTask.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(goalTask.isCompleted ? .green : .gray)
                    }
                    Text(goalTask.title)
                        .strikethrough(goalTask.isCompleted)
                        .foregroundColor(goalTask.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.stretchGoals.removeAll { $0.id == goalTask.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.stretchGoals.count < 5 {
                HStack {
                    TextField(L10n.newStretchGoal, text: $newStretchGoal)
                        .textFieldStyle(.roundedBorder)
                    Button(L10n.add) {
                        let trimmed = newStretchGoal.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.stretchGoals.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newStretchGoal = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()

            // Tasks (ToDo)
            Text(L10n.tasks).font(.headline)
            ForEach($goal.tasks) { $task in
                HStack {
                    Button(action: { task.isCompleted.toggle() }) {
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                    Text(task.title)
                        .strikethrough(task.isCompleted)
                        .foregroundColor(task.isCompleted ? .gray : .primary)
                    Spacer()
                    Button(action: {
                        goal.tasks.removeAll { $0.id == task.id }
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            if goal.tasks.count < 20 {
                HStack {
                    TextField(L10n.newTask, text: $newTaskTitle)
                        .textFieldStyle(.roundedBorder)
                    Button(L10n.add) {
                        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        goal.tasks.append(GoalTask(id: UUID(), title: trimmed, isCompleted: false))
                        newTaskTitle = ""
                    }
                    .buttonStyle(.bordered)
                }
            }

            Divider()


        }
        .padding()
    }
}

// --- GoalView本体 ---

struct GoalView: View {
    @Binding var selectedDate: Date?
    @State private var monthlyGoalsData: Data = UserDefaults.standard.data(forKey: "monthlyGoals") ?? Data()
    @State private var monthlyGoals: [MonthlyGoal] = []
    @State private var showLetterSheet = false
    @State private var expandedSection: ExpandedSection? = .goals

    enum ExpandedSection { case goals, letter }

    var ratingsForDates: [Date: Int]
    var items: [Item]
    var emotionDict: [String: Emotion]

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                GoalMonthSelector(selectedDate: $selectedDate)

                if let goal = goalForMonth {
                    // プログレスリング（常に表示）
                    GoalProgressView(goal: goal)

                    // 📋 目標一覧（折りたたみ）
                    CollapsibleSection(
                        title: L10n.current == .ja ? "📋 目標" : "📋 Goals",
                        isExpanded: expandedSection == .goals,
                        onTap: { expandedSection = expandedSection == .goals ? nil : .goals }
                    ) {
                        GoalEditor(
                            goal: binding(for: goal),
                            showLetterSheet: .constant(false),
                            ratingsForDates: ratingsForDates,
                            items: items,
                            emotionDict: emotionDict
                        )
                    }

                    // 💛 自分への手紙（折りたたみ）
                    CollapsibleSection(
                        title: L10n.current == .ja ? "💛 自分への手紙" : "💛 Letter to Yourself",
                        isExpanded: expandedSection == .letter,
                        onTap: { expandedSection = expandedSection == .letter ? nil : .letter }
                    ) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(L10n.letterToSelf)
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            if goal.letterToSelf.isEmpty {
                                Button {
                                    showLetterSheet = true
                                } label: {
                                    Label(L10n.current == .ja ? "手紙を書く" : "Write a letter",
                                          systemImage: "pencil.line")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(AppColors.accent)
                            } else {
                                Text(goal.letterToSelf)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                HStack {
                                    Spacer()
                                    Button {
                                        showLetterSheet = true
                                    } label: {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Button(L10n.createGoal) {
                        createGoalForMonth()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(AppColors.accent)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .padding()
        }
        .navigationTitle(L10n.tabGoal)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear(perform: loadGoals)
        .onChange(of: monthlyGoals) { _, _ in
            saveGoals()
        }
        .sheet(isPresented: $showLetterSheet) {
            if let idx = monthlyGoals.firstIndex(where: { $0.year == selectedYear && $0.month == selectedMonth }) {
                LetterComposeView(
                    selectedDate: selectedDate,
                    ratingsForDates: ratingsForDates,
                    items: items,
                    emotionDict: emotionDict,
                    goal: $monthlyGoals[idx],
                    onSave: { showLetterSheet = false }
                )
            }
        }
    }

    // 今月の目標を取得
    private var goalForMonth: MonthlyGoal? {
        guard let selectedDate = selectedDate else { return nil }
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        return monthlyGoals.first { $0.year == comps.year && $0.month == comps.month }
    }

    // Binding取得
    private func binding(for goal: MonthlyGoal) -> Binding<MonthlyGoal> {
        guard let idx = monthlyGoals.firstIndex(where: { $0.id == goal.id }) else {
            // フォールバック: 最初の目標を返す
            return $monthlyGoals[0]
        }
        return $monthlyGoals[idx]
    }

    // 目標新規作成
    private func createGoalForMonth() {
        guard let selectedDate = selectedDate else { return }
        let comps = Calendar.current.dateComponents([.year, .month], from: selectedDate)
        let newGoal = MonthlyGoal(
            id: UUID(),
            year: comps.year ?? 2024,
            month: comps.month ?? 1,
            excitedGoals: [],
            stretchGoals: [],
            tasks: [],
            letterToSelf: ""
        )
        monthlyGoals.append(newGoal)
    }

    // --- 保存・読み込み ---
    private func loadGoals() {
        guard !monthlyGoalsData.isEmpty,
              let decoded = try? JSONDecoder().decode([MonthlyGoal].self, from: monthlyGoalsData)
        else { return }
        monthlyGoals = decoded
    }

    private func saveGoals() {
        if let data = try? JSONEncoder().encode(monthlyGoals) {
            monthlyGoalsData = data
            UserDefaults.standard.set(data, forKey: "monthlyGoals")
        }
    }

    private var selectedYear: Int {
        guard let selectedDate = selectedDate else { return 2024 }
        return Calendar.current.component(.year, from: selectedDate)
    }
    private var selectedMonth: Int {
        guard let selectedDate = selectedDate else { return 1 }
        return Calendar.current.component(.month, from: selectedDate)
    }
}
