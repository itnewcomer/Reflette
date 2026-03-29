import SwiftUI

// --- データモデル ---
struct Emotion: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let color: Color
}

struct EmotionGroup: Identifiable {
    let id = UUID()
    let name: String
    let emotions: [Emotion]
}

// --- グループ定義（管理・集計用） ---
let emotionGroups: [EmotionGroup] = [
    EmotionGroup(name: "calm", emotions: [
        Emotion(name: "Peaceful", color: Color(red:0.70, green:0.90, blue:0.80)),
        Emotion(name: "Grateful", color: Color(red:0.80, green:0.93, blue:0.74)),
        Emotion(name: "Awe", color: Color(red:0.99, green:0.96, blue:0.77)),
        Emotion(name: "Safe", color: Color(red:0.74, green:0.90, blue:0.85)),
        Emotion(name: "Calm", color: Color(red:0.73, green:0.91, blue:0.91)),
        Emotion(name: "Curious", color: Color(red:0.87, green:0.97, blue:0.82)),
        Emotion(name: "Cozy", color: Color(red:0.75, green:0.88, blue:0.80)),
        Emotion(name: "Chill", color: Color(red:0.72, green:0.87, blue:0.89)),
        Emotion(name: "Fine", color: Color(red:0.92, green:0.96, blue:0.85))
    ]),
    EmotionGroup(name: "active", emotions: [
        Emotion(name: "Love", color: Color(red:1.00, green:0.91, blue:0.70)),
        Emotion(name: "Connected", color: Color(red:1.00, green:0.91, blue:0.70)),
        Emotion(name: "Joy", color: Color(red:1.00, green:0.89, blue:0.53)),
        Emotion(name: "Creative", color: Color(red:0.99, green:0.95, blue:0.76)),
        Emotion(name: "Happy", color: Color(red:1.00, green:0.95, blue:0.65)),
        Emotion(name: "Excited", color: Color(red:1.00, green:0.88, blue:0.51)),
        Emotion(name: "Pleasant", color: Color(red:0.99, green:0.95, blue:0.78)),
        Emotion(name: "Silly", color: Color(red:1.00, green:0.93, blue:0.72)),
        Emotion(name: "Energetic", color: Color(red:1.00, green:0.80, blue:0.44))
    ]),
    EmotionGroup(name: "down", emotions: [
        Emotion(name: "Tired", color: Color(red:0.59, green:0.76, blue:0.92)),
        Emotion(name: "Disappointed", color: Color(red:0.51, green:0.68, blue:0.88)),
        Emotion(name: "Bored", color: Color(red:0.60, green:0.72, blue:0.82)),
        Emotion(name: "Miserable", color: Color(red:0.44, green:0.63, blue:0.88)),
        Emotion(name: "Sad", color: Color(red:0.38, green:0.54, blue:0.80)),
        Emotion(name: "Shy", color: Color(red:0.56, green:0.69, blue:0.89)),
        Emotion(name: "Depressed", color: Color(red:0.30, green:0.43, blue:0.70)),
        Emotion(name: "Lonely", color: Color(red:0.33, green:0.47, blue:0.74)),
        Emotion(name: "Ashamed", color: Color(red:0.51, green:0.56, blue:0.80))
    ]),
    EmotionGroup(name: "upset", emotions: [
        Emotion(name: "Annoyed", color: Color(red:0.98, green:0.70, blue:0.61)),
        Emotion(name: "Frustrated", color: Color(red:0.98, green:0.63, blue:0.49)),
        Emotion(name: "Rowdy", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Embarrassed", color: Color(red:0.98, green:0.76, blue:0.67)),
        Emotion(name: "Angry", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Stressed", color: Color(red:1.00, green:0.36, blue:0.22)),
        Emotion(name: "Anxious", color: Color(red:0.98, green:0.70, blue:0.61)),
        Emotion(name: "Jealous", color: Color(red:1.00, green:0.46, blue:0.26)),
        Emotion(name: "Furious", color: Color(red:1.00, green:0.22, blue:0.19))
    ])
]

// --- 紙の順番でEmotionを並べる ---
let emotionOrder: [String] = [
    // 1行目
    "Peaceful", "Grateful", "Awe", "Love", "Connected", "Joy",
    // 2行目
    "Safe", "Calm", "Curious", "Creative", "Happy", "Excited",
    // 3行目
    "Cozy", "Chill", "Fine", "Pleasant", "Silly", "Energetic",
    // 4行目
    "Tired", "Disappointed", "Bored", "Annoyed", "Frustrated", "Rowdy",
    // 5行目
    "Miserable", "Sad", "Shy", "Embarrassed", "Angry", "Stressed",
    // 6行目
    "Depressed", "Lonely", "Ashamed", "Anxious", "Jealous", "Furious"
]

// --- Emotion nameからEmotionを引く辞書を作成 ---
let emotionDict: [String: Emotion] = emotionGroups.flatMap { $0.emotions }.reduce(into: [:]) { $0[$1.name] = $1 }

// --- 紙の順番で6×6グリッドを作成 ---
let emotionRows: [[Emotion]] = stride(from: 0, to: emotionOrder.count, by: 6).map { i in
    (0..<6).compactMap { j in
        let idx = i + j
        guard idx < emotionOrder.count else { return nil }
        return emotionDict[emotionOrder[idx]]
    }
}

// --- グループタイトルと色（枠用） ---
var groupTitles: [String] {
    emotionGroups.map { L10n.groupName($0.name) }
}
let groupColors: [Color] = AppColors.zoneColors

// --- EmotionMatrixView本体 ---
struct EmotionMatrixView: View {
    let emotionRows: [[Emotion]]
    let emotionGroups: [EmotionGroup]
    @Binding var selectedEmotions: Set<String>

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 2), count: 6)

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(groupTitles[0]).font(.system(size: 9)).bold().foregroundColor(groupColors[0])
                Spacer()
                Text(groupTitles[1]).font(.system(size: 9)).bold().foregroundColor(groupColors[1])
            }

            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(emotionRows.flatMap { $0 }) { emotion in
                    let isSelected = selectedEmotions.contains(emotion.name)
                    Button {
                        if isSelected {
                            selectedEmotions.remove(emotion.name)
                        } else {
                            selectedEmotions.insert(emotion.name)
                        }
                    } label: {
                        VStack(spacing: 1) {
                            Circle()
                                .fill(emotion.color.opacity(isSelected ? 1.0 : 0.4))
                                .overlay(
                                    Circle().stroke(selectedEmotions.contains(emotion.name) ? Color.white : Color.clear, lineWidth: 2)
                                )
                                .frame(width: 22, height: 22)
                            Text(L10n.emotionName(emotion.name))
                                .font(.system(size: 8))
                                .foregroundColor(AppColors.textPrimary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
            .overlay(
                // 4象限の枠線
                GeometryReader { geo in
                    let midX = geo.size.width / 2
                    let midY = geo.size.height / 2
                    // 左上
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(groupColors[0].opacity(0.5), lineWidth: 1)
                        .frame(width: midX - 1, height: midY - 1)
                        .position(x: midX / 2, y: midY / 2)
                    // 右上
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(groupColors[1].opacity(0.5), lineWidth: 1)
                        .frame(width: midX - 1, height: midY - 1)
                        .position(x: midX + midX / 2, y: midY / 2)
                    // 左下
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(groupColors[2].opacity(0.5), lineWidth: 1)
                        .frame(width: midX - 1, height: midY - 1)
                        .position(x: midX / 2, y: midY + midY / 2)
                    // 右下
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(groupColors[3].opacity(0.5), lineWidth: 1)
                        .frame(width: midX - 1, height: midY - 1)
                        .position(x: midX + midX / 2, y: midY + midY / 2)
                }
            )

            // グループタイトル下段
            HStack {
                Text(groupTitles[2]).font(.system(size: 9)).bold().foregroundColor(groupColors[2])
                Spacer()
                Text(groupTitles[3]).font(.system(size: 9)).bold().foregroundColor(groupColors[3])
            }
        }
        .padding(.horizontal, 4)
    }
}

