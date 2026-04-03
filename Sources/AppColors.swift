import SwiftUI

/// 科学的根拠に基づく配色
///
/// 参考: Elliot & Maier (2014), Goldstein (1942), Valdez & Mehrabian (1994)
/// デザイン参考: Calm, Headspace, eMoods のダークモード
///
/// 原則:
/// - 背景は真っ黒ではなく深い紺（副交感神経を刺激しつつ温かみを保つ）
/// - カードは背景より少し明るい色で浮かせる
/// - アクセントは低彩度の暖色（温かみ・安心感）
enum AppColors {
    // MARK: - 背景（深い紺系: 鎮静効果 + 温かみ）
    static let background = Color(red: 0.10, green: 0.11, blue: 0.16)
    static let cardBackground = Color(red: 0.15, green: 0.16, blue: 0.22)
    static let cardBackgroundElevated = Color(red: 0.19, green: 0.20, blue: 0.27)

    // MARK: - テキスト
    static let textPrimary = Color(red: 0.92, green: 0.93, blue: 0.95)
    static let textSecondary = Color(red: 0.58, green: 0.60, blue: 0.68)

    // MARK: - アクセント
    static let accent = Color(red: 0.82, green: 0.62, blue: 0.42)
    static let accentSoft = Color(red: 0.82, green: 0.62, blue: 0.42).opacity(0.15)

    // MARK: - Rating カラー（寒色→暖色）
    // Rating カラー（科学的根拠に基づく）
    // Carruthers et al. (2010): 明るく彩度の高い色 = ポジティブ
    // Jonauskaite et al. (2020): 黄・オレンジ = 喜び（30カ国で一貫）
    // 原則: 明度を全体的に高めに。カレンダーが埋まるほど画面が明るくなる
    static let ratingColors: [Color] = [
        Color(red: 0.55, green: 0.50, blue: 0.68),  // 1: ラベンダー（控えめだが灰色ではない）
        Color(red: 0.45, green: 0.62, blue: 0.78),  // 2: スカイブルー（落ち着き）
        Color(red: 0.50, green: 0.75, blue: 0.55),  // 3: ミントグリーン（安定・中立）
        Color(red: 0.95, green: 0.82, blue: 0.35),  // 4: サンシャインイエロー（明るさ）
        Color(red: 1.00, green: 0.65, blue: 0.28),  // 5: ビビッドオレンジ（喜び・活力）
    ]

    // MARK: - 感情ゾーン
    static let zoneCalm = Color(red: 0.55, green: 0.78, blue: 0.65)
    static let zoneActive = Color(red: 0.92, green: 0.75, blue: 0.42)
    static let zoneDown = Color(red: 0.45, green: 0.60, blue: 0.82)
    static let zoneUpset = Color(red: 0.88, green: 0.50, blue: 0.40)
    static let zoneColors: [Color] = [zoneCalm, zoneActive, zoneDown, zoneUpset]

    // MARK: - 機能色
    static let streak = Color(red: 0.90, green: 0.65, blue: 0.35)
    static let success = Color(red: 0.45, green: 0.75, blue: 0.55)
    static let today = Color(red: 1.0, green: 0.40, blue: 0.40)  // 赤系 — 他の色と被らず目立つ
}

// MARK: - 共通カードスタイル
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.cardBackground))
    }
}

struct ElevatedCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.cardBackgroundElevated))
    }
}

extension View {
    func card() -> some View { modifier(CardStyle()) }
    func elevatedCard() -> some View { modifier(ElevatedCardStyle()) }
    func screenBackground() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppColors.background)
    }

    /// Mac Catalyst では最大幅を制限して中央寄せ、iOSではそのまま
    func macContentFrame() -> some View {
        #if targetEnvironment(macCatalyst)
        self.frame(maxWidth: 720).frame(maxWidth: .infinity)
        #else
        self
        #endif
    }
}

