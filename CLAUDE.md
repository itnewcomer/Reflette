# Memento（Reflette）

感情・振り返り記録アプリ。日々の感情をトラッキングし、自己理解を深める。

## アプリ概要

- **ターゲット**: 自己理解・メンタルケアに関心がある人
- **コンセプト**: 感情マトリクス × 振り返りカレンダー
- **主な機能**: 感情記録、月次レポート、目標管理、週次サマリー、セルフコンパッション

## 技術スタック

- Swift / SwiftUI
- SwiftData（永続化）
- XcodeGen（`project.yml` からプロジェクト生成）
- `L10n.swift` でローカライズ管理

## ファイル構成

```
Sources/
  RefletteApp.swift          # エントリポイント
  AppColors.swift            # カラーパレット
  AppState.swift             # グローバル状態
  Models.swift               # SwiftDataモデル
  L10n.swift                 # ローカライズ
  Item.swift                 # 基本データ型
  ContentView.swift          # メインナビゲーション
  HomeCalendarView.swift     # ホームカレンダー
  RefletteCalendarView.swift # 振り返りカレンダー
  RecordEditorView.swift     # 記録編集
  EmotionMatrixView.swift    # 感情マトリクス
  EmotionGridView.swift      # 感情グリッド
  EmotionSummaryView.swift   # 感情サマリー
  InsightView.swift          # インサイト
  GoalView.swift             # 目標
  GoalProgressView.swift     # 目標進捗
  ReportView.swift           # レポート
  MonthlyLineChartView.swift # 月次グラフ
  YearlyLineChartView.swift  # 年次グラフ
  DistributionBarView.swift  # 分布バー
  WeeklySummaryScheduler.swift # 週次通知
  SelfCompassionView.swift   # セルフコンパッション
  LetterComposeView.swift    # 手紙作成
  GuideView.swift            # ガイド
  SettingsView.swift         # 設定
  BackupView.swift           # バックアップ
  // UI Components
  CollapsibleSection.swift
  ActivityTagView.swift
  DayRule.swift / DayRulePicker.swift
  MonthSelector.swift
  RatingScaleView.swift
  StarRatingView.swift
  TimeSlot.swift
  ErrorAlert.swift
Resources/
docs/
```

## 注意事項

- Xcodeプロジェクト名は `Reflette.xcodeproj`（フォルダ名は `Memento`）
- XcodeGen使用: 変更後は `xcodegen generate`
- コミットに `Co-Authored-By:` 行は入れない

## モデル分担（Ops / Sonnet）

このプロジェクトは Opus（Ops）と Sonnet を役割分担して進める。

- **Opus（メイン）の担当**:
  - 設計・アーキテクチャ判断
  - レビュー（コード／UX／Mac対応／パフォーマンス）
  - 難所のデバッグ、再現性の低い不具合の調査
  - リファクタの方針決め
- **Sonnet（サブエージェント）の担当**:
  - 仕様が確定した実装タスク
  - 軽微なリファクタ、命名修正、ローカライズ追加
  - 単純な置換・配線作業
- **運用**:
  - Opus は実装の前にまず方針を提示し、確定したら `Agent`（subagent_type=`general-purpose` か `Explore`）経由で Sonnet に投げる
  - Sonnet に渡すプロンプトには「対象ファイル＋行番号、変更内容、終了条件」を明記する
  - Sonnet が戻ってきたら Opus が必ず差分をレビューしてからユーザーに報告する

## タスク管理（GitHub Issues）

セッションを跨いで残るタスク・将来やること・リリース前の確認項目は `gh issue create` で GitHub Issue 化する。会話の中だけで管理しない（忘れる）。

- **Issue化する対象**
  - レビューで挙がった "今すぐ直さない" 項目（リファクタ・技術負債・改善案）
  - リリース前の動作確認チェックリスト（チェックボックス付き、全部チェックで Close）
  - バグだが優先度低めで次回まとめて対応するもの
- **本文に含める**: 問題 / 影響 / 修正案 / 関連ファイル（行番号 + シンボル名を併記。コード変更で行はズレる前提）
- **ラベル**: `bug` / `enhancement` を使い分け
- **一覧確認**: `gh issue list --repo itnewcomer/Memento`
