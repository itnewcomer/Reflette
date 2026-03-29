import SwiftUI
import SwiftData
import UserNotifications

struct WeeklySummaryScheduler {
    static func schedule(items: [Item]) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])

        let content = UNMutableNotificationContent()
        content.title = L10n.current == .ja ? "今週の振り返り" : "Weekly Review"
        content.body = generateSummary(items: items)
        content.sound = .default

        // 毎週日曜 20:00
        var trigger = DateComponents()
        trigger.weekday = 1 // 日曜
        trigger.hour = 20
        trigger.minute = 0

        let request = UNNotificationRequest(
            identifier: "weekly_summary",
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: trigger, repeats: true)
        )
        center.add(request)
    }

    static func remove() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["weekly_summary"])
    }

    private static func generateSummary(items: [Item]) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) else {
            return L10n.current == .ja ? "今週の記録を振り返ってみましょう。" : "Let's review this week's records."
        }

        let weekItems = items.filter { $0.timestamp >= weekAgo && $0.timestamp <= today }
        guard !weekItems.isEmpty else {
            return L10n.current == .ja ? "今週はまだ記録がありません。" : "No records this week yet."
        }

        let avgRating = Double(weekItems.map(\.rating).reduce(0, +)) / Double(weekItems.count)
        let topEmotion = weekItems.flatMap(\.emotions)
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?.key ?? (L10n.current == .ja ? "なし" : "none")

        let fmt = L10n.current == .ja ? "記録%d日 / 平均%.1f / 最多「%@」" : "%d days / avg %.1f / top \"%@\""
        return String(format: fmt, weekItems.count, avgRating, topEmotion)
    }
}
