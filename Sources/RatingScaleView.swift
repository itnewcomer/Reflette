import SwiftUI

struct RatingScaleView: View {
    var body: some View {
        HStack(spacing: 4) {
            Text("😞")
                .font(.system(size: 10))
            ForEach(0..<5) { i in
                RoundedRectangle(cornerRadius: 2)
                    .fill(AppColors.ratingColors[i])
                    .frame(width: 20, height: 8)
            }
            Text("😆")
                .font(.system(size: 10))
        }
    }
}
