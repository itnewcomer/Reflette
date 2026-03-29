import SwiftUI

struct SelfCompassionView: View {
    var items: [Item]
    var selectedDate: Date?

    private var shouldShow: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // 直近3日間で気分1-2が2回以上
        let recent = items.filter {
            let daysBetween = calendar.dateComponents([.day], from: $0.timestamp, to: today).day ?? 99
            return daysBetween >= 0 && daysBetween <= 2
        }
        let lowCount = recent.filter { $0.rating <= 2 }.count
        return lowCount >= 2
    }

    private var message: (title: String, body: String) {
        let messages: [(String, String, String, String)] = [
            ("つらい日が続いていますね",
             "大切な友人にかけるような言葉を、自分にもかけてあげてください。つらさを感じられること自体が、あなたの強さです。",
             "It's been a tough few days",
             "Speak to yourself as you would to a dear friend. Feeling the pain is itself a sign of your strength."),
            ("がんばっていますね",
             "完璧でなくていい。記録を続けているだけで、あなたは自分と向き合っています。",
             "You're doing your best",
             "You don't have to be perfect. Just by recording, you're already facing yourself."),
            ("少し立ち止まってみませんか",
             "深呼吸をして、今の自分をそのまま受け入れてみてください。",
             "Take a moment to pause",
             "Take a deep breath and accept yourself as you are right now."),
        ]
        let idx = Calendar.current.component(.day, from: Date()) % messages.count
        let m = messages[idx]
        return L10n.current == .ja ? (m.0, m.1) : (m.2, m.3)
    }

    var body: some View {
        if shouldShow {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text("💛")
                    Text(message.title)
                        .font(.subheadline).bold()
                        .foregroundColor(AppColors.accent)
                }
                Text(message.body)
                    .font(.caption)
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(L10n.current == .ja
                     ? "— Breines & Chen (2012): セルフコンパッションは回復力を高めます"
                     : "— Breines & Chen (2012): Self-compassion builds resilience")
                    .font(.system(size: 8))
                    .foregroundColor(AppColors.textSecondary)
            }
            .card()
        }
    }
}
