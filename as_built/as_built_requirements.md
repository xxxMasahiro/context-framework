# 要件定義書 — cf-context-framework

version: 0.1
date: 2026-02-12
status: as-built

---

## 0. 目的・位置づけ

本書は cf-context-framework の **実装済み要件（as-built requirements）** を記述する。

- 本書は **as-built（実態記述）** である。
- 対応する仕様書（`as_built/as_built_spec.md`）・実装計画書（`as_built/as_built_implementation_plan.md`）とトレーサブルである。
- `_handoff_check/` の内容を正（SSOT）として、本書はそれと整合する形で作成された。

---

## 1. スコープ

### 1.1 対象

- cf-context-framework リポジトリの構成・運用・CI/CQ 統合に関する要件
- Gate 進行管理（A → B → C → D）による品質保証プロセス
- SSOT 3 ファイルバンドル（`_handoff_check/`）による引継ぎ管理
- controller / policy / routes による分類・ルーティング
- GitHub Actions による CI/CQ パイプライン統合
- 運用アダプタ（CLAUDE.md / AGENTS.md / GEMINI.md）

### 1.2 非対象（Non-goals）

- CI/CQ 基盤（ciqa）自体の実装（別リポジトリで管理）
- controller（main.py）のロジック詳細変更
- vendor/ 配下のサードパーティコード変更

---

## 2. 用語定義

| 用語 | 定義 | 根拠 |
|------|------|------|
| **SSOT** | Single Source of Truth。本リポジトリでは `_handoff_check/` の 3 ファイルバンドルを指す（最上位 SSOT の意味ではない） | `ssot_manifest.yaml` |
| **Charter** | 最高憲章。情報源の最上位 | `CHARTER/*.md` |
| **Gate** | 品質保証の段階化単位（A/B/C/D） | `WORKFLOW/GATES.md` |
| **Mode** | 運用ルールの定義（Lite / Standard / Strict） | `WORKFLOW/MODES_AND_TRIGGERS.md` |
| **Profile** | 成果物内で Mode を記録するための記入欄（Mode と同義） | `WORKFLOW/MODES_AND_TRIGGERS.md` |
| **Triggers** | Standard 以上へのエスカレーション条件（Yes / No） | `WORKFLOW/MODES_AND_TRIGGERS.md` |
| **controller** | `controller/main.py`。分類・リスクスコアリング・Go/No-Go 判定を行う | `controller/main.py` |
| **policy.json** | 分類スキーマ・リスクフラグ・禁止語・危険操作パターンの定義 | `rules/policy.json` |
| **routes.yaml** | intent に基づくアクションルーティング定義 | `rules/routes.yaml` |
| **ssot_manifest.yaml** | SSOT バンドル・Charter・Architect・Skills・allow_read_prefix の定義 | `rules/ssot_manifest.yaml` |
| **ciqa** | 汎用 CI/CQ 基盤（別リポジトリ）。本リポジトリの CI/CQ パイプラインで使用 | 外部参照 |

---

## 3. 安全性要件（MUST）

### REQ-CF-S01: SSOT 参照順序

- **要件**: 情報源の参照・優先順位を以下のとおりとする:
  1. Charter（最高憲章）
  2. Mode（運用ルール）
  3. Artifacts（成果物）
  4. Skills（再利用手順）
- 矛盾発生時は上位情報源を優先する。
- **受入条件**: 運用アダプタ（CLAUDE.md 等）に参照順序が明記されている。
- **実装状態**: 実装済み
- **根拠**: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`

### REQ-CF-S02: リポジトリロック

- **要件**: `tools/cf-guard.sh` によるリポジトリロック機構を提供し、意図しない変更を防止する。
- **受入条件**: `cf-guard.sh` が実行可能で、ロック・検証機能が動作する。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/TOOLING/REPO_LOCK.md`

### REQ-CF-S03: policy.json による分類・リスク制御

- **要件**: `rules/policy.json` で以下を定義し、操作の安全性を制御する:
  - 分類スキーマ（intent, actor, risk, needs_gonogo, context_profile, output_format）
  - リスクフラグ（danger_ops, external_send, secrets, network）
  - 禁止語・禁止パス（banned phrases/paths）
  - 危険操作パターン（delete, overwrite, exfiltrate, force）
- **受入条件**: `policy.json` が上記の全セクションを含み、`controller/main.py` から参照される。
- **実装状態**: 実装済み
- **根拠**: `rules/policy.json`

### REQ-CF-S04: Go/No-Go 判定

- **要件**: リスクスコアが閾値（risk_score ≥ 8）以上、または hit_categories に該当する場合に Go/No-Go 判定を必須とする。
- **受入条件**: `policy.json` の `require_gonogo_conditions` が定義されており、controller が評価する。
- **実装状態**: 実装済み
- **根拠**: `rules/policy.json`

### REQ-CF-S05: main 直コミット禁止

- **要件**: `main` ブランチへの直接コミットを禁止し、PR 経由での変更を必須とする。
- **受入条件**: `WORKFLOW/BRANCHING.md` および `WORKFLOW/GATES.md` に明記されている。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/BRANCHING.md`, `WORKFLOW/GATES.md`

### REQ-CF-S06: GitHub Actions セキュリティ

- **要件**: CI ワークフローにおいて以下を遵守する:
  - `permissions` を最小権限に設定
  - サードパーティ Action は SHA pin で固定
- **受入条件**: `.github/workflows/ci-validate.yml` および `.github/workflows/ciqa.yml` が上記条件を満たす。
- **実装状態**: 実装済み
- **根拠**: `.github/workflows/ci-validate.yml`, `.github/workflows/ciqa.yml`

### REQ-CF-S07: CODEOWNERS による SSOT 保護

- **要件**: `CODEOWNERS` ファイルで SSOT パス（`rules/ssot_manifest.yaml`, `rules/`, `_handoff_check/`, `WORKFLOW/`）を保護し、必須レビューを設定する。
- **受入条件**: `CODEOWNERS` が存在し、上記パスに対してオーナーが設定されている。
- **実装状態**: 実装済み
- **根拠**: `CODEOWNERS`

---

## 4. 追跡性要件（MUST）

### REQ-CF-T01: Gate A-D 進行管理

- **要件**: 以下の Gate 進行管理プロセスを実施する:
  - Gate A: Task Lists 合意（スコープと Done 固定）
  - Gate B: Implementation Plan 合意（ファイル単位の差分計画固定）
  - Gate C: Walkthrough 完走（再現性のある検証 + 証跡）
  - Gate D: Audit 完了（第三者視点の Evidence 整合性監査）
- **受入条件**: `WORKFLOW/GATES.md` に Gate A-D が定義され、`ARTIFACTS/` に対応する成果物が存在する。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/GATES.md`, `WORKFLOW/AUDIT.md`

### REQ-CF-T02: SSOT 3 ファイルバンドル

- **要件**: `_handoff_check/` に以下の 3 ファイルを SSOT バンドルとして管理する:
  - `cf_handoff_prompt.md`（引継ぎサマリ）
  - `cf_update_runbook.md`（運用マニュアル）
  - `cf_task_tracker_v5.md`（進捗管理）
- `ssot_manifest.yaml` の `ssot` キーでバンドルを定義する。
- **受入条件**: 3 ファイルが `_handoff_check/` に存在し、`ssot_manifest.yaml` に登録されている。
- **実装状態**: 実装済み
- **根拠**: `rules/ssot_manifest.yaml`, `_handoff_check/`

### REQ-CF-T03: 証跡ログ管理

- **要件**: 実行ログを `LOGS/` に保存し、`LOGS/INDEX.md` を自動生成する。
- **受入条件**: `tools/cf-log-index.sh` で `LOGS/INDEX.md` が生成可能。
- **実装状態**: 実装済み
- **根拠**: `LOGS/INDEX.md`, `tools/cf-log-index.sh`

### REQ-CF-T04: CI/CQ パイプライン統合

- **要件**: GitHub Actions で CI/CQ パイプラインを実行し、検査結果を証跡として保存する:
  - `ci-validate.yml`: 既存の CI バリデーション（rules/manifest/routes/policy 検証）
  - `ciqa.yml`: 汎用 CI/CQ 基盤によるフルパイプライン（phase0 → lint → build → unit_test → cq → report）
- **受入条件**: 両ワークフローが push/PR トリガーで自動実行される。
- **実装状態**: 実装済み
- **根拠**: `.github/workflows/ci-validate.yml`, `.github/workflows/ciqa.yml`

### REQ-CF-T05: Audit 証跡（Gate D）

- **要件**: Gate D 監査で以下の Evidence を参照し、PASS/FAIL と最小修正案を記録する:
  - `ARTIFACTS/TASK_LISTS.md`, `IMPLEMENTATION_PLAN.md`, `WALKTHROUGH.md`
  - `LOGS/`（実行ログ、差分）
  - `ARTIFACTS/EXCEPTIONS.md`（例外がある場合）
- **受入条件**: `ARTIFACTS/AUDIT_REPORT.md` および `ARTIFACTS/AUDIT_CHECKLIST.md` が更新される。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/AUDIT.md`

---

## 5. 運用要件（MUST）

### REQ-CF-O01: PR 経由のブランチ運用

- **要件**: 以下のブランチ運用を遵守する:
  - `main`: 常に安定。GO の無い変更は入れない
  - `wip/<version>`: 作業ブランチ
  - Gate A/B/C でコミットを切る
  - PR 経由で `main` へ反映
- **受入条件**: `WORKFLOW/BRANCHING.md` に記載されており、運用アダプタにも明記されている。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/BRANCHING.md`, `WORKFLOW/GATES.md`

### REQ-CF-O02: 役割定義

- **要件**: 以下の 5 役割を定義し、運用アダプタ経由で各エージェントに割り当て可能とする:
  - Architect: 設計・整合性の前段チェック
  - Crafter: 実装（追加/修正/削除）
  - Orchestrator: タスク分解・横断調整・進行管理
  - CI/QA: 検証・ログ化・再現性の担保
  - Auditor: 監査・証跡・リスク指摘（実装はしない）
- **受入条件**: 運用アダプタ（CLAUDE.md 等）に役割一覧が記載されている。
- **実装状態**: 実装済み
- **根拠**: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`

### REQ-CF-O03: Mode 運用（Lite / Standard / Strict）

- **要件**: 変更の重大性に応じて Mode をエスカレーションする:
  - Lite: 最小コスト（小規模変更）
  - Standard: 証跡付き（複数ファイル変更）
  - Strict: 監査耐性（高リスク変更）
- Triggers = Yes の場合は Standard 以上へエスカレーション。
- **受入条件**: `WORKFLOW/MODES_AND_TRIGGERS.md` に定義されている。
- **実装状態**: 実装済み
- **根拠**: `WORKFLOW/MODES_AND_TRIGGERS.md`

---

## 6. 機能要件（MUST/SHOULD）

### REQ-CF-F01: controller（main.py）

- **要件**: `controller/main.py` で以下の機能を提供する:
  - manifest / routes / policy の読込・バリデーション
  - 分類スキーマによるリクエスト分類
  - リスクスコアリング・Go/No-Go 判定
- **受入条件**: `controller/main.py` が存在し、上記機能が実装されている。
- **実装状態**: 実装済み
- **根拠**: `controller/main.py`

### REQ-CF-F02: routes.yaml ルーティング

- **要件**: `rules/routes.yaml` で intent に基づくアクションルーティングを定義する:
  - verify_readonly, edit_docs, add_files, delete_or_overwrite, plan_only の 5 標準ルート
  - デフォルトフォールバック（high risk, requires go/no-go）
- **受入条件**: `routes.yaml` が 5 標準ルートとフォールバックを含む。
- **実装状態**: 実装済み
- **根拠**: `rules/routes.yaml`

### REQ-CF-F03: ssot_manifest.yaml

- **要件**: `rules/ssot_manifest.yaml` で以下のカテゴリを定義する:
  - `ssot`: 3 ファイルバンドル
  - `handoff_check_files`: 将来用明示キー（ssot と同値）
  - `charter`: Charter ドキュメント
  - `architect`: Workflow ドキュメント
  - `skills`: Skill 定義
  - `projection`: 運用アダプタ（CLAUDE.md, AGENTS.md, GEMINI.md）
  - `allow_read_prefix`: 公開読取ゾーン
- **受入条件**: `ssot_manifest.yaml` が上記全カテゴリを含む。
- **実装状態**: 実装済み
- **根拠**: `rules/ssot_manifest.yaml`

### REQ-CF-F04: tools（ユーティリティ群）

- **要件**: 以下のツールを `tools/` に提供する:
  - `cf-ci-validate.sh`: rules/manifest/routes/policy バリデーション + smoke test
  - `cf-controller-smoke.sh`: controller smoke test
  - `cf-doctor.sh`: Phase 0 診断（STEP-G003）
  - `cf-guard.sh`: リポジトリロック・検証
  - `cf-log-index.sh`: LOGS/INDEX.md 自動生成
  - `cf-signature-report.sh`: 署名/フィンガープリント報告
- **受入条件**: 各ツールが `tools/` に存在し、実行可能である。
- **実装状態**: 実装済み
- **根拠**: `tools/`

### REQ-CF-F05: 運用アダプタシステム

- **要件**: エージェント向けの運用アダプタを以下の構成で提供する:
  - `CLAUDE.md`: Claude Code 向け
  - `AGENTS.md`: OpenAI Codex 向け
  - `GEMINI.md`: Google Gemini 向け
  - テンプレート: `TOOLING/ADAPTERS/` に各テンプレートを配置
- アダプタは SSOT の再定義をせず、参照リンク中心で記述する。
- **受入条件**: 3 アダプタとテンプレートが存在し、SSOT 参照順序が明記されている。
- **実装状態**: 実装済み
- **根拠**: `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `TOOLING/ADAPTERS/`

### REQ-CF-F06: Skills フレームワーク

- **要件**: 再利用可能な Skills を `SKILLS/` に管理し、レジストリ（`_registry.md`）で一覧化する。
- **受入条件**: `SKILLS/_registry.md` が存在し、Skill テンプレートが提供されている。
- **実装状態**: 実装済み
- **根拠**: `SKILLS/`, `WORKFLOW/SKILLS_INTEGRATION.md`

### REQ-CF-F07: CI/CQ ワークフロー統合

- **要件**: GitHub Actions で以下の 2 ワークフローを提供する:
  - `ci-validate.yml`: 既存バリデーション（SHA pin、permissions 設定済み）
  - `ciqa.yml`: ciqa フルパイプライン（phase0 → lint → build → unit_test → cq → report + notify_failure）
- **受入条件**: 両ワークフローが `.github/workflows/` に存在し、SHA pin・permissions が設定されている。
- **実装状態**: 実装済み
- **根拠**: `.github/workflows/ci-validate.yml`, `.github/workflows/ciqa.yml`

### REQ-CF-F08: PROMPTS（役割別プロンプト）

- **要件**: `PROMPTS/` に役割別のプロンプトを配置する:
  - `CODEX_CRAFTER.md`: Crafter 役割
  - `CODEX_CIQA.md`: CI/QA 役割
  - `CHATGPT_ARCHITECT_ORCHESTRATOR.md`: Architect/Orchestrator 役割
  - `AUDITOR.md`: Auditor 役割
- **受入条件**: 4 プロンプトが `PROMPTS/` に存在する。
- **実装状態**: 実装済み
- **根拠**: `PROMPTS/`

---

## 7. トレーサビリティ（REQ → 根拠）

| 要件 | 根拠 | 備考 |
|------|------|------|
| REQ-CF-S01 (SSOT 参照順序) | CLAUDE.md, AGENTS.md, GEMINI.md | |
| REQ-CF-S02 (リポジトリロック) | WORKFLOW/TOOLING/REPO_LOCK.md | |
| REQ-CF-S03 (policy.json) | rules/policy.json | |
| REQ-CF-S04 (Go/No-Go) | rules/policy.json | |
| REQ-CF-S05 (main 直コミット禁止) | WORKFLOW/BRANCHING.md | |
| REQ-CF-S06 (Actions セキュリティ) | .github/workflows/ | SHA pin + permissions |
| REQ-CF-S07 (CODEOWNERS) | CODEOWNERS | |
| REQ-CF-T01 (Gate A-D) | WORKFLOW/GATES.md | |
| REQ-CF-T02 (SSOT 3 ファイル) | ssot_manifest.yaml | |
| REQ-CF-T03 (証跡ログ) | tools/cf-log-index.sh | |
| REQ-CF-T04 (CI/CQ 統合) | .github/workflows/ | |
| REQ-CF-T05 (Audit 証跡) | WORKFLOW/AUDIT.md | |
| REQ-CF-O01 (ブランチ運用) | WORKFLOW/BRANCHING.md | |
| REQ-CF-O02 (役割定義) | CLAUDE.md, AGENTS.md, GEMINI.md | |
| REQ-CF-O03 (Mode 運用) | WORKFLOW/MODES_AND_TRIGGERS.md | |
| REQ-CF-F01 (controller) | controller/main.py | |
| REQ-CF-F02 (routes.yaml) | rules/routes.yaml | |
| REQ-CF-F03 (ssot_manifest) | rules/ssot_manifest.yaml | |
| REQ-CF-F04 (tools) | tools/ | |
| REQ-CF-F05 (アダプタ) | CLAUDE.md 等 + TOOLING/ADAPTERS/ | |
| REQ-CF-F06 (Skills) | SKILLS/ | |
| REQ-CF-F07 (CI/CQ WF) | .github/workflows/ | |
| REQ-CF-F08 (PROMPTS) | PROMPTS/ | |

---

## 8. 差分/未定義一覧

### REQ-CF-D01: ciqa プロファイル

- **内容**: ciqa.yml で参照する CF 用プロファイルは ciqa リポジトリ側で管理される。CF リポジトリ側での定義は不要。
- **影響度**: 低
- **提案**: ciqa リポジトリで `profiles/cf-context-framework/` を作成する。

### REQ-CF-D02: ブランチ保護ルール

- **内容**: GitHub リポジトリ設定でのブランチ保護ルール（必須チェック、必須レビュー数）は UI 設定であり、リポジトリ内ファイルには含まれない。
- **影響度**: 低
- **提案**: 運用開始時に GitHub Settings で設定する。

---

## 9. 変更履歴

- v0.1（2026-02-12 JST）: 初版作成。cf-context-framework の実装済み要件を as-built として記述。安全性 7 件、追跡性 5 件、運用 3 件、機能 8 件、差分 2 件を策定。
