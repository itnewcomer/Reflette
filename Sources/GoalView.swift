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
    var dueDate: Date?

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, dueDate: Date? = nil) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.dueDate = dueDate
    }
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

// --- 日付バッジ ---

struct GoalTaskDateBadge: View {
    let dueDate: Date?
    let onChange: (Date?) -> Void

    @State private var showPicker = false
    @State private var pickerDate = Date()

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = L10n.current == .ja ? "M/d" : "M/d"
        return f
    }()

    var body: some View {
        if let date = dueDate {
            HStack(spacing: 2) {
                Button {
                    pickerDate = date
                    showPicker = true
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "calendar")
                            .font(.system(size: 10))
                        Text(Self.dateFormatter.string(from: date))
                            .font(.system(size: 12))
                    }
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppColors.cardBackgroundElevated)
                    .cornerRadius(6)
                    .foregroundColor(isOverdue(date) ? AppColors.zoneDown : AppColors.accent)
                }
                Button {
                    onChange(nil)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    DatePicker("", selection: $pickerDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .navigationTitle(L10n.current == .ja ? "日付を選択" : "Select Date")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(L10n.save) {
                                    onChange(Calendar.current.startOfDay(for: pickerDate))
                                    showPicker = false
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button(L10n.cancel) { showPicker = false }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        } else {
            Button {
                pickerDate = Date()
                showPicker = true
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16))
                    .foregroundColor(AppColors.textSecondary)
            }
            .sheet(isPresented: $showPicker) {
                NavigationStack {
                    DatePicker("", selection: $pickerDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                        .navigationTitle(L10n.current == .ja ? "日付を選択" : "Select Date")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button(L10n.save) {
                                    onChange(Calendar.current.startOfDay(for: pickerDate))
                                    showPicker = false
                                }
                            }
                            ToolbarItem(placement: .cancellationAction) {
                                Button(L10n.cancel) { showPicker = false }
                            }
                        }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private func isOverdue(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
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
    @State private var deleteTarget: GoalTask?
    @State private var deleteCategory: DeleteCategory?

    enum DeleteCategory { case excited, stretch, task }

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
                    GoalTaskDateBadge(dueDate: $goalTask.wrappedValue.dueDate) { newDate in
                        $goalTask.wrappedValue.dueDate = newDate
                    }
                    Button(action: {
                        deleteTarget = goalTask
                        deleteCategory = .excited
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
                    GoalTaskDateBadge(dueDate: $goalTask.wrappedValue.dueDate) { newDate in
                        $goalTask.wrappedValue.dueDate = newDate
                    }
                    Button(action: {
                        deleteTarget = goalTask
                        deleteCategory = .stretch
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
                    GoalTaskDateBadge(dueDate: $task.wrappedValue.dueDate) { newDate in
                        $task.wrappedValue.dueDate = newDate
                    }
                    Button(action: {
                        deleteTarget = task
                        deleteCategory = .task
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
        .confirmationDialog(
            L10n.current == .ja ? "削除しますか？" : "Delete this item?",
            isPresented: Binding(get: { deleteTarget != nil }, set: { if !$0 { deleteTarget = nil } }),
            titleVisibility: .visible
        ) {
            Button(L10n.current == .ja ? "削除" : "Delete", role: .destructive) {
                guard let target = deleteTarget, let category = deleteCategory else { return }
                switch category {
                case .excited: goal.excitedGoals.removeAll { $0.id == target.id }
                case .stretch: goal.stretchGoals.removeAll { $0.id == target.id }
                case .task: goal.tasks.removeAll { $0.id == target.id }
                }
                deleteTarget = nil
            }
            Button(L10n.current == .ja ? "キャンセル" : "Cancel", role: .cancel) {
                deleteTarget = nil
            }
        }
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
        Group {
            #if targetEnvironment(macCatalyst)
            macLayout
            #else
            iOSLayout
            #endif
        }
        .navigationTitle(L10n.tabGoal)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear(perform: loadGoals)
        .onChange(of: monthlyGoals) { _, _ in saveGoals() }
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

    // MARK: - Mac 2カラムレイアウト

    private var macLayout: some View {
        HStack(alignment: .top, spacing: 0) {
            // 左: 月選択 + 進捗 + 手紙
            ScrollView {
                VStack(spacing: 16) {
                    GoalMonthSelector(selectedDate: $selectedDate)

                    if let goal = goalForMonth {
                        GoalProgressView(goal: goal)
                        macLetterSection(goal: goal)
                    } else {
                        Button(L10n.createGoal) { createGoalForMonth() }
                            .buttonStyle(.borderedProminent)
                            .tint(AppColors.accent)
                            .padding(.top, 8)
                    }
                }
                .padding(20)
            }
            .frame(width: 340)
            .scrollIndicators(.hidden)

            Divider()
                .background(AppColors.cardBackgroundElevated)

            // 右: 目標エディタ
            ScrollView {
                if let goal = goalForMonth {
                    GoalEditor(
                        goal: binding(for: goal),
                        showLetterSheet: $showLetterSheet,
                        ratingsForDates: ratingsForDates,
                        items: items,
                        emotionDict: emotionDict
                    )
                    .padding(.bottom, 40)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "target")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textSecondary)
                        Text(L10n.current == .ja ? "左パネルで月を選択して目標を作成しましょう" : "Select a month in the left panel to create goals")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                }
            }
            .frame(maxWidth: .infinity)
            .scrollIndicators(.hidden)
        }
    }

    @ViewBuilder
    private func macLetterSection(goal: MonthlyGoal) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L10n.current == .ja ? "💛 自分への手紙" : "💛 Letter to Yourself")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Text(L10n.letterToSelf)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            if goal.letterToSelf.isEmpty {
                Button {
                    showLetterSheet = true
                } label: {
                    Label(L10n.current == .ja ? "手紙を書く" : "Write a letter", systemImage: "pencil.line")
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
                    Button { showLetterSheet = true } label: {
                        Image(systemName: "pencil")
                    }
                }
            }
        }
        .card()
    }

    // MARK: - iOS レイアウト

    private var iOSLayout: some View {
        ScrollView {
            VStack(spacing: 12) {
                GoalMonthSelector(selectedDate: $selectedDate)

                if let goal = goalForMonth {
                    GoalProgressView(goal: goal)

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
                                    Button { showLetterSheet = true } label: {
                                        Image(systemName: "pencil")
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Button(L10n.createGoal) { createGoalForMonth() }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.accent)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
            .padding()
            .macContentFrame()
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
            preconditionFailure("Goal not found in monthlyGoals — this should never happen")
        }
        return $monthlyGoals[idx]
    }

    // 目標新規作成
    private func createGoalForMonth() {
        guard let selectedDate = selectedDate else { return }
        let calendar = Calendar.current
        let newGoal = MonthlyGoal(
            id: UUID(),
            year: calendar.component(.year, from: selectedDate),
            month: calendar.component(.month, from: selectedDate),
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
        Calendar.current.component(.year, from: selectedDate ?? Date())
    }
    private var selectedMonth: Int {
        Calendar.current.component(.month, from: selectedDate ?? Date())
    }
}
