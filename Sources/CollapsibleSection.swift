import SwiftUI

struct CollapsibleSection<Content: View>: View {
    let title: String
    let isExpanded: Bool
    let onTap: () -> Void
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) { onTap() }
            }) {
                HStack {
                    Text(title)
                        .font(.subheadline).bold()
                        .foregroundColor(AppColors.textPrimary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(12)
                .background(AppColors.cardBackground)
                .cornerRadius(isExpanded ? 0 : 12)
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
                    .padding(12)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(RoundedRectangle(cornerRadius: 12).fill(AppColors.cardBackground))
        .clipped()
    }
}
