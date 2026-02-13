# 仕様書 — context-framework

version: 0.7
date: 2026-02-14
status: as-built

---

## 0. 目的・位置づけ

本書は `as_built/as_built_requirements.md`（要件定義書 v0.4）に定義された全要件に対する **技術仕様** を記述する。

- 本書は **as-built（実態記述）** である。
- 要件定義書（`as_built/as_built_requirements.md`）・実装計画書（`as_built/as_built_implementation_plan.md`）とトレーサブルである。
- `_handoff_check/` の内容を正（SSOT）として、本書はそれと整合する形で作成された。

---

## 1. ディレクトリ構造仕様

### SPEC-CF-DIR01: リポジトリレイアウト

```
context-framework/
├── .github/
│   └── workflows/
│       ├── ci-validate.yml      # 既存 CI バリデーション (REQ-CF-T04)
│       └── ciqa.yml             # ciqa フルパイプライン (REQ-CF-F07)
├── _handoff_check/              # SSOT 3ファイルバンドル (REQ-CF-T02)
│   ├── cf_handoff_prompt.md     # 引継ぎサマリ
│   ├── cf_update_runbook.md     # 運用マニュアル
│   └── cf_task_tracker_v5.md    # 進捗管理
├── WORKFLOW/                    # Gate 運用・プロセス定義 (REQ-CF-T01)
│   ├── GATES.md
│   ├── MODES_AND_TRIGGERS.md
│   ├── AUDIT.md
│   ├── BRANCHING.md
│   ├── SKILLS_INTEGRATION.md
│   ├── TRANSLATION_LAYER.md
│   └── TOOLING/
│       ├── COEXIST_3FILES.md
│       ├── INITIAL_SETTINGS.md
│       └── REPO_LOCK.md
├── ARTIFACTS/                   # Gate 成果物
│   ├── TASK_LISTS.md            # Gate A 成果物
│   ├── IMPLEMENTATION_PLAN.md   # Gate B 成果物
│   ├── WALKTHROUGH.md           # Gate C 成果物
│   ├── AUDIT_REPORT.md          # Gate D 成果物
│   ├── AUDIT_CHECKLIST.md       # Gate D 成果物
│   └── EXCEPTIONS.md            # 例外管理
├── rules/                       # ポリシー・ルーティング・SSOT 定義
│   ├── policy.json              # 分類スキーマ・リスク制御 (REQ-CF-S03)
│   ├── routes.yaml              # ルーティング定義 (REQ-CF-F02)
│   └── ssot_manifest.yaml       # SSOT マニフェスト (REQ-CF-F03)
├── controller/                  # Python controller (REQ-CF-F01)
│   └── main.py
├── tools/                       # Bash ユーティリティ (REQ-CF-F04)
│   ├── cf-ci-validate.sh
│   ├── cf-controller-smoke.sh
│   ├── cf-doctor.sh
│   ├── cf-guard.sh
│   ├── cf-log-index.sh
│   ├── cf-signature-report.sh
│   ├── cleanup-local-merged.sh
│   └── delete-remote-branch.sh
├── SKILLS/                      # 再利用 Skill (REQ-CF-F06)
│   ├── _registry.md
│   └── skill-template/
├── PROMPTS/                     # 役割別プロンプト (REQ-CF-F08)
│   ├── CODEX_CRAFTER.md
│   ├── CODEX_CIQA.md
│   ├── CHATGPT_ARCHITECT_ORCHESTRATOR.md
│   └── AUDITOR.md
├── LOGS/                        # 実行ログ・証跡 (REQ-CF-T03)
│   ├── INDEX.md                 # 自動生成インデックス
│   ├── ci/
│   ├── controller/
│   └── ctx-run/
├── TOOLING/                     # ビルド・リリースツール
│   └── ADAPTERS/                # アダプタテンプレート
│       ├── CLAUDE.template.md
│       ├── AGENTS.template.md
│       └── GEMINI.template.md
├── bin/                         # CLI ツール
│   ├── ctx-run
│   └── ctx-controller
├── vendor/                      # サードパーティ
├── CLAUDE.md                    # Claude 運用アダプタ (REQ-CF-F05)
├── AGENTS.md                    # Codex 運用アダプタ (REQ-CF-F05)
├── GEMINI.md                    # Gemini 運用アダプタ (REQ-CF-F05)
├── as_built/                    # as-built 文書
│   ├── as_built_requirements.md # 要件定義書
│   ├── as_built_spec.md         # 仕様書（本書）
│   └── as_built_implementation_plan.md # 実装計画書
├── CODEOWNERS                   # SSOT 保護 (REQ-CF-S07)
├── README.md                    # ブートストラップ文書
├── QUICK_START.md               # セットアップガイド
└── CHANGELOG.md                 # 変更履歴
```

- **対応要件**: REQ-CF-F01〜F08, REQ-CF-T01〜T04, REQ-CF-S06〜S07
- **実装状態**: 実装済み

---

## 2. 安全性仕様

### SPEC-CF-S01: SSOT 参照順序仕様

- **対応要件**: REQ-CF-S01
- **仕様**:
  1. 情報源の優先順位（上位が優先）:
     1. Charter（`CHARTER/*.md`）
     2. Mode（`WORKFLOW/MODES_AND_TRIGGERS.md`）
     3. Artifacts（`ARTIFACTS/*.md`）
     4. Skills（`SKILLS/**/*.md`）
  2. 運用アダプタ（CLAUDE.md, AGENTS.md, GEMINI.md）に参照順序を明記する。
  3. `ssot_manifest.yaml` の構造がこの優先順位を反映する（`charter` > `architect` > `skills`）。
- **実装状態**: 実装済み

### SPEC-CF-S02: リポジトリロック仕様

- **対応要件**: REQ-CF-S02
- **仕様**:
  1. `tools/cf-guard.sh` がリポジトリのロック・検証を担当する。
  2. Guard プロトコル: `_handoff_check/cf_update_runbook.md` §8 に定義。
  3. `WORKFLOW/TOOLING/REPO_LOCK.md` にロック機構の仕様を記載。
- **実装状態**: 実装済み

### SPEC-CF-S03: policy.json 仕様

- **対応要件**: REQ-CF-S03
- **仕様**:
  1. `rules/policy.json` の構造:
     - `version`: スキーマバージョン（現在 1）
     - `classification_schema`: 分類スキーマ（6 必須キー + `notes`, `risk_score`）
       - `intent`: verify / edit / add / delete / plan
       - `actor`: ubuntu / codex
       - `risk`: low / high
       - `needs_gonogo`: boolean
       - `context_profile`: ssot_only / ssot_charter / full
       - `output_format`: checklist / json / unified_diff
     - `risk_flags`: danger_ops / external_send / secrets / network
     - `banned`: phrases / paths
     - `limits`: max_output_chars / max_patch_lines / timeout_sec
     - `gate_c`: SoT 宣言・リンク・Skill 優先の正規表現
     - `prohibited_words`: 禁止操作文字列リスト
     - `dangerous_ops`: delete / overwrite / exfiltrate / force パターン
     - `require_gonogo_conditions`: risk_score_gte / hit_categories
  2. `additionalProperties: false` によりスキーマ外のキー注入を禁止。
- **実装状態**: 実装済み

### SPEC-CF-S04: Go/No-Go 判定仕様

- **対応要件**: REQ-CF-S04
- **仕様**:
  1. 判定条件（`require_gonogo_conditions`）:
     - `risk_score_gte: 8`（リスクスコア 8 以上で Go/No-Go 必須）
     - `hit_categories`: dangerous_ops / prohibited_words / risk_flags / banned のいずれかに該当
  2. `controller/main.py` がリクエスト分類時に評価する。
- **実装状態**: 実装済み

### SPEC-CF-S05: main 直コミット禁止仕様

- **対応要件**: REQ-CF-S05
- **仕様**:
  1. `WORKFLOW/BRANCHING.md`: 「main 直コミット禁止」を明記。
  2. `WORKFLOW/GATES.md`: 「PR経由」の運用で Gate コミットによるレビューと証跡を残す。
  3. 運用アダプタ: 「main への直接コミット（PR経由で反映すること）」を明記。
- **実装状態**: 実装済み

### SPEC-CF-S06: GitHub Actions セキュリティ仕様

- **対応要件**: REQ-CF-S06
- **仕様**:
  1. `ci-validate.yml`:
     - `permissions: contents: read`
     - SHA pin: `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11`
     - SHA pin: `actions/setup-python@0b93645e9fea7318ecaed2b359559ac225c90a2b`
     - SHA pin: `actions/upload-artifact@5d5d22a31266ced268874388b861e4b58bb5c2f3`
  2. `ciqa.yml`:
     - `permissions: contents: read, pull-requests: write`
     - SHA pin: `actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11`
     - SHA pin: `actions/upload-artifact@5d5d22a31266ced268874388b861e4b58bb5c2f3`
     - SHA pin: `actions/download-artifact@c850b930e6ba138125429b7e5c93fc707a7f8427`
- **実装状態**: 実装済み

### SPEC-CF-S07: CODEOWNERS 仕様

- **対応要件**: REQ-CF-S07
- **仕様**:
  1. `CODEOWNERS` ファイルの内容:
     ```
     /rules/ssot_manifest.yaml  @xxxMasahiro
     /rules/                    @xxxMasahiro
     /_handoff_check/           @xxxMasahiro
     /WORKFLOW/                 @xxxMasahiro
     ```
  2. SSOT パス・rules・_handoff_check・WORKFLOW への変更に必須レビューを設定。
- **実装状態**: 実装済み

---

## 3. 追跡性仕様

### SPEC-CF-T01: Gate A-D 進行管理仕様

- **対応要件**: REQ-CF-T01
- **仕様**:
  1. Gate A（Task Lists 合意）:
     - 成果物: `ARTIFACTS/TASK_LISTS.md`
     - Profile/Triggers を記入
     - コミット: `gate(A): scope + done definition`
  2. Gate B（Implementation Plan 合意）:
     - 成果物: `ARTIFACTS/IMPLEMENTATION_PLAN.md`
     - コミット: `gate(B): implementation plan locked`
  3. Gate C（Walkthrough 完走）:
     - 成果物: `ARTIFACTS/WALKTHROUGH.md`, `LOGS/` に実行ログ
     - Profile/Triggers と証跡の整合確認
     - コミット: `gate(C): walkthrough passed (logs attached)`
  4. Gate D（Audit 完了）:
     - 成果物: `ARTIFACTS/AUDIT_REPORT.md`, `ARTIFACTS/AUDIT_CHECKLIST.md`
     - 第三者視点で Evidence の整合性を監査
     - PASS/FAIL と最小修正案を返す
     - コミット: `gate(D): audit passed`
  5. main 反映後にタグを打つ（例: `v0.1.4-alpha.1`）
- **実装状態**: 実装済み

### SPEC-CF-T02: SSOT 3 ファイルバンドル仕様

- **対応要件**: REQ-CF-T02
- **仕様**:
  1. `ssot_manifest.yaml` の `ssot` キーで定義:
     ```yaml
     ssot:
       - "_handoff_check/cf_handoff_prompt.md"
       - "_handoff_check/cf_update_runbook.md"
       - "_handoff_check/cf_task_tracker_v5.md"
     ```
  2. 注: `ssot` はここでは「_handoff_check の 3 ファイル集合（bundle）」の意味であり、最上位 SSOT の意味ではない。
  3. `handoff_check_files` キーは将来用の明示キー（`ssot` と同値）。
- **実装状態**: 実装済み

### SPEC-CF-T03: 証跡ログ管理仕様

- **対応要件**: REQ-CF-T03
- **仕様**:
  1. `LOGS/` ディレクトリ構造:
     - `INDEX.md`: 自動生成インデックス（手動編集禁止）
     - `ci/`: CI 実行ログ
     - `controller/`: controller 実行ログ
     - `ctx-run/`: コンテキストランナーログ
  2. `tools/cf-log-index.sh`:
     - `cf_task_tracker_v5.md` から `INDEX.md` を自動生成
     - 実行: `./tools/cf-log-index.sh`
- **実装状態**: 実装済み

### SPEC-CF-T04: CI/CQ パイプライン統合仕様

- **対応要件**: REQ-CF-T04
- **仕様**:
  1. `ci-validate.yml`:
     - トリガー: `pull_request` + `push` (main)
     - 実行内容: `./tools/cf-ci-validate.sh`（rules/manifest/routes/policy 検証 + smoke test）
     - Python 3.11
     - 証跡: `LOGS/ci/*.log` をアーティファクトとしてアップロード
  2. `ciqa.yml`:
     - トリガー: `on: [push, pull_request]`（ブランチフィルタなし）
     - ジョブ順序: phase0 → lint → build → unit_test → cq → report + notify_failure
     - ciqa リポジトリを `CIQA_REF`（SHA pin）でチェックアウト
     - CF プロファイル存在確認（`ciqa/profiles/context-framework/profile.yml`）
     - 各ジョブで secrets スキャン + evidence アップロード
     - notify_failure: 失敗時に PR コメント投稿
- **実装状態**: 実装済み

### SPEC-CF-T05: Audit 証跡仕様

- **対応要件**: REQ-CF-T05
- **仕様**:
  1. Gate D 監査の Inputs（Evidence）:
     - `ARTIFACTS/TASK_LISTS.md`
     - `ARTIFACTS/IMPLEMENTATION_PLAN.md`
     - `ARTIFACTS/WALKTHROUGH.md`
     - `LOGS/`（CI/QA ログ、監査ログ、差分要約）
     - `meta/CHECKSUMS.sha256`（配布バンドルがある場合）
     - `ARTIFACTS/EXCEPTIONS.md`（例外がある場合）
  2. Outputs（Audit Artifacts）:
     - `ARTIFACTS/AUDIT_REPORT.md`
     - `ARTIFACTS/AUDIT_CHECKLIST.md`
     - `ARTIFACTS/EXCEPTIONS.md`（例外が必要な場合に追記）
  3. 判定ルール:
     - PASS: Evidence が揃い、重大な矛盾・未解決リスクがない
     - FAIL: Evidence 不足 / 重大な矛盾 / 重大リスク未解決 / ルール違反
     - FAIL 時は最小修正案と再監査条件を必ず返す
- **実装状態**: 実装済み

---

## 4. 運用仕様

### SPEC-CF-O01: ブランチ運用仕様

- **対応要件**: REQ-CF-O01
- **仕様**:
  1. ブランチ規約:
     - `main`: 常に安定。GO の無い変更は入れない
     - `wip/<version>`（例: `wip/v0.1.4`）: 作業ブランチ
  2. コミット規約:
     - `gate(A): ...` / `gate(B): ...` / `gate(C): ...` / `gate(D): ...`
     - `docs: ...`（軽微な文言修正）
     - `refactor: ...`（構成整理）
  3. 破壊的変更は必ず `CHANGELOG.md` に記録。
  4. main 反映後にタグを打つ。
- **実装状態**: 実装済み

### SPEC-CF-O02: 役割定義仕様

- **対応要件**: REQ-CF-O02
- **仕様**:
  1. 5 役割の定義:
     | 役割 | 責務 | 実装する? |
     |------|------|-----------|
     | Architect | 設計・整合性の前段チェック | ケースバイケース |
     | Crafter | 実装（追加/修正/削除） | する |
     | Orchestrator | タスク分解・横断調整・進行管理 | する |
     | CI/QA | 検証・ログ化・再現性の担保 | する |
     | Auditor | 監査・証跡・リスク指摘 | **しない** |
  2. 「Auditor は PR へ監査結果を返す。修正は Crafter/Orchestrator が行う。」（統一必須文言）
  3. 役割は Developer が初期設定ファイルで割り当てる:
     - `WORKFLOW/TOOLING/INITIAL_SETTINGS.md`
     - `.repo-id/agent_role_assignment.example.yaml`
- **実装状態**: 実装済み

### SPEC-CF-O03: Mode 運用仕様

- **対応要件**: REQ-CF-O03
- **仕様**:
  1. Mode 定義:
     | Mode | 目的 | 適用範囲 |
     |------|------|----------|
     | Lite | 最小コストで前進 | 小規模変更、影響限定 |
     | Standard | レビュー可能な証跡 | 複数ファイル変更、影響中程度 |
     | Strict | 監査/説明責任耐性 | 重大な変更（破壊的、セキュリティ等） |
  2. エスカレーション規則:
     - 既定: Lite
     - Triggers = Yes: Standard へ
     - 重大性が高い場合: Strict へ
  3. Gate との接続:
     - Gate A: Profile/Triggers を記入して合意
     - Gate B: Profile/Triggers を再確認（必要なら昇格）
     - Gate C: Profile/Triggers と証跡の整合を確認
     - Gate D: 監査結果と Evidence の整合を確認
- **実装状態**: 実装済み

---

## 5. 機能仕様

### SPEC-CF-F01: controller 仕様

- **対応要件**: REQ-CF-F01
- **仕様**:
  1. `controller/main.py`:
     - manifest（`ssot_manifest.yaml`）読込・パース
     - routes（`routes.yaml`）読込・パース
     - policy（`policy.json`）読込・バリデーション
     - 分類スキーマによるリクエスト分類
     - リスクスコアリング
     - Go/No-Go 判定
  2. controller は他のモジュール（tools, guard 等）とは独立して動作する。
- **実装状態**: 実装済み

### SPEC-CF-F02: routes.yaml 仕様

- **対応要件**: REQ-CF-F02
- **仕様**:
  1. `rules/routes.yaml` の構造:
     - intent に基づくルーティングルール
     - 5 標準ルート:
       | ルート名 | intent | 説明 |
       |----------|--------|------|
       | verify_readonly | verify | 読取専用検証 |
       | edit_docs | edit | ドキュメント編集 |
       | add_files | add | ファイル追加 |
       | delete_or_overwrite | delete | 削除・上書き（高リスク） |
       | plan_only | plan | 計画のみ |
     - デフォルトフォールバック: high risk, requires go/no-go
  2. ルートごとにリスクレベルとアクション定義を含む。
- **実装状態**: 実装済み

### SPEC-CF-F03: ssot_manifest.yaml 仕様

- **対応要件**: REQ-CF-F03
- **仕様**:
  1. カテゴリ定義:
     | カテゴリ | 内容 |
     |----------|------|
     | `ssot` | 3 ファイルバンドル（`_handoff_check/` の 3 ファイル） |
     | `handoff_check_files` | 将来用明示キー（ssot と同値） |
     | `charter` | `CHARTER/*.md` |
     | `architect` | `WORKFLOW/*.md` |
     | `skills` | `SKILLS/**/*.md` |
     | `projection` | CLAUDE.md, AGENTS.md, GEMINI.md |
     | `allow_read_prefix` | 公開読取ゾーン（_handoff_check/, CHARTER/, WORKFLOW/, SKILLS/, LOGS/） |
  2. 注: `ssot` キーは「_handoff_check の 3 ファイル集合（bundle）」の意味であり、フレームワーク全体の SSOT 最上位の意味ではない。
- **実装状態**: 実装済み

### SPEC-CF-F04: tools 仕様

- **対応要件**: REQ-CF-F04
- **仕様**:
  1. ツール一覧:
     | ツール | 機能 |
     |--------|------|
     | `cf-ci-validate.sh` | rules/manifest/routes/policy バリデーション + smoke test |
     | `cf-controller-smoke.sh` | controller smoke test |
     | `cf-doctor.sh` | Phase 0 診断（STEP-G003） |
     | `cf-guard.sh` | リポジトリロック・検証 |
     | `cf-log-index.sh` | LOGS/INDEX.md 自動生成（tracker から生成） |
     | `cf-signature-report.sh` | 署名/フィンガープリント報告 |
     | `cleanup-local-merged.sh` | マージ済みローカルブランチクリーンアップ |
     | `delete-remote-branch.sh` | リモートブランチ削除 |
  2. すべて `tools/` に配置し、実行権限を付与する。
- **実装状態**: 実装済み

### SPEC-CF-F05: 運用アダプタ仕様

- **対応要件**: REQ-CF-F05
- **仕様**:
  1. アダプタ 3 種:
     - `CLAUDE.md`: Claude Code 向け
     - `AGENTS.md`: OpenAI Codex 向け
     - `GEMINI.md`: Google Gemini 向け
  2. テンプレート: `TOOLING/ADAPTERS/` に各テンプレートを配置
  3. アダプタ共通構造:
     - 目的（対象エージェントに直接渡す運用アダプタ）
     - 役割（固定しない、Developer が割り当て）
     - SSOT 参照順（Charter → Mode → Artifacts → Skills）
     - やること（SSOT 参照、1 手ずつ指示）
     - やらないこと（SSOT の再定義、main 直接コミット）
     - 証跡・出力形式
     - ブランチ運用
     - チェックリスト
     - 統一必須文言
  4. アダプタは SSOT ではない（`WORKFLOW/TOOLING/COEXIST_3FILES.md`）。
- **実装状態**: 実装済み

### SPEC-CF-F06: Skills フレームワーク仕様

- **対応要件**: REQ-CF-F06
- **仕様**:
  1. `SKILLS/` ディレクトリ構造:
     - `_registry.md`: Skill レジストリ（一覧）
     - `skill-template/SKILL.md`: Skill テンプレート
     - 個別 Skill: `skill-XXX.md`
  2. `WORKFLOW/SKILLS_INTEGRATION.md` に統合仕様を記載。
  3. ツール非依存・アダプタ分離の原則。
- **実装状態**: 実装済み

### SPEC-CF-F07: CI/CQ ワークフロー仕様

- **対応要件**: REQ-CF-F07
- **仕様**:
  1. `ci-validate.yml`:
     - トリガー: `pull_request` + `push` (main)
     - ランナー: `ubuntu-latest`
     - ステップ:
       1. checkout（SHA pin）
       2. setup-python 3.11（SHA pin）
       3. `./tools/cf-ci-validate.sh` 実行
       4. LOGS/ci/ アーティファクトアップロード（SHA pin）
     - permissions: `contents: read`
  2. `ciqa.yml`:
     - トリガー: `on: [push, pull_request]`（ブランチフィルタなし）
     - ランナー: `ubuntu-24.04`
     - ジョブ構成（直列チェーン）:
       ```
       phase0 → lint → build → unit_test → cq → report + notify_failure
       ```
     - 各ジョブ共通:
       - CF リポジトリ checkout（target/）
       - ciqa リポジトリ checkout（ciqa/、CIQA_REF で SHA pin）
       - CIQA_REF プレースホルダ検証
       - 依存インストール（jq, uuid-runtime, shellcheck, yq, ajv-cli）
       - CF プロファイル存在確認
       - ciqa コマンド実行
       - secrets スキャン
       - evidence アーティファクトアップロード（retention-days: 30）
     - notify_failure:
       - 条件: `failure() && github.event_name == 'pull_request'`
       - evidence ダウンロード + PR コメント投稿
     - permissions: `contents: read`, `pull-requests: write`
- **実装状態**: 実装済み

### SPEC-CF-F08: PROMPTS 仕様

- **対応要件**: REQ-CF-F08
- **仕様**:
  1. 4 役割プロンプト:
     | ファイル | 対象役割 |
     |----------|----------|
     | `CODEX_CRAFTER.md` | Crafter（実装担当） |
     | `CODEX_CIQA.md` | CI/QA（検証担当） |
     | `CHATGPT_ARCHITECT_ORCHESTRATOR.md` | Architect/Orchestrator |
     | `AUDITOR.md` | Auditor（監査担当） |
  2. `PROMPTS/` に配置。
- **実装状態**: 実装済み

---

## 6. トレーサビリティ（REQ → SPEC）

| 要件 | 対応 SPEC | 備考 |
|------|-----------|------|
| REQ-CF-S01 (SSOT 参照順序) | SPEC-CF-S01 | |
| REQ-CF-S02 (リポジトリロック) | SPEC-CF-S02 | |
| REQ-CF-S03 (policy.json) | SPEC-CF-S03 | |
| REQ-CF-S04 (Go/No-Go) | SPEC-CF-S04 | |
| REQ-CF-S05 (main 直コミット禁止) | SPEC-CF-S05 | |
| REQ-CF-S06 (Actions セキュリティ) | SPEC-CF-S06 | SHA pin + permissions |
| REQ-CF-S07 (CODEOWNERS) | SPEC-CF-S07 | |
| REQ-CF-T01 (Gate A-D) | SPEC-CF-T01 | |
| REQ-CF-T02 (SSOT 3 ファイル) | SPEC-CF-T02 | |
| REQ-CF-T03 (証跡ログ) | SPEC-CF-T03 | |
| REQ-CF-T04 (CI/CQ 統合) | SPEC-CF-T04 | |
| REQ-CF-T05 (Audit 証跡) | SPEC-CF-T05 | |
| REQ-CF-O01 (ブランチ運用) | SPEC-CF-O01 | |
| REQ-CF-O02 (役割定義) | SPEC-CF-O02 | |
| REQ-CF-O03 (Mode 運用) | SPEC-CF-O03 | |
| REQ-CF-F01 (controller) | SPEC-CF-F01 | |
| REQ-CF-F02 (routes.yaml) | SPEC-CF-F02 | |
| REQ-CF-F03 (ssot_manifest) | SPEC-CF-F03 | |
| REQ-CF-F04 (tools) | SPEC-CF-F04 | |
| REQ-CF-F05 (アダプタ) | SPEC-CF-F05 | |
| REQ-CF-F06 (Skills) | SPEC-CF-F06 | |
| REQ-CF-F07 (CI/CQ WF) | SPEC-CF-F07 | |
| REQ-CF-F08 (PROMPTS) | SPEC-CF-F08 | |

---

## 7. 差分/未定義一覧

### SPEC-CF-D01: ciqa プロファイル詳細

- **対応**: REQ-CF-D01
- **状況**: ciqa リポジトリに `profiles/context-framework/profile.yml` を作成済み（strict モード、SSOT required、Gate 5 件）。ciqa.yml の各ジョブが参照するプロファイル存在確認ステップを通過可能。
- **影響度**: 解消済み

### SPEC-CF-D02: CIQA_REF 確定

- **対応**: —
- **状況**: ciqa.yml の `CIQA_REF` を ciqa リポジトリ最終コミット SHA（`4d31f397a44cb1bfb3f69631eacb9e17c636e907`）に確定済み。プレースホルダ検証ステップを通過可能。
- **影響度**: 解消済み

---

## 8. 変更履歴

- v0.7（2026-02-14 JST）: `.cfctx/` → `.repo-id/` リネーム。SPEC-CF-O02 の初期設定パス参照を更新。
- v0.6（2026-02-13 JST）: CODEX 三者整合監査 H-03/L-01 修正。SPEC-CF-D02: CIQA_REF を最終コミット SHA（`4d31f39`）に更新。参照要件定義書バージョンを v0.1→v0.3 に修正。
- v0.5（2026-02-13 JST）: CODEX H-03/H-04 解消。SPEC-CF-D01: ciqa プロファイル作成済みに更新。SPEC-CF-D02: CIQA_REF 確定済み（`954af28`）に更新。
- v0.4（2026-02-13 JST）: リポジトリ名ドリフト修正。タイトル・ディレクトリ構造図ルート・プロファイルパスの旧名 `cf-context-framework` を `context-framework` に統一（CODEX H-02/M-01 対応）。
- v0.3（2026-02-12 JST）: CODEX 再検証 F-05 修正。SPEC-CF-D01 のプロファイルパスを SPEC-CF-T04 と統一（`ciqa/profiles/cf-context-framework/profile.yml`）。
- v0.2（2026-02-12 JST）: CODEX 調査報告 F3/F4 修正。SPEC-CF-DIR01: _handoff_check/ 配下の存在しないサブディレクトリ（SPEC/, TOOLING/）を削除。SPEC-CF-T04/F07: ciqa.yml トリガー記述を実装と整合（`on: [push, pull_request]`）。SPEC-CF-T04: プロファイル確認パスを実装と整合（`ciqa/profiles/cf-context-framework/profile.yml`）。
- v0.1（2026-02-12 JST）: 初版作成。cf-context-framework の実装済み仕様を as-built として記述。ディレクトリ構造 1 件、安全性 7 件、追跡性 5 件、運用 3 件、機能 8 件、差分 2 件を策定。
