import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    // 日時リマインダー
    @AppStorage("reminderDate") private var reminderDate: Double = Date().timeIntervalSince1970
    @AppStorage("reminderEnabled") private var reminderEnabled: Bool = false

    // 月次リマインダー
    @AppStorage("monthlyReminderDay") private var monthlyReminderDay: Int = 1
    @AppStorage("monthlyReminderHour") private var monthlyReminderHour: Int = 9
    @AppStorage("monthlyReminderEnabled") private var monthlyReminderEnabled: Bool = false

    // 週次サマリー
    @AppStorage("appLanguage") private var appLanguage: String = "ja"
    @AppStorage("weeklySummaryEnabled") private var weeklySummaryEnabled: Bool = false
    @Query(sort: \Item.timestamp) private var items: [Item]
    @State private var showGuide = false

    var body: some View {
        NavigationView {
            Form {
                // 日時リマインダー
                Section(header: Text(L10n.dailyReminder)) {
                    Toggle(L10n.enable, isOn: $reminderEnabled)
                        .onChange(of: reminderEnabled) { _, newValue in
                            if newValue {
                                scheduleDailyReminder()
                            } else {
                                removeDailyReminder()
                            }
                        }
                    DatePicker(L10n.reminderTime, selection: Binding(
                        get: { Date(timeIntervalSince1970: reminderDate) },
                        set: {
                            reminderDate = $0.timeIntervalSince1970
                            if reminderEnabled {
                                scheduleDailyReminder()
                            }
                        }
                    ), displayedComponents: [.hourAndMinute])
                        .disabled(!reminderEnabled)
                }

                // 月次リマインダー
                Section(header: Text(L10n.monthlyReminder)) {
                    Toggle(L10n.enable, isOn: $monthlyReminderEnabled)
                        .onChange(of: monthlyReminderEnabled) { _, newValue in
                            if newValue {
                                scheduleMonthlyReminder()
                            } else {
                                removeMonthlyReminder()
                            }
                        }
                    HStack {
                        Text(L10n.date)
                        Picker("", selection: $monthlyReminderDay) {
                            ForEach(1...28, id: \.self) { day in
                                Text(L10n.dayLabel(day)).tag(day)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(!monthlyReminderEnabled)
                        .onChange(of: monthlyReminderDay) { _, _ in
                            if monthlyReminderEnabled { scheduleMonthlyReminder() }
                        }
                    }
                    HStack {
                        Text(L10n.time)
                        Picker("", selection: $monthlyReminderHour) {
                            ForEach(0..<24, id: \.self) { hour in
                                Text(String(format: "%02d:00", hour)).tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .disabled(!monthlyReminderEnabled)
                        .onChange(of: monthlyReminderHour) { _, _ in
                            if monthlyReminderEnabled { scheduleMonthlyReminder() }
                        }
                    }
                }

                // 目標・振り返り日
                Section(header: Text(L10n.current == .ja ? "目標・振り返り" : "Goals & Reflect")) {
                    DayRulePicker(label: L10n.goalDay, key: "goalDayRule", defaultDay: 1)
                    DayRulePicker(label: L10n.reflectDay, key: "reflectDayRule", defaultDay: 25)
                }

                // バックアップ
                BackupView()

                // 週次サマリー
                Section(header: Text(L10n.weeklySummary)) {
                    Toggle(L10n.weeklySummaryDesc, isOn: $weeklySummaryEnabled)
                        .onChange(of: weeklySummaryEnabled) { _, newValue in
                            if newValue {
                                WeeklySummaryScheduler.schedule(items: items)
                            } else {
                                WeeklySummaryScheduler.remove()
                            }
                        }
                }

                // 情報
                Section(header: Text(L10n.info)) {
                    // 言語切り替え
                    Picker(L10n.language, selection: $appLanguage) {
                        ForEach(AppLanguage.allCases, id: \.rawValue) { lang in
                            Text(lang.displayName).tag(lang.rawValue)
                        }
                    }

                    Button {
                        showGuide = true
                    } label: {
                        Label(L10n.guide, systemImage: "book.fill")
                    }
                    HStack {
                        Text(L10n.version)
                        Spacer()
                        Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "-")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle(L10n.tabSettings)
            .scrollContentBackground(.hidden)
            .background(AppColors.background.ignoresSafeArea())
        }
        .sheet(isPresented: $showGuide) {
            GuideView()
        }
        .onAppear {
            requestNotificationPermission()
        }
    }

    // MARK: - Notification Helpers

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func scheduleDailyReminder() {
        removeDailyReminder()
        let date = Date(timeIntervalSince1970: reminderDate)
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        var trigger = DateComponents()
        trigger.hour = components.hour
        trigger.minute = components.minute

        let content = UNMutableNotificationContent()
        content.title = L10n.dailyReminderTitle
        content.body = L10n.dailyReminderBody
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "daily_reminder",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func removeDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["daily_reminder"])
    }

    private func scheduleMonthlyReminder() {
        removeMonthlyReminder()
        var trigger = DateComponents()
        trigger.day = monthlyReminderDay
        trigger.hour = monthlyReminderHour
        trigger.minute = 0

        let content = UNMutableNotificationContent()
        content.title = L10n.monthlyReminderTitle
        content.body = L10n.monthlyReminderBody
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "monthly_reminder",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        UNUserNotificationCenter.current().add(request)
    }

    private func removeMonthlyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["monthly_reminder"])
    }
}
