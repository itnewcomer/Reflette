import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp) private var items: [Item]
    @State private var appState = AppState()
    @AppStorage("hasSeenGuide") private var hasSeenGuide = false
    @State private var showGuide = false
    @State private var showFirstRecord = false

    var ratingsForDates: [Date: Int] {
        // 同日複数記録の平均値
        var grouped: [Date: [Int]] = [:]
        for item in items {
            let day = Calendar.current.startOfDay(for: item.timestamp)
            grouped[day, default: []].append(item.rating)
        }
        return grouped.mapValues { ratings in
            ratings.reduce(0, +) / ratings.count
        }
    }

    private let tabs: [(icon: String, labelJa: String, labelEn: String)] = [
        ("calendar", "カレンダー", "Calendar"),
        ("chart.bar.fill", "レポート", "Report"),
        ("arrow.trianglehead.2.clockwise", "振り返り", "Reflect"),
        ("gearshape.fill", "設定", "Settings"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            // コンテンツ
            Group {
                switch appState.selectedTab {
                case 0:
                    HomeCalendarView(
                        appState: appState,
                        ratingsForDates: ratingsForDates,
                        items: items
                    )
                case 1:
                    ReportView(
                        selectedDate: $appState.selectedDate,
                        ratingsForDates: ratingsForDates,
                        items: items
                    )
                case 2:
                    GoalView(
                        selectedDate: $appState.selectedDate,
                        ratingsForDates: ratingsForDates,
                        items: items,
                        emotionDict: emotionDict
                    )
                case 3:
                    SettingsView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // 自作タブバー
            HStack {
                ForEach(0..<tabs.count, id: \.self) { i in
                    Button {
                        appState.selectedTab = i
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: tabs[i].icon)
                                .font(.system(size: 18))
                            Text(L10n.current == .ja ? tabs[i].labelJa : tabs[i].labelEn)
                                .font(.system(size: 9))
                        }
                        .foregroundColor(appState.selectedTab == i ? AppColors.accent : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 4)
            .background(AppColors.background)
        }
        .background(AppColors.background)
        .ignoresSafeArea(edges: .bottom)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showGuide) {
            GuideView {
                showFirstRecord = true
            }
        }
        .sheet(isPresented: $showFirstRecord) {
            NavigationStack {
                RecordEditorView(
                    selectedDate: $appState.selectedDate,
                    items: items,
                    onComplete: { showFirstRecord = false }
                )
            }
        }
        .onAppear {
            if !hasSeenGuide {
                showGuide = true
                hasSeenGuide = true
            }
        }
    }
}
