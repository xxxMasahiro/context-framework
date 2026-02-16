# 実装計画書 — context-framework

version: 1.6
date: 2026-02-17
status: as-built

---

## 0. 目的・位置づけ

本書は `as_built/as_built_requirements.md`（要件定義書 v0.8）および `as_built/as_built_spec.md`（仕様書 v0.15）に完全準拠した **実装計画** を記述する。

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
  - `tools/ci-validate.sh`: rules/manifest/routes/policy バリデーション + smoke test
  - `tools/controller-smoke.sh`: controller smoke test
  - `tools/doctor.sh`: Phase 0 診断
  - `tools/guard.sh`: リポジトリロック・検証
  - `tools/log-index.sh`: LOGS/INDEX.md 自動生成
  - `tools/signature-report.sh`: 署名/フィンガープリント報告
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
  - `_handoff_check/handoff_prompt.md`
  - `_handoff_check/update_runbook.md`
  - `_handoff_check/task_tracker.md`
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
  - permissions: ワークフローレベル `contents: read`、`notify_failure` ジョブレベル `pull-requests: write`（最小権限原則）
- **完了条件**: ciqa.yml が `.github/workflows/` に存在し、全ジョブが定義されている
- **注記**: CIQA_REF は ciqa リポジトリ最終コミット SHA `9da152c0d8a916b501b20e9bc210f55894d03cf9` に確定済み
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
| REQ-CF-I01 (Template Repository) | SPEC-CF-I01 | PI-6 |
| REQ-CF-I02 (3 層分類) | SPEC-CF-I02 | PI-1 |
| REQ-CF-I03 (app/ 統合) | SPEC-CF-I03 | PI-1 |
| REQ-CF-I04 (初期化フロー) | SPEC-CF-I04 | PI-4 |
| REQ-CF-I05 (upstream 同期) | SPEC-CF-I05 | PI-5 |
| REQ-CF-I06 (ssot_manifest 拡張) | SPEC-CF-I06 | PI-3 |
| REQ-CF-I07 (.gitignore 拡張) | SPEC-CF-I07 | PI-3 |
| REQ-CF-I08 (ciqa.yml 簡素化) | SPEC-CF-I08 | PI-2 |
| REQ-CF-I09 (ciqa profile) | SPEC-CF-I09 | PI-1 |
| REQ-CF-I10 (CIQA_REF pin) | SPEC-CF-I10 | PI-2, PI-4 |
| REQ-CF-I11 (Gate 適用境界) | SPEC-CF-I11 | PI-4, PI-7 |

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

--- インスタンス化フェーズ ---

CPI-1 (profile-file) → CPI-2 (reusable workflow) → CPI-3 (ciqa as-built)
                                                          │
PI-0 (Baseline) ←────────────────────────────────────────┘
 ├── PI-1 (layer_manifest + .ciqa/ + app/)
 │    ├── PI-3 (ssot_manifest + .gitignore)
 │    │    └── PI-4 (init-instance) ← PI-1, PI-2, PI-3
 │    └── PI-5 (sync-upstream) ← PI-1
 ├── PI-2 (ciqa.yml simplification) ← CPI-2
 └── PI-6 (Template Repository) ← PI-1〜PI-5
      └── PI-7 (as-built + WORKFLOW + verification) ← PI-1〜PI-6
```

---

## 14a. インスタンス化フェーズ（CPI-1〜CPI-3 + PI-0〜PI-7）

### ciqa 側前提条件

#### IMPL-CPI-1: ローカルプロファイル検出

- **対応 SPEC**: SPEC-F17
- **対応 REQ**: REQ-F17
- **実装内容**:
  - `core/profile_engine.sh` の `resolve_profile()` に `--profile-file` 優先順位を追加
  - `ciqa` CLI に `--profile-file <path>` オプションを追加
  - `core/runner.sh` の `run_pipeline()` に `profile_file_path` パラメータ追加
  - `tests/test_profile_local.sh` テスト追加
- **状態**: 実装済み

#### IMPL-CPI-2: reusable workflow 作成

- **対応 SPEC**: SPEC-F18
- **対応 REQ**: REQ-F18
- **実装内容**:
  - `.github/workflows/pipeline.yml` を新規作成（`workflow_call` トリガー）
  - 入力: `profile-path`（デフォルト: `.ciqa/profile.yml`）、`ciqa-ref`（必須）
  - 7 jobs 構成: phase0 → lint → build → unit_test → cq → report + notify_failure
  - SHA pinned actions、permissions 構造保全
  - 既存 `ci.yml` は不変（REQ-O03 保全）
- **状態**: 実装済み

#### IMPL-CPI-3: ciqa as-built 更新

- **実装内容**:
  - ciqa as-built 3 文書に CPI-1/CPI-2 を反映（REQ-F17/F18, SPEC-F17/F18）
  - CPI-3 コミット SHA: `8133a15765246f3cbccebe4210c306a5e17114cf`
- **状態**: 実装済み

### CF 側実装

#### IMPL-PI-0: Baseline 固定

- **実装内容**:
  - CF as-built 版数記録: req v0.6 / spec v0.12 / impl v1.3
  - ciqa as-built 版数記録: req v0.9 / spec v0.16 / impl v0.12（CPI-3 後: v0.10 / v0.17 / v0.13）
- **状態**: 実装済み

#### IMPL-PI-1: 非破壊基盤追加

- **対応 SPEC**: SPEC-CF-I02, SPEC-CF-I03, SPEC-CF-I09
- **対応 REQ**: REQ-CF-I02, REQ-CF-I03, REQ-CF-I09
- **実装内容**:
  - `layer_manifest.yaml` 作成（L1/L2/L3 パス分類、resolution_rules 付き）
  - `.ciqa/profile.yml` テンプレート作成（実値: `context-framework` / `xxxMasahiro`）
  - `app/.gitkeep` 作成
- **状態**: 実装済み

#### IMPL-PI-2: ciqa.yml 簡素化

- **対応 SPEC**: SPEC-CF-I08, SPEC-CF-I10
- **対応 REQ**: REQ-CF-I08, REQ-CF-I10
- **実装内容**:
  - 現行 559 行 → ~15 行の reusable workflow caller に置換
  - `uses: xxxMasahiro/ciqa/.github/workflows/pipeline.yml@dc2b906f27a652b532f2e235f32b68c756b0725f`
  - `with: profile-path: .ciqa/profile.yml`、`ciqa-ref: "dc2b906..."`
- **状態**: 実装済み

#### IMPL-PI-3: ssot_manifest + .gitignore 拡張

- **対応 SPEC**: SPEC-CF-I06, SPEC-CF-I07
- **対応 REQ**: REQ-CF-I06, REQ-CF-I07
- **実装内容**:
  - `rules/ssot_manifest.yaml` に `layer_manifest: "layer_manifest.yaml"` 追加
  - `.gitignore` に `# App (L3)` セクション追加（12 パターン）
  - `parse_manifest()` 後方互換検証済み
- **状態**: 実装済み

#### IMPL-PI-4: init-instance 実装

- **対応 SPEC**: SPEC-CF-I04
- **対応 REQ**: REQ-CF-I04
- **実装内容**:
  - `bin/init-instance` 新規作成（8 Steps、~175 行）
  - CLI: `--project <name> --owner <owner> [--ciqa-ref <40hex>]`
  - 外部ツール不要（gh CLI 不要）、冪等性確保
- **状態**: 実装済み

#### IMPL-PI-5: sync-upstream 実装

- **対応 SPEC**: SPEC-CF-I05
- **対応 REQ**: REQ-CF-I05
- **実装内容**:
  - `bin/sync-upstream` 新規作成（~126 行）
  - `main` ブランチ実行禁止、L1 パスのみ同期
  - `--dry-run` オプション
- **状態**: 実装済み

#### IMPL-PI-6: Template Repository 設定

- **対応 SPEC**: SPEC-CF-I01
- **対応 REQ**: REQ-CF-I01
- **実装内容**: GitHub UI で Settings → General → 「Template repository」有効化（手動実施）
- **状態**: 実装済み

#### IMPL-PI-7: as-built + WORKFLOW 更新 + 最終検証

- **対応 REQ**: REQ-CF-I01〜I11
- **実装内容**:
  - CF as-built 3 文書に I01-I11 反映
  - WORKFLOW 3 文書に app/ 免除条件追記
  - トレーサビリティ表完全化
  - 最終版数確定
- **状態**: 実装済み

---

## 14. 変更履歴

- v1.6（2026-02-17 JST）: IMPL-PI-2 の CIQA_REF SHA を `8133a15...` → `dc2b906...` に更新。参照仕様書 v0.14 → v0.15（CODEX HIGH 対応）。
- v1.5（2026-02-17 JST）: 参照要件定義書/仕様書バージョンを v0.7/v0.13 → v0.8/v0.14 に更新（REQ-CF-I08 行数記述修正との整合）。
- v1.4（2026-02-16 JST）: インスタンス化フェーズ追加。§14a 新設（CPI-1〜CPI-3 + PI-0〜PI-7）。§12 トレーサビリティ表に 11 行追加。§13 依存関係グラフ更新。参照 v0.7 / v0.13。
- v1.3（2026-02-15 JST）: IMPL-CF-P8-01 ciqa.yml 権限記述を実装準拠に修正。`pull-requests: write` が `notify_failure` ジョブレベルであることを明記。参照 v0.6 / v0.12（CODEX F-02 対応）。
- v1.2（2026-02-15 JST）: vendor/ 廃止（ZIP 運用完全終了）。互換シンボリックリンク 9 本撤去（完全ゼロ化）。参照 v0.6 / v0.11。
- v1.1（2026-02-14 JST）: `cf_` / `cf-` プレフィックス除去。全ツール名・SSOT ファイル名参照を新名に更新。参照 v0.5 / v0.10。
- v1.0（2026-02-14 JST）: CIQA_REF を `4d31f39` → `9da152c`（3層リネーム後コミット）に更新。参照仕様書 v0.8 → v0.9（CODEX F-01 対応）。
- v0.9（2026-02-14 JST）: 参照仕様書バージョンを v0.7 → v0.8 に更新（CODEX F-02 対応。仕様書との文書間トレーサビリティ整合）。
- v0.8（2026-02-14 JST）: `.cfctx/` → `.repo-id/` リネーム。身元確認ディレクトリ参照を更新。
- v0.7（2026-02-13 JST）: CODEX 再監査 M-01 修正。参照仕様書バージョンを v0.5→v0.6 に更新（仕様書と同期）。
- v0.6（2026-02-13 JST）: CODEX 三者整合監査 H-03/L-01 修正。CIQA_REF を最終コミット SHA（`4d31f39`）に更新。参照要件定義書/仕様書バージョンを v0.1→v0.3 / v0.3→v0.5 に修正。
- v0.5（2026-02-13 JST）: CODEX H-03 解消。IMPL-CF-P8-01 の CIQA_REF 注記をプレースホルダから確定済み SHA に更新。
- v0.4（2026-02-13 JST）: リポジトリ名ドリフト修正。タイトルの旧名 `cf-context-framework` を `context-framework` に統一（CODEX H-02/M-01 対応）。
- v0.3（2026-02-12 JST）: CODEX 再検証 F-04 修正。冒頭の参照仕様書バージョンを v0.1 → v0.3 に更新（実態と整合）。
- v0.2（2026-02-12 JST）: CODEX 調査報告 F2 修正。IMPL-CF-P10-01 成果物パスを実態と整合（`as_built/` プレフィックス追加）。
- v0.1（2026-02-12 JST）: 初版作成。cf-context-framework の実装計画を as-built として記述。10 フェーズ・15 実装タスクを策定。REQ↔SPEC↔IMPL の完全トレーサビリティを確保。
