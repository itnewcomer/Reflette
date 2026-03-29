# Reflette

感情記録・振り返りiOSアプリ / Emotion tracking & reflection app for iOS

## 機能 / Features

- 📅 カレンダーベースの日次感情記録
- ⭐ 5段階の気分評価
- 🎭 36種類の感情選択（4カテゴリ × 9感情）
- 📊 月間・年間レポート（折れ線グラフ、分布バー、タグ×感情分析）
- 💡 インサイト自動生成（前期比較、タグ分析）
- 🔥 連続記録ストリーク
- 📈 感情ボキャブラリースコア
- 🎯 月間目標管理（Excited Goals / Stretch Goals / Tasks）
- ✉️ 自分への手紙
- 🔔 日次・月次・週次リマインダー
- 💾 JSONバックアップ/インポート
- 📖 科学的根拠に基づく記録ガイド
- 🌐 日本語 / English 対応

## 科学的根拠 / Scientific Evidence

本アプリの設計は以下の研究に基づいています：

- **Lieberman et al. (2007)** - 感情ラベリングによる扁桃体の鎮静化 (Cited by 2,118)
- **Pennebaker & Beall (1986)** - 筆記開示による心身の健康改善 (Cited by 3,812)
- **Kashdan, Barrett & McKnight (2015)** - 感情の粒度とストレス耐性 (Cited by 767)
- **Smyth (1998)** - 感情記録の効果に関するメタ分析 (Cited by 2,422)

## 必要環境 / Requirements

- iOS 17.0+ / macOS 14.0+ (Designed for iPad)
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## セットアップ / Setup

```bash
brew install xcodegen
xcodegen generate
open Reflette.xcodeproj
```

## プロジェクト構成 / Structure

```
Reflette/
├── Sources/          # Swiftソースファイル
├── Resources/        # Assets, Info.plist, Entitlements
├── Tests/            # Unit Tests
├── docs/             # プライバシーポリシー (GitHub Pages)
├── project.yml       # XcodeGen設定
└── .github/          # CI (GitHub Actions)
```

## ロードマップ / Roadmap

### v1.0 ✅ 初回リリース
- 感情記録・レポート・目標・ガイド
- インサイト自動生成
- バックアップ/エクスポート
- 日英対応
- Mac対応 (Designed for iPad)

### v1.1 🏥 HealthKit連携
- 睡眠時間 × 気分の相関分析
- 歩数 × 気分の相関分析
- 運動時間 × 気分の相関分析
- 散布図 + 相関係数の自動計算

### v1.2 📱 UX改善
- ウィジェット（今日の気分を素早く記録）
- Apple Watch対応
- ダークモード/ライトモード切り替え

### v2.0 🌍 マルチプラットフォーム
- Android版（Flutter）
- Windows/Linux版

### Future 🔮
- iCloud同期
- AI によるインサイト生成
- ソーシャル機能（匿名での感情共有）

## 依存ライブラリ / Dependencies

なし（外部依存ゼロ）

## ライセンス / License

MIT
