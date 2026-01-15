# Implementation Plan（実装計画 / Antigravity準拠）
> 対象：`cf-dist_v0.1.3_complete.zip` を入力として、最終的に `cf-dist_v0.1.4_complete.zip` を生成する。
> ここでは「どのファイルをどう変えるか」を **ファイル単位**で明確化し、レビュー可能にする。

## Profile / Triggers
- 定義：`../WORKFLOW/MODES_AND_TRIGGERS.md`
- Profile:
- Triggers: Yes | No
- Reason:

## 0. 変更方針（最重要）
- **追加 + 最小修正**で完結させる（既存のPLAN/DESIGN_NOTE/RISK_ASSESSMENTは残す）
- Antigravity 3点セットは **新テンプレとして標準搭載**し、参照ドキュメントと役割定義で “公式成果物” にする

---

## 1. 変更対象（コンポーネント）
### A) Core（正本）
- 入力：`cf-core_v0.1.3.zip`
- 出力：`cf-core_v0.1.4.zip`

### B) Sample Product（workframe）
- 入力：`cf-wf-sample-product_v0.1.1.zip`
- 出力：`cf-wf-sample-product_v0.1.2.zip`
- 変更対象：`workframe/core`（vendored core）

### C) Dist（封筒）
- 入力：`cf-dist_v0.1.3_complete.zip`
- 出力：`cf-dist_v0.1.4_complete.zip`

---

## 2. 追加（Add）
### Core / workframe-core 共通で追加するテンプレ（3点セット）
追加先：
- `artifacts/templates/`

追加ファイル：
- `TASK_LISTS.md`（Task Lists：タスク分割）
- `IMPLEMENTATION_PLAN.md`（Implementation Plan：実装計画）
- `WALKTHROUGH.md`（Walkthrough：検証）

> これらの“ファイル内容（ひな形）”は `support/templates/` に同梱。  
> 作業時は **同一内容を core と vendored core にコピー**する。

---

## 3. 修正（Modify）
### Core / workframe-core 共通
- `docs/reference/ARTIFACTS.md`
  - Templates セクションへ3点セットを追記
- `artifacts/README.md`
  - templates/ の説明に3点セットを追記
- `protocols/roles/ORCHESTRATOR.md`
  - 成果物に `TASK_LISTS.md` を追記
- `protocols/roles/ARCHITECT.md`
  - 主要成果物に `IMPLEMENTATION_PLAN.md` を追記
- `protocols/roles/CI_QA.md`
  - 成果物に `WALKTHROUGH.md` を追記（検証＋証跡の基準）
- `protocols/roles/CRAFTER.md`（推奨）
  - Walkthrough への協力（差分・検証手順）を追記

### バージョン/メタ更新（Core）
- `VERSION`：`0.1.3` → `0.1.4`
- `CHANGELOG.md`：`[0.1.4-alpha] - 2026-01-14` を追記
- `_meta/BUILD_INFO.json`：`version` と `built_at` 更新
- `_meta/MANIFEST.yaml`：`version` と `built_at` 更新
- `_meta/REPO_TREE.txt`：ツリー更新（テンプレ3点の反映）
- `_meta/CHECKSUMS.sha256`：再生成

### バージョン/メタ更新（Sample Product）
- ルート `VERSION`：`0.1.1` → `0.1.2`
- ルート `CHANGELOG.md`：`0.1.2` 追記
- `WORKFRAME_MANIFEST.yaml`：
  - `workframe_version` と `product.version` を `0.1.2` へ
  - `vendored.core_zip.name` を `cf-core_v0.1.4.zip` へ
  - `vendored.core_zip.version` を `0.1.4` へ
  - `vendored.core_zip.sha256` を **新しいcore zipのsha256**へ更新
  - `built_at` 更新
- ルート `_meta/*`：version/built_at/checksums 更新
- `workframe/core/VERSION`：`0.1.3` → `0.1.4`
- `workframe/core/CHANGELOG.md`：`[0.1.4-alpha] - 2026-01-14` 追記
- `workframe/core/_meta/*`：core同様に更新

---

## 4. 変更内容（テキスト修正の“具体”）
### 4.1 `docs/reference/ARTIFACTS.md`（追記行）
Templates に以下を追加：
- `artifacts/templates/TASK_LISTS.md`：Task Lists（タスク分割 / Antigravity互換）
- `artifacts/templates/IMPLEMENTATION_PLAN.md`：Implementation Plan（実装計画 / Antigravity互換）
- `artifacts/templates/WALKTHROUGH.md`：Walkthrough（検証 / Antigravity互換）

### 4.2 `artifacts/README.md`（追記例）
- templates/：設計メモ、計画、リスク評価、**Task Lists / Implementation Plan / Walkthrough** など

### 4.3 roles（追記例：成果物セクション）
- Orchestrator：`TASK_LISTS.md` を追加
- Architect：`IMPLEMENTATION_PLAN.md` を追加
- CI/QA：`WALKTHROUGH.md` を追加（Evidence: diff/screenshot/recording を推奨）
- Crafter：Walkthroughの入力（差分説明/検証手順）への協力を明記

---

## 5. 生成物（最終アウトプット）
- `cf-core_v0.1.4.zip`
- `cf-wf-sample-product_v0.1.2.zip`
- `cf-dist_v0.1.4_complete.zip`

---

## 6. リスクと緩和策（抜粋）
- リスク：coreとvendored coreで差分が出る  
  緩和：テンプレファイルは同梱の `support/templates/` をコピーし、差分ゼロにする
- リスク：チェックサム/マニフェスト更新漏れ  
  緩和：Walkthroughの検証で `_meta` 必須項目を全てチェックする
- リスク：zipのルートディレクトリ名が変わって壊れる  
  緩和：既存zipのルート名を維持（coreは `cf-core/`、sample-productは `cf-wf-sample-product_v0.1.2/`）
