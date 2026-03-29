import Foundation

enum AppLanguage: String, CaseIterable {
    case ja = "ja"
    case en = "en"

    var displayName: String {
        switch self {
        case .ja: return "日本語"
        case .en: return "English"
        }
    }
}

struct L10n {
    static var current: AppLanguage {
        AppLanguage(rawValue: UserDefaults.standard.string(forKey: "appLanguage") ?? "ja") ?? .ja
    }

    static func set(_ lang: AppLanguage) {
        UserDefaults.standard.set(lang.rawValue, forKey: "appLanguage")
    }

    // MARK: - タブ
    static var tabCalendar: String { current == .ja ? "カレンダー" : "Calendar" }
    static var tabReport: String { current == .ja ? "レポート" : "Report" }
    static var tabGoal: String { current == .ja ? "振り返り" : "Reflect" }
    static var tabSettings: String { current == .ja ? "設定" : "Settings" }

    // MARK: - 共通
    static var save: String { current == .ja ? "保存" : "Save" }
    static var update: String { current == .ja ? "更新" : "Update" }
    static var cancel: String { current == .ja ? "キャンセル" : "Cancel" }
    static var delete: String { current == .ja ? "削除" : "Delete" }
    static var close: String { current == .ja ? "閉じる" : "Close" }
    static var error: String { current == .ja ? "エラー" : "Error" }
    static var noData: String { current == .ja ? "データなし" : "No data" }

    // MARK: - カレンダー
    static var streakDays: String { current == .ja ? "日連続" : " day streak" }
    static var deleteConfirmTitle: String { current == .ja ? "削除確認" : "Confirm Delete" }
    static var deleteConfirmMessage: String { current == .ja ? "この日の記録を完全に削除しますか？" : "Delete this day's record permanently?" }

    // MARK: - 記録エディタ
    static var dateNotSelected: String { current == .ja ? "日付未選択" : "No date selected" }
    static var tagHint: String { current == .ja ? "#家族 #仕事 のようにタグも一緒に登録して集計できます" : "Add tags like #family #work to track patterns" }
    static var emotionNudge: String { current == .ja ? "もう少し細かく言うと？" : "Can you be more specific?" }
    static var saveFailed: String { current == .ja ? "保存に失敗しました" : "Failed to save" }

    // MARK: - レポート
    static var monthly: String { current == .ja ? "月間" : "Monthly" }
    static var yearly: String { current == .ja ? "年間" : "Yearly" }
    static var monthlyReport: String { current == .ja ? "月間レポート" : "Monthly Report" }
    static var yearlyReport: String { current == .ja ? "年間レポート" : "Yearly Report" }
    static var reportType: String { current == .ja ? "レポート種別" : "Report Type" }
    static var emotionVocabulary: String { current == .ja ? "感情ボキャブラリー" : "Emotion Vocabulary" }
    static var tagEmotionDistribution: String { current == .ja ? "タグごとの感情分布" : "Emotion Distribution by Tag" }
    static var insights: String { current == .ja ? "インサイト" : "Insights" }

    // MARK: - インサイト
    static var noDataYet: String { current == .ja ? "データがまだありません。記録を始めましょう。" : "No data yet. Start recording!" }
    static func avgRatingChange(from: Double, to: Double, direction: String) -> String {
        let dir = current == .ja ? direction : (direction == "上昇" ? "increased" : "decreased")
        return String(format: current == .ja ? "平均気分が %.1f → %.1f に%@しています" : "Average mood %@ from %.1f to %.1f", dir, from, to)
    }
    static func topEmotion(_ name: String, count: Int) -> String {
        let n = emotionName(name)
        return current == .ja ? "最も多い感情は「\(n)」（\(count)回）です" : "Most frequent: \"\(n)\" (\(count) times)"
    }
    static func emotionIncrease(_ name: String, pct: Int) -> String {
        let n = emotionName(name)
        return current == .ja ? "「\(n)」が前期比 +\(pct)% 増加" : "\"\(n)\" increased +\(pct)% vs previous"
    }
    static func bestTag(_ tag: String, avg: Double) -> String {
        String(format: current == .ja ? "最もポジティブなタグは %@（平均 %.1f）です" : "Most positive tag: %@ (avg %.1f)", tag, avg)
    }
    static func worstTag(_ tag: String, avg: Double) -> String {
        String(format: current == .ja ? "%@ タグの平均気分が %.1f と低めです" : "%@ tag has low average mood: %.1f", tag, avg)
    }
    static func negativeTagIncrease(_ tag: String) -> String {
        current == .ja ? "\(tag) でネガティブ感情が前期比で増加しています" : "Negative emotions increased for \(tag) vs previous period"
    }
    static func allGood(_ avg: Double) -> String {
        String(format: current == .ja ? "平均気分は %.1f です。順調です！" : "Average mood is %.1f. Looking good!", avg)
    }

    // MARK: - ボキャブラリースコア
    static var vocabHigh: String { current == .ja ? "感情の粒度が高いです。研究によると、ストレス耐性が高い傾向があります。" : "High emotional granularity. Research shows this correlates with greater stress resilience." }
    static var vocabMid: String { current == .ja ? "もう少し細かく感情を区別してみましょう。似た感情の違いに注目すると効果的です。" : "Try distinguishing emotions more precisely. Notice subtle differences between similar feelings." }
    static var vocabLow: String { current == .ja ? "感情の種類を増やしてみましょう。細かく分類できるほど、心の回復力が高まります。" : "Try using more emotion types. Greater differentiation builds emotional resilience." }

    // MARK: - 設定
    static var dailyReminder: String { current == .ja ? "日時リマインダー" : "Daily Reminder" }
    static var monthlyReminder: String { current == .ja ? "月次リマインダー" : "Monthly Reminder" }
    static var weeklySummary: String { current == .ja ? "週次サマリー" : "Weekly Summary" }
    static var weeklySummaryDesc: String { current == .ja ? "日曜20時に今週の振り返りを通知" : "Get weekly review notification on Sunday 8PM" }
    static var enable: String { current == .ja ? "有効にする" : "Enable" }
    static var backup: String { current == .ja ? "バックアップ" : "Backup" }
    static var exportData: String { current == .ja ? "データをエクスポート" : "Export Data" }
    static var importData: String { current == .ja ? "データをインポート" : "Import Data" }
    static var info: String { current == .ja ? "情報" : "Info" }
    static var version: String { current == .ja ? "バージョン" : "Version" }
    static var language: String { current == .ja ? "言語" : "Language" }
    static var guide: String { current == .ja ? "記録ガイド（科学的根拠）" : "Recording Guide (Science-backed)" }

    // MARK: - 目標
    static var excitedGoals: String { current == .ja ? "Excited Goals（ワクワク目標・最大5つ）" : "Excited Goals (max 5)" }
    static var stretchGoals: String { current == .ja ? "Stretch Goals（ストレッチ目標・最大5つ）" : "Stretch Goals (max 5)" }
    static var tasks: String { current == .ja ? "Task（ToDo・最大20個）" : "Tasks (max 20)" }
    static var letterToSelf: String { current == .ja ? "自分への手紙（大事な友人や恋人、家族に送るように自分に優しい言葉をかけてね）" : "Letter to yourself (Write with the kindness you'd show a dear friend)" }
    static var createGoal: String { current == .ja ? "この月の目標を作成" : "Create this month's goals" }

    // MARK: - 目標・振り返り日
    static var goalDay: String { current == .ja ? "目標設定日" : "Goal Setting Day" }
    static var reflectDay: String { current == .ja ? "振り返り日" : "Reflect Day" }

    // MARK: - 通知
    static var dailyReminderTitle: String { current == .ja ? "今日の記録をつけましょう" : "Time to record today's mood" }
    static var dailyReminderBody: String { current == .ja ? "カレンダーに今日の気分や出来事を記録しましょう。" : "Record your feelings and events in the calendar." }
    static var monthlyReminderTitle: String { current == .ja ? "月次レポートを見てみましょう" : "Check your monthly report" }
    static var monthlyReminderBody: String { current == .ja ? "1ヶ月の振り返りをしてみませんか？" : "How about reviewing your month?" }

    // MARK: - 感情名
    private static let emotionNames: [String: String] = [
        "Peaceful": "穏やか", "Grateful": "感謝", "Awe": "畏敬",
        "Safe": "安心", "Calm": "落ち着き", "Curious": "好奇心",
        "Cozy": "心地よい", "Chill": "のんびり", "Fine": "まあまあ",
        "Love": "愛情", "Connected": "つながり", "Joy": "喜び",
        "Creative": "創造的", "Happy": "幸せ", "Excited": "ワクワク",
        "Pleasant": "快適", "Silly": "おちゃめ", "Energetic": "活力",
        "Tired": "疲れ", "Disappointed": "がっかり", "Bored": "退屈",
        "Miserable": "惨め", "Sad": "悲しい", "Shy": "恥ずかしい",
        "Depressed": "憂うつ", "Lonely": "孤独", "Ashamed": "恥",
        "Annoyed": "イライラ", "Frustrated": "もどかしい", "Rowdy": "荒れ気味",
        "Embarrassed": "気まずい", "Angry": "怒り", "Stressed": "ストレス",
        "Anxious": "不安", "Jealous": "嫉妬", "Furious": "激怒",
    ]
    static func emotionName(_ key: String) -> String {
        if current == .ja { return emotionNames[key] ?? key }
        return key
    }

    // MARK: - 感情グループ名
    static func groupName(_ key: String) -> String {
        let ja: [String: String] = ["calm": "落ち着き・安心", "active": "活発・ポジティブ", "down": "落ち込み・内向き", "upset": "不快・怒り"]
        let en: [String: String] = ["calm": "Calm & Secure", "active": "Active & Positive", "down": "Down & Inward", "upset": "Upset & Angry"]
        return (current == .ja ? ja[key] : en[key]) ?? key
    }

    // MARK: - バックアップ追加
    static var restoreConfirm: String { current == .ja ? "復元確認" : "Restore Confirm" }
    static var restoreButton: String { current == .ja ? "復元（既存データに追加）" : "Restore (add to existing)" }
    static var restoreMessage: String { current == .ja ? "インポートしたデータを既存データに追加します。" : "Imported data will be added to existing records." }
    static var fileAccessDenied: String { current == .ja ? "ファイルへのアクセスが拒否されました" : "File access denied" }
    static var exportFailed: String { current == .ja ? "エクスポートに失敗しました" : "Export failed" }
    static var importFailed: String { current == .ja ? "インポートに失敗しました" : "Import failed" }
    static var fileSelectError: String { current == .ja ? "ファイル選択エラー" : "File selection error" }
    static func importSuccess(_ imported: Int, _ skipped: Int) -> String {
        current == .ja ? "\(imported)件インポート（重複\(skipped)件スキップ）" : "Imported \(imported) records (\(skipped) duplicates skipped)"
    }
    static func recordCount(_ count: Int) -> String {
        current == .ja ? "記録数: \(count)件" : "\(count) records"
    }

    // MARK: - 目標追加
    static var newExcitedGoal: String { current == .ja ? "新しいワクワク目標" : "New excited goal" }
    static var newStretchGoal: String { current == .ja ? "新しいストレッチ目標" : "New stretch goal" }
    static var newTask: String { current == .ja ? "新しいタスク" : "New task" }
    static var notWritten: String { current == .ja ? "未記入" : "Not written" }
    static var add: String { current == .ja ? "追加" : "Add" }
    static var year: String { current == .ja ? "年" : "Year" }
    static var month: String { current == .ja ? "月" : "Month" }
    static func yearLabel(_ y: Int) -> String { current == .ja ? "\(y)年" : "\(y)" }
    static func monthLabel(_ m: Int) -> String { current == .ja ? "\(m)月" : "\(m)" }
    static func dayLabel(_ d: Int) -> String { current == .ja ? "\(d)日" : "\(d)" }

    // MARK: - 設定追加
    static var reminderTime: String { current == .ja ? "リマインド時刻" : "Reminder time" }
    static var date: String { current == .ja ? "日付" : "Date" }
    static var time: String { current == .ja ? "時刻" : "Time" }
    static var monthlyReview: String { current == .ja ? "今月の振り返り" : "Monthly Review" }
}
