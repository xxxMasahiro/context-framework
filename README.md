# Context Framework (Bootstrap) for cf-dist v0.1.4

このZIPは **`cf-dist_v0.1.4_procedure_antigravity-3artifacts`（手順書ZIP）** を“唯一の拠り所”として、
**PR無し（ただしブランチ運用＋Gateコミット）**で安全に作業を進めるための **コンテキストフレームワーク一式**です。

- 想定：あなた（開発者）が **GO/STOP**、ChatGPTが **Architect + Orchestrator**、Codexが **Crafter + CI/QA**
- 主作業：Markdown（追加/修正/削除）
- 成果物：`cf-dist_v0.1.4_complete.zip`（最終配布物）を作るための編集・検証・証跡管理

---

## 0. まず最初に読むもの

1. `QUICK_START.md`
2. `WORKFLOW/GATES.md`
3. `PROMPTS/`（Codexに貼るプロンプト一式）

---

## 1. どこに“真実”があるか（Source of Truth）

### A. 手順書ZIP（ベースライン・不変）
`vendor/cf-dist_v0.1.4_procedure_antigravity-3artifacts/`  
ここに **オリジナルZIP** と **展開済み**があります。

> 原則：ここは **変更しない**（必要な場合のみ、Architect相談→Developer GO）

### B. 作業用アーティファクト（ここを更新する）
`ARTIFACTS/`  
Gate管理（Task Lists / Implementation Plan / Walkthrough）を **作業用に運用**する場所です。

### C. 実装用テンプレ（ここが“材料”）
`TEMPLATES/`  
最終的に `cf-core` などへ取り込まれる本文（Markdown等）の **作業用テンプレ**です。

---

## 2. 運用ルール（最小）

- **main直コミット禁止**
- 作業は `wip/v0.1.4` ブランチで行う
- **Gateごとにコミットを切る**
  - Gate A：Task Lists 合意
  - Gate B：Implementation Plan 合意
  - Gate C：Walkthrough 完走（ログ付き）

---

## 3. このZIPに入っているもの（概要）

- `ARTIFACTS/`：作業用3アーティファクト（更新していく）
- `TEMPLATES/`：実装用テンプレ（更新していく）
- `WORKFLOW/`：Gate運用、ブランチ・コミット規約
- `PROMPTS/`：Codex用（Crafter/CI）貼り付けプロンプト
- `LOGS/`：検証ログや証跡を置く場所
- `vendor/`：手順書ZIP（オリジナル＋展開済み）

更新履歴は `CHANGELOG.md` に残します。

---

## 4. 日付
生成日：2026年1月14日

---

## 5. 入力ZIP（v0.1.3）

このフレームワークZIPには、ビルド元となる **`cf-dist_v0.1.3_complete.zip`** を同梱しています。

- 置き場所：`vendor/inputs/cf-dist_v0.1.3_complete.zip`
- 目的：`cf-dist_v0.1.4_complete.zip` を再現可能に生成するための“入力（ベースライン）”

> 原則：入力ZIPは変更しません（必要ならArchitect相談→Developer GO）
