import SwiftUI
import SwiftData

struct BackupData: Codable {
    let exportDate: Date
    let items: [BackupItem]
}

struct BackupItem: Codable {
    let timestamp: Date
    let rating: Int
    let memoText: String
    let emotions: [String]
    let emotionNotes: [String: String]
    let tags: [String]
    let emotionTags: [String: [String]]
}

struct BackupView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Item.timestamp) private var items: [Item]
    @State private var showImporter = false
    @State private var alertMessage: String? = nil
    @State private var showRestoreConfirm = false
    @State private var pendingURL: URL? = nil

    var body: some View {
        Section(header: Text(L10n.backup)) {
            Button {
                exportData()
            } label: {
                Label(L10n.exportData, systemImage: "square.and.arrow.up")
            }

            Button {
                showImporter = true
            } label: {
                Label(L10n.importData, systemImage: "square.and.arrow.down")
            }

            Text(L10n.current == .ja ? "記録数: \(items.count)件" : "\(items.count) records")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .fileImporter(isPresented: $showImporter, allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                pendingURL = url
                showRestoreConfirm = true
            case .failure(let error):
                alertMessage = "\(L10n.fileSelectError): \(error.localizedDescription)"
            }
        }
        .alert(L10n.restoreConfirm, isPresented: $showRestoreConfirm) {
            Button(L10n.restoreButton) {
                if let url = pendingURL { importData(from: url) }
            }
            Button(L10n.cancel, role: .cancel) {}
        } message: {
            Text(L10n.restoreMessage)
        }
        .errorAlert($alertMessage)
    }

    private func exportData() {
        let backupItems = items.map { item in
            BackupItem(
                timestamp: item.timestamp,
                rating: item.rating,
                memoText: item.memoText,
                emotions: item.emotions,
                emotionNotes: item.emotionNotes,
                tags: item.tags,
                emotionTags: item.emotionTags
            )
        }
        let backup = BackupData(exportDate: Date(), items: backupItems)

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(backup)

            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let filename = "Reflette_\(formatter.string(from: Date())).json"

            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
            try data.write(to: tempURL)

            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = windowScene.windows.first?.rootViewController {
                root.present(activityVC, animated: true)
            }
        } catch {
            alertMessage = "\(L10n.exportFailed): \(error.localizedDescription)"
        }
    }

    private func importData(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            alertMessage = L10n.fileAccessDenied
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let backup = try decoder.decode(BackupData.self, from: data)

            var imported = 0
            for backupItem in backup.items {
                let exists = items.contains {
                    Calendar.current.isDate($0.timestamp, inSameDayAs: backupItem.timestamp)
                }
                if !exists {
                    let newItem = Item(
                        timestamp: backupItem.timestamp,
                        rating: backupItem.rating,
                        memoText: backupItem.memoText
                    )
                    newItem.emotionRecords = backupItem.emotions.map { emotion in
                        EmotionRecord(emotionName: emotion, note: backupItem.emotionNotes[emotion] ?? "")
                    }
                    modelContext.insert(newItem)
                    imported += 1
                }
            }
            try modelContext.save()
            alertMessage = L10n.importSuccess(imported, backup.items.count - imported)
        } catch {
            alertMessage = "\(L10n.importFailed): \(error.localizedDescription)"
        }
    }
}
