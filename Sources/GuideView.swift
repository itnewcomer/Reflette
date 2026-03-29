import SwiftUI

struct GuideView: View {
    @Environment(\.dismiss) private var dismiss
    var onStartRecord: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {

                    // イントロ
                    VStack(alignment: .leading, spacing: 8) {
                        Text(L10n.current == .ja ? "なぜ感情を記録するのか？" : "Why Record Your Emotions?")
                            .font(.title2).bold()
                        Text(L10n.current == .ja
                             ? "感情を「ただ感じる」だけでなく、「記録・分類・言語化」することで、脳の回路が切り替わり、心の回復力（レジリエンス）が高まることが科学的に証明されています。"
                             : "Science shows that recording, categorizing, and labeling emotions—not just feeling them—rewires your brain and builds resilience.")
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    // ステップ1
                    GuideStepView(
                        step: 1,
                        title: L10n.current == .ja ? "感情マトリクスで位置を決める" : "Locate yourself on the emotion matrix",
                        subtitle: L10n.current == .ja ? "感情の粒度を上げる" : "Increase emotional granularity",
                        icon: "🎯",
                        content: L10n.current == .ja ? """
                        Refletteの感情マトリクスは4つのゾーンに分かれています。

                        🟢 落ち着き・安心（快 × 低エネルギー）
                        　Peaceful, Calm, Grateful...

                        🟡 活発・ポジティブ（快 × 高エネルギー）
                        　Joy, Excited, Love...

                        🔵 落ち込み・内向き（不快 × 低エネルギー）
                        　Sad, Lonely, Tired...

                        🔴 不快・怒り（不快 × 高エネルギー）
                        　Angry, Stressed, Frustrated...

                        今の自分がどのゾーンにいるか、直感で選んでください。
                        """ : """
                        Reflette's emotion matrix has 4 zones:

                        🟢 Calm & Secure (Pleasant × Low Energy)
                        　Peaceful, Calm, Grateful...

                        🟡 Active & Positive (Pleasant × High Energy)
                        　Joy, Excited, Love...

                        🔵 Down & Inward (Unpleasant × Low Energy)
                        　Sad, Lonely, Tired...

                        🔴 Upset & Angry (Unpleasant × High Energy)
                        　Angry, Stressed, Frustrated...

                        Trust your gut—pick the zone that fits.
                        """,
                        evidence: L10n.current == .ja
                            ? "イェール大学のムードメーター研究に基づく2軸モデル（快-不快 × エネルギー高-低）を採用しています。"
                            : "Based on Yale's Mood Meter research using a 2-axis model (pleasant-unpleasant × high-low energy)."
                    )

                    // ステップ2
                    GuideStepView(
                        step: 2,
                        title: L10n.current == .ja ? "感情にラベルを貼る" : "Label your emotions",
                        subtitle: L10n.current == .ja ? "脳の鎮静化スイッチ" : "Activate your brain's calming switch",
                        icon: "🏷️",
                        content: L10n.current == .ja ? """
                        ゾーンを選んだら、さらに具体的な感情を選びます。

                        ❌「むかつく」のような大雑把な言葉
                        ⭕「軽蔑」「拒絶感」「焦燥」など精密な言葉

                        できるだけ細かく分類するほど効果が高まります。「もう少し細かく言うと？」の提案も活用してください。
                        """ : """
                        After picking a zone, choose specific emotions.

                        ❌ Vague words like "bad" or "upset"
                        ⭕ Precise words like "contempt," "rejection," "agitation"

                        The more precisely you label, the greater the effect. Use the "Can you be more specific?" suggestions.
                        """,
                        evidence: L10n.current == .ja
                            ? "Lieberman et al. (2007) の研究で、感情に名前をつける（ラベリング）だけで、恐怖を司る扁桃体の活動が抑制され、理性を司る右腹外側前頭前野が活性化することが実証されています。"
                            : "Lieberman et al. (2007) demonstrated that simply labeling emotions suppresses amygdala activity (fear center) and activates the right ventrolateral prefrontal cortex (rational thinking)."
                    )

                    // ステップ3
                    GuideStepView(
                        step: 3,
                        title: L10n.current == .ja ? "なぜその感情か、書き出す" : "Write why you feel that way",
                        subtitle: L10n.current == .ja ? "エクスプレッシブ・ライティング" : "Expressive Writing",
                        icon: "✍️",
                        content: L10n.current == .ja ? """
                        感情を選んだら、メモ欄に1〜3行だけ書きます。

                        📌 客観的な事実
                        「会議で意見を否定された」

                        💭 主観的な反応
                        「自分が必要とされていないと感じて、胸がざわついた」

                        #仕事 #会議 のようにタグをつけると、後から「何が感情の原因か」を分析できます。
                        """ : """
                        After choosing emotions, write 1-3 lines in the memo.

                        📌 Objective fact
                        "My idea was rejected in the meeting"

                        💭 Subjective reaction
                        "I felt unneeded and my chest tightened"

                        Add tags like #work #meeting to analyze what triggers your emotions later.
                        """,
                        evidence: L10n.current == .ja
                            ? "Pennebaker & Beall (1986) の研究で、感情を書き出すことで免疫機能（Tリンパ球）が向上し、通院回数が減少することが確認されています。15分の筆記を4日間続けるだけで効果が現れました。"
                            : "Pennebaker & Beall (1986) found that writing about emotions improved immune function (T-lymphocytes) and reduced doctor visits. Just 15 minutes of writing for 4 days showed measurable effects."
                    )

                    Divider()

                    // 科学的根拠まとめ
                    VStack(alignment: .leading, spacing: 16) {
                        Text("📚 科学的根拠")
                            .font(.title3).bold()

                        EvidenceCardView(
                            title: "感情ラベリングの効果",
                            authors: "Lieberman, M. D., et al. (2007)",
                            paper: "Putting Feelings Into Words: Affect Labeling Disrupts Amygdala Activity to Affective Stimuli",
                            finding: "感情に名前をつけると、扁桃体の活動が低下し、前頭前野が活性化する。脳が「暴走モード」から「分析モード」に切り替わる。"
                        )

                        EvidenceCardView(
                            title: "筆記開示の健康効果",
                            authors: "Pennebaker, J. W., & Beall, S. K. (1986)",
                            paper: "Confronting a traumatic event: toward an understanding of inhibition and disease",
                            finding: "感情を書き出すことで、免疫機能が向上し通院回数が減少。感情の記録は「薬」のような効果がある。"
                        )

                        EvidenceCardView(
                            title: L10n.current == .ja ? "感情の粒度とストレス耐性" : "Emotional Granularity & Stress Resilience",
                            authors: "Kashdan, T. B., Barrett, L. F., & McKnight, P. E. (2015)",
                            paper: "Unpacking emotion differentiation: Transforming unpleasant experience by perceiving distinctions in negativity",
                            finding: "感情を細かく分類できる人ほど、ストレス耐性が高く、依存行動が少ない。感情の「解像度」がレジリエンスの鍵。"
                        )

                        EvidenceCardView(
                            title: "感情記録の普遍的効果",
                            authors: "Smyth, J. M. (1998)",
                            paper: "Written emotional expression: Effect sizes, outcome types, and moderating variables",
                            finding: "140以上の研究を統合した結果、属性を問わず感情の言語化は幸福感の向上・パフォーマンス改善に寄与する。"
                        )
                    }

                    Divider()

                    // 続けるコツ
                    VStack(alignment: .leading, spacing: 8) {
                        Text("💡 " + (L10n.current == .ja ? "続けるコツ" : "Tips for Consistency"))
                            .font(.title3).bold()
                        BulletPointView(items: L10n.current == .ja ? [
                            "完璧を目指さない。星評価と感情1つ選ぶだけでもOK",
                            "毎日同じ時間に記録する（寝る前がおすすめ）",
                            "レポート画面で「感情ボキャブラリースコア」を上げることをゲーム感覚で楽しむ",
                            "月末に「自分への手紙」で1ヶ月を振り返る",
                        ] : [
                            "Don't aim for perfection. A star rating + one emotion is enough",
                            "Record at the same time daily (before bed works great)",
                            "Gamify it: try to increase your Emotion Vocabulary score in Reports",
                            "Write a Letter to Yourself at month's end to reflect",
                        ])
                    }

                    // CTA: 最初の記録へ
                    if onStartRecord != nil {
                        Button {
                            dismiss()
                            onStartRecord?()
                        } label: {
                            Label(
                                L10n.current == .ja ? "今日の気分を記録する" : "Record today's mood",
                                systemImage: "pencil.circle.fill"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppColors.accent)
                    }

                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle(L10n.current == .ja ? "記録ガイド" : "Recording Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(L10n.close) { dismiss() }
                }
            }
        }
    }
}

// MARK: - サブビュー

private struct GuideStepView: View {
    let step: Int
    let title: String
    let subtitle: String
    let icon: String
    let content: String
    let evidence: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(icon)
                    .font(.system(size: 32))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Step \(step)")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .bold()
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            Text(content)
                .font(.subheadline)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color(.secondarySystemBackground)))

            HStack(alignment: .top, spacing: 4) {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.accentColor)
                    .font(.caption)
                Text(evidence)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

private struct EvidenceCardView: View {
    let title: String
    let authors: String
    let paper: String
    let finding: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline).bold()
            Text(authors)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(paper)
                .font(.caption)
                .italic()
                .foregroundColor(.secondary)
            Text(finding)
                .font(.caption)
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 8).fill(Color(.tertiarySystemBackground)))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
    }
}

private struct BulletPointView: View {
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.accentColor)
                    Text(item)
                        .font(.subheadline)
                }
            }
        }
    }
}
