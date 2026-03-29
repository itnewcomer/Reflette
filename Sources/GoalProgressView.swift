import SwiftUI

struct GoalProgressView: View {
    let goal: MonthlyGoal

    private var totalTasks: Int {
        goal.excitedGoals.count + goal.stretchGoals.count + goal.tasks.count
    }

    private var completedTasks: Int {
        goal.excitedGoals.filter(\.isCompleted).count +
        goal.stretchGoals.filter(\.isCompleted).count +
        goal.tasks.filter(\.isCompleted).count
    }

    private var progress: Double {
        totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
    }

    private var ringColor: Color {
        if progress >= 0.8 { return AppColors.success }
        if progress >= 0.5 { return AppColors.accent }
        return AppColors.zoneDown
    }

    var body: some View {
        if totalTasks > 0 {
            HStack(spacing: 16) {
                // プログレスリング
                ZStack {
                    Circle()
                        .stroke(AppColors.cardBackgroundElevated, lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 0.5), value: progress)
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ringColor)
                }
                .frame(width: 64, height: 64)

                // 内訳
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.current == .ja ? "目標達成率" : "Goal Progress")
                        .font(.subheadline).bold()
                        .foregroundColor(AppColors.textPrimary)
                    Text("\(completedTasks) / \(totalTasks)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    HStack(spacing: 12) {
                        miniStat("🎯", goal.excitedGoals.filter(\.isCompleted).count, goal.excitedGoals.count)
                        miniStat("💪", goal.stretchGoals.filter(\.isCompleted).count, goal.stretchGoals.count)
                        miniStat("✅", goal.tasks.filter(\.isCompleted).count, goal.tasks.count)
                    }
                }
            }
            .card()
        }
    }

    private func miniStat(_ icon: String, _ done: Int, _ total: Int) -> some View {
        HStack(spacing: 2) {
            Text(icon).font(.system(size: 10))
            Text("\(done)/\(total)")
                .font(.system(size: 10))
                .foregroundColor(done == total && total > 0 ? AppColors.success : AppColors.textSecondary)
        }
    }
}
