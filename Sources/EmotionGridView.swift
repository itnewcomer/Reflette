import SwiftUI

struct EmotionGridView: View {
    let group: EmotionGroup
    let item: Item
    @Binding var selectedEmotion: String?

    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(L10n.groupName(group.name))
                .font(.system(size: 9))
                .foregroundColor(AppColors.textSecondary)

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 4
            ) {
                ForEach(group.emotions) { emotion in
                    let isActive = item.emotions.contains(emotion.name)
                    Button {
                        if isActive {
                            selectedEmotion = (selectedEmotion == emotion.name) ? nil : emotion.name
                        }
                    } label: {
                        VStack(spacing: 1) {
                            Circle()
                                .fill(isActive ? emotion.color : Color.gray.opacity(0.3))
                                .overlay(
                                    Circle()
                                        .stroke(selectedEmotion == emotion.name ? Color.white : Color.clear, lineWidth: 2)
                                )
                                .frame(width: 14, height: 14)
                            Text(L10n.emotionName(emotion.name))
                                .font(.system(size: 7))
                                .foregroundColor(isActive ? AppColors.textPrimary : AppColors.textSecondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.6)
                        }
                    }
                    .buttonStyle(.plain)
                    .disabled(!isActive)
                }
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }
}
