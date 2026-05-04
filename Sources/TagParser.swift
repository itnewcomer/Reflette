import Foundation

/// テキストからハッシュタグ（#で始まる単語）を抽出する共通ユーティリティ。
/// EmotionRecord と RecordEditorView で同じパターンを使うため一元化。
enum TagParser {
    private static let regex = try? NSRegularExpression(pattern: "#[\\p{L}0-9_]+")

    static func extract(from text: String) -> [String] {
        guard let regex else { return [] }
        let nsrange = NSRange(text.startIndex..., in: text)
        return regex.matches(in: text, range: nsrange).compactMap {
            Range($0.range, in: text).map { String(text[$0]) }
        }
    }
}
