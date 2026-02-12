# 実装計画書 — cf-context-framework

version: 0.3
date: 2026-02-12
status: as-built

---

## 0. 目的・位置づけ

本書は `as_built/as_built_requirements.md`（要件定義書 v0.1）および `as_built/as_built_spec.md`（仕様書 v0.3）に完全準拠した **実装計画** を記述する。

- 本書は **as-built（実態記述）** である。
- 要件定義書（`as_built/as_built_requirements.md`）・仕様書（`as_built/as_built_spec.md`）とトレーサブルである。
- `_handoff_check/` の内容を正（SSOT）として、本書はそれと整合する形で作成された。

### 0.1 前提条件

- フレームワーク言語: Python（controller）+ Bash（tools, CI/CQ）
- 実行環境: Ubuntu（GitHub Actions `ubuntu-24.04` / `ubuntu-latest`）
- CI/CQ 基盤: ciqa（別リポジトリ、SHA pin で参照）
- バージョン管理: Git + GitHub（PR 経由運用）

### 0.2 実装原則

1. **SSOT 参照順序**（REQ-CF-S01）: Charter → Mode → Artifacts → Skills
2. **main 直コミット禁止**（REQ-CF-S05）: PR 経由で反映
3. **Gate 進行管理**（REQ-CF-T01）: A → B → C → D の段階的品質保証
4. **証跡必須**（REQ-CF-T03, REQ-CF-T05）: LOGS/ に実行ログ、ARTIFACTS/ に監査結果
5. **CI/CQ 統合**（REQ-CF-T04）: ci-validate + ciqa パイプライン

---

## 1. 実装フェーズ概要

| Phase | 名称 | 内容 | 対応 SPEC | 依存 |
|-------|------|------|-----------|------|
| P1 | 基盤構成 | ディレクトリ構造・rules 定義 | DIR01, F02, F03 | なし |
| P2 | controller | main.py・分類・リスク判定 | F01, S03, S04 | P1 |
| P3 | tools | guard, doctor, ci-validate 等 | F04, S02 | P1 |
| P4 | Gate 運用 | WORKFLOW, ARTIFACTS 定義 | T01, T05, O01, O03 | P1 |
| P5 | アダプタ | CLAUDE/AGENTS/GEMINI + テンプレート | F05, S01, O02 | P4 |
| P6 | Skills | Skills フレームワーク・レジストリ | F06 | P4 |
| P7 | PROMPTS | 役割別プロンプト | F08 | P4, P5 |
| P8 | CI/CQ 統合 | ci-validate.yml + ciqa.yml | F07, S06, T04 | P3 |
| P9 | SSOT 保護 | CODEOWNERS + ブランチ保護 | S07, S05 | P8 |
| P10 | as-built 文書 | 要件/仕様/実装計画書 | — | P1-P9 |

---

## 2. Phase 1: 基盤構成

### IMPL-CF-P1-01: ディレクトリ構造の構築

- **対応 SPEC**: SPEC-CF-DIR01
- **対応 REQ**: REQ-CF-F01〜F08
- **成果物**: SPEC-CF-DIR01 に定義されたディレクトリ構造
- **完了条件**: 全ディレクトリが存在し、各サブディレクトリに必要なファイルが配置されている
- **状態**: 実装済み

### IMPL-CF-P1-02: rules 定義ファイルの作成

- **対応 SPEC**: SPEC-CF-F02, SPEC-CF-F03, SPEC-CF-S03
- **対応 REQ**: REQ-CF-F02, REQ-CF-F03, REQ-CF-S03
- **成果物**:
  - `rules/policy.json`（分類スキーマ・リスク制御）
  - `rules/routes.yaml`（ルーティング定義）
  - `rules/ssot_manifest.yaml`（SSOT マニフェスト）
- **完了条件**: 3 ファイルが `rules/` に存在し、controller から参照可能
- **状態**: 実装済み

---

## 3. Phase 2: controller

### IMPL-CF-P2-01: controller/main.py 実装

- **対応 SPEC**: SPEC-CF-F01, SPEC-CF-S03, SPEC-CF-S04
- **対応 REQ**: REQ-CF-F01, REQ-CF-S03, REQ-CF-S04
- **実装内容**:
  - manifest / routes / policy の読込・パース
  - 分類スキーマによるリクエスト分類
  - リスクスコアリング
  - Go/No-Go 判定（risk_score ≥ 8）
- **完了条件**: controller が policy.json を読込み、分類・リスク判定が動作する
- **状態**: 実装済み

---

## 4. Phase 3: tools

### IMPL-CF-P3-01: Bash ユーティリティ群の実装

- **対応 SPEC**: SPEC-CF-F04, SPEC-CF-S02
- **対応 REQ**: REQ-CF-F04, REQ-CF-S02
- **成果物**:
  - `tools/cf-ci-validate.sh`: rules/manifest/routes/policy バリデーション + smoke test
  - `tools/cf-controller-smoke.sh`: controller smoke test
  - `tools/cf-doctor.sh`: Phase 0 診断
  - `tools/cf-guard.sh`: リポジトリロック・検証
  - `tools/cf-log-index.sh`: LOGS/INDEX.md 自動生成
  - `tools/cf-signature-report.sh`: 署名/フィンガープリント報告
  - `tools/cleanup-local-merged.sh`: マージ済みブランチクリーンアップ
  - `tools/delete-remote-branch.sh`: リモートブランチ削除
- **完了条件**: 全ツールが実行可能で、各機能が動作する
- **状態**: 実装済み

---

## 5. Phase 4: Gate 運用

### IMPL-CF-P4-01: WORKFLOW 定義

- **対応 SPEC**: SPEC-CF-T01, SPEC-CF-O01, SPEC-CF-O03
- **対応 REQ**: REQ-CF-T01, REQ-CF-O01, REQ-CF-O03
- **成果物**:
  - `WORKFLOW/GATES.md`: Gate A/B/C/D 定義
  - `WORKFLOW/MODES_AND_TRIGGERS.md`: Mode（Lite/Standard/Strict）定義
  - `WORKFLOW/AUDIT.md`: Gate D 監査手順
  - `WORKFLOW/BRANCHING.md`: ブランチ運用規約
  - `WORKFLOW/SKILLS_INTEGRATION.md`: Skills 統合仕様
  - `WORKFLOW/TRANSLATION_LAYER.md`: 翻訳レイヤー
  - `WORKFLOW/TOOLING/`: ツール関連文書
- **完了条件**: Gate A-D の進行管理プロセスが文書化されている
- **状態**: 実装済み

### IMPL-CF-P4-02: ARTIFACTS 成果物テンプレート

- **対応 SPEC**: SPEC-CF-T01, SPEC-CF-T05
- **対応 REQ**: REQ-CF-T01, REQ-CF-T05
- **成果物**:
  - `ARTIFACTS/TASK_LISTS.md`（Gate A）
  - `ARTIFACTS/IMPLEMENTATION_PLAN.md`（Gate B）
  - `ARTIFACTS/WALKTHROUGH.md`（Gate C）
  - `ARTIFACTS/AUDIT_REPORT.md`（Gate D）
  - `ARTIFACTS/AUDIT_CHECKLIST.md`（Gate D）
  - `ARTIFACTS/EXCEPTIONS.md`（例外管理）
- **完了条件**: 全成果物テンプレートが `ARTIFACTS/` に存在する
- **状態**: 実装済み

### IMPL-CF-P4-03: SSOT 3 ファイルバンドル

- **対応 SPEC**: SPEC-CF-T02
- **対応 REQ**: REQ-CF-T02
- **成果物**:
  - `_handoff_check/cf_handoff_prompt.md`
  - `_handoff_check/cf_update_runbook.md`
  - `_handoff_check/cf_task_tracker_v5.md`
- **完了条件**: 3 ファイルが `_handoff_check/` に存在し、`ssot_manifest.yaml` に登録されている
- **状態**: 実装済み

---

## 6. Phase 5: アダプタ

### IMPL-CF-P5-01: 運用アダプタ作成

- **対応 SPEC**: SPEC-CF-F05, SPEC-CF-S01, SPEC-CF-O02
- **対応 REQ**: REQ-CF-F05, REQ-CF-S01, REQ-CF-O02
- **成果物**:
  - `CLAUDE.md`: Claude Code 向けアダプタ
  - `AGENTS.md`: OpenAI Codex 向けアダプタ
  - `GEMINI.md`: Google Gemini 向けアダプタ
  - `TOOLING/ADAPTERS/CLAUDE.template.md`
  - `TOOLING/ADAPTERS/AGENTS.template.md`
  - `TOOLING/ADAPTERS/GEMINI.template.md`
- **完了条件**: 3 アダプタ + 3 テンプレートが存在し、SSOT 参照順序・役割定義・統一必須文言を含む
- **状態**: 実装済み

---

## 7. Phase 6: Skills

### IMPL-CF-P6-01: Skills フレームワーク構築

- **対応 SPEC**: SPEC-CF-F06
- **対応 REQ**: REQ-CF-F06
- **成果物**:
  - `SKILLS/_registry.md`
  - `SKILLS/skill-template/SKILL.md`
- **完了条件**: レジストリとテンプレートが存在する
- **状態**: 実装済み

---

## 8. Phase 7: PROMPTS

### IMPL-CF-P7-01: 役割別プロンプト作成

- **対応 SPEC**: SPEC-CF-F08
- **対応 REQ**: REQ-CF-F08
- **成果物**:
  - `PROMPTS/CODEX_CRAFTER.md`
  - `PROMPTS/CODEX_CIQA.md`
  - `PROMPTS/CHATGPT_ARCHITECT_ORCHESTRATOR.md`
  - `PROMPTS/AUDITOR.md`
- **完了条件**: 4 プロンプトが `PROMPTS/` に存在する
- **状態**: 実装済み

---

## 9. Phase 8: CI/CQ 統合

### IMPL-CF-P8-01: ci-validate.yml セキュリティ強化

- **対応 SPEC**: SPEC-CF-S06, SPEC-CF-T04
- **対応 REQ**: REQ-CF-S06, REQ-CF-T04
- **実装内容**:
  - `permissions: contents: read` 追加
  - 全 Action を SHA pin に固定:
    - checkout@b4ffde65f46336ab88eb53be808477a3936bae11
    - setup-python@0b93645e9fea7318ecaed2b359559ac225c90a2b
    - upload-artifact@5d5d22a31266ced268874388b861e4b58bb5c2f3
- **完了条件**: permissions と SHA pin が設定されている
- **状態**: 実装済み

### IMPL-CF-P8-02: ciqa.yml 新規作成

- **対応 SPEC**: SPEC-CF-F07, SPEC-CF-T04
- **対応 REQ**: REQ-CF-F07, REQ-CF-T04
- **実装内容**:
  - 7 ジョブ構成: phase0, lint, build, unit_test, cq, report, notify_failure
  - 直列チェーン: phase0 → lint → build → unit_test → cq → report
  - CIQA_REF による ciqa リポジトリ SHA pin
  - CF プロファイル存在確認
  - 各ジョブ: 依存インストール + ciqa 実行 + secrets スキャン + evidence アップロード
  - notify_failure: 失敗時 PR コメント投稿
  - permissions: `contents: read`, `pull-requests: write`
- **完了条件**: ciqa.yml が `.github/workflows/` に存在し、全ジョブが定義されている
- **注記**: CIQA_REF はプレースホルダ（ciqa リポジトリ初回コミット後に確定）
- **状態**: 実装済み

---

## 10. Phase 9: SSOT 保護

### IMPL-CF-P9-01: CODEOWNERS 作成

- **対応 SPEC**: SPEC-CF-S07
- **対応 REQ**: REQ-CF-S07
- **成果物**: `CODEOWNERS`
- **内容**:
  ```
  /rules/ssot_manifest.yaml  @xxxMasahiro
  /rules/                    @xxxMasahiro
  /_handoff_check/           @xxxMasahiro
  /WORKFLOW/                 @xxxMasahiro
  ```
- **完了条件**: CODEOWNERS が存在し、SSOT パスにオーナーが設定されている
- **状態**: 実装済み

### IMPL-CF-P9-02: PR ワークフロー文書統一

- **対応 SPEC**: SPEC-CF-S05, SPEC-CF-O01
- **対応 REQ**: REQ-CF-S05, REQ-CF-O01
- **実装内容**:
  - README.md: 「PR無し」→「PR経由」
  - QUICK_START.md: 「PR無し運用」→「PR経由運用」、「FF merge推奨」→「PR経由でマージ」
  - WORKFLOW/GATES.md: 「PR無し」→「PR経由」
  - WORKFLOW/BRANCHING.md: 「PRを使わない」→「PR経由」
  - AGENTS.md, CLAUDE.md, GEMINI.md: 「PRなし」→「PR経由で反映すること」
  - 3 テンプレート: 同様の修正
- **完了条件**: リポジトリ全体で「PR無し」「PRなし」「PRを使わない」が 0 件
- **状態**: 実装済み

---

## 11. Phase 10: as-built 文書

### IMPL-CF-P10-01: as-built 3 文書作成

- **対応 SPEC**: —（本書自体が成果物）
- **対応 REQ**: —
- **成果物**:
  - `as_built/as_built_requirements.md`: 要件定義書
  - `as_built/as_built_spec.md`: 仕様書
  - `as_built/as_built_implementation_plan.md`: 実装計画書（本書）
- **完了条件**: 3 文書が存在し、REQ↔SPEC↔IMPL のトレーサビリティが確保されている
- **状態**: 実装済み

---

## 12. トレーサビリティ（REQ → SPEC → IMPL）

| 要件 | 対応 SPEC | 対応 IMPL |
|------|-----------|-----------|
| REQ-CF-S01 (SSOT 参照順序) | SPEC-CF-S01 | P5-01 |
| REQ-CF-S02 (リポジトリロック) | SPEC-CF-S02 | P3-01 |
| REQ-CF-S03 (policy.json) | SPEC-CF-S03 | P1-02 |
| REQ-CF-S04 (Go/No-Go) | SPEC-CF-S04 | P2-01 |
| REQ-CF-S05 (main 直コミット禁止) | SPEC-CF-S05 | P9-02 |
| REQ-CF-S06 (Actions セキュリティ) | SPEC-CF-S06 | P8-01, P8-02 |
| REQ-CF-S07 (CODEOWNERS) | SPEC-CF-S07 | P9-01 |
| REQ-CF-T01 (Gate A-D) | SPEC-CF-T01 | P4-01, P4-02 |
| REQ-CF-T02 (SSOT 3 ファイル) | SPEC-CF-T02 | P4-03 |
| REQ-CF-T03 (証跡ログ) | SPEC-CF-T03 | P3-01 |
| REQ-CF-T04 (CI/CQ 統合) | SPEC-CF-T04 | P8-01, P8-02 |
| REQ-CF-T05 (Audit 証跡) | SPEC-CF-T05 | P4-01, P4-02 |
| REQ-CF-O01 (ブランチ運用) | SPEC-CF-O01 | P4-01, P9-02 |
| REQ-CF-O02 (役割定義) | SPEC-CF-O02 | P5-01 |
| REQ-CF-O03 (Mode 運用) | SPEC-CF-O03 | P4-01 |
| REQ-CF-F01 (controller) | SPEC-CF-F01 | P2-01 |
| REQ-CF-F02 (routes.yaml) | SPEC-CF-F02 | P1-02 |
| REQ-CF-F03 (ssot_manifest) | SPEC-CF-F03 | P1-02 |
| REQ-CF-F04 (tools) | SPEC-CF-F04 | P3-01 |
| REQ-CF-F05 (アダプタ) | SPEC-CF-F05 | P5-01 |
| REQ-CF-F06 (Skills) | SPEC-CF-F06 | P6-01 |
| REQ-CF-F07 (CI/CQ WF) | SPEC-CF-F07 | P8-01, P8-02 |
| REQ-CF-F08 (PROMPTS) | SPEC-CF-F08 | P7-01 |

---

## 13. 依存関係グラフ

```
P1 (基盤構成)
 ├── P2 (controller)
 ├── P3 (tools)
 │    └── P8 (CI/CQ 統合)
 │         └── P9 (SSOT 保護)
 └── P4 (Gate 運用)
      ├── P5 (アダプタ)
      ├── P6 (Skills)
      └── P7 (PROMPTS)

P10 (as-built 文書) ← P1-P9 全完了後
```

---

## 14. 変更履歴

- v0.3（2026-02-12 JST）: CODEX 再検証 F-04 修正。冒頭の参照仕様書バージョンを v0.1 → v0.3 に更新（実態と整合）。
- v0.2（2026-02-12 JST）: CODEX 調査報告 F2 修正。IMPL-CF-P10-01 成果物パスを実態と整合（`as_built/` プレフィックス追加）。
- v0.1（2026-02-12 JST）: 初版作成。cf-context-framework の実装計画を as-built として記述。10 フェーズ・15 実装タスクを策定。REQ↔SPEC↔IMPL の完全トレーサビリティを確保。
