# CI/QA 実装計画（CIQA Implementation Plan）

## 0. 目的

ciqa_requirements.md および ciqa_spec.md に従い、CI/QA レイヤーを段階的に実装する。
各フェーズは独立して検証可能な単位とし、フェーズ間の依存関係を明示する。

---

## 1. 変更ファイル一覧

### 1.1 新規作成

| # | ファイルパス | 説明 | Phase |
|---|---|---|---|
| N1 | `docs/ciqa/ciqa_requirements.md` | CI/QA 要件定義 | 0 |
| N2 | `docs/ciqa/ciqa_spec.md` | CI/QA 仕様 | 0 |
| N3 | `docs/ciqa/ciqa_implementation_plan.md` | CI/QA 実装計画（本ファイル）| 0 |
| N4 | `tasks/ciqa_task_tracker.md` | CI/QA タスク管理表 | 0 |
| N5 | `config/ciqa.conf` | CI/QA 設定ファイル | 1 |
| N6 | `scripts/lib/ciqa_common.sh` | CI/QA 共通ヘルパー関数 | 1 |
| N7 | `scripts/ciqa_runner.sh` | CI/QA 実行器（メインエントリ）| 1 |
| N8 | `scripts/lib/ciqa_checks/cq_tracker.sh` | CQ-TRK: トラッカー整合性 | 1 |
| N9 | `scripts/lib/ciqa_checks/cq_evidence.sh` | CQ-EVC: Evidence chain | 1 |
| N10 | `scripts/lib/ciqa_checks/cq_ssot.sh` | CQ-SSOT: SSOT ドリフト | 1 |
| N11 | `scripts/lib/ciqa_checks/cq_docs.sh` | CQ-DOC: ドキュメント整合 | 2 |
| N12 | `scripts/lib/ciqa_checks/cq_lint.sh` | CQ-LINT: スクリプト品質 | 2 |
| N13 | `scripts/lib/ciqa_checks/cq_naming.sh` | CQ-NAME: 命名規約 | 2 |
| N14 | `scripts/lib/ciqa_checks/cq_regression.sh` | CQ-REG: 回帰検出 | 3 |
| N15 | `logs/ciqa/baseline/last_run.json` | 回帰検出用ベースライン | 3 |

### 1.2 修正

| # | ファイルパス | 変更内容 | Phase |
|---|---|---|---|
| M1 | `kit` | `ciqa` サブコマンド追加 + `all` に ciqa ステップ追加 | 2 |
| M2 | `kit` (`kit_status()`) | CIQA トラッカー表示追加 | 2 |
| M3 | `scripts/lib/handoff_builder.sh` | Trackers Digest に CIQA トラッカー追加 | 2 |

### 1.3 変更なし（尊重）

| ファイルパス | 理由 |
|---|---|
| `verify/verify_requirements.md` | 運用の正 |
| `verify/verify_spec.md` | 運用の正 |
| `verify/verify_implementation_plan.md` | 運用の正 |
| `scripts/lib/gate_*.sh` | 既存の検証ロジック |
| `scripts/run_tests.sh` | 既存のテストランナー |
| `scripts/verify_all.sh` | 既存の検証オーケストレータ |
| `scripts/verify_gate.sh` | 既存のGate別検証 |

---

## 2. フェーズ分割

### Phase 0: 設計（要件・仕様・計画策定）— 今回の作業範囲

**目的**: CI/QA の設計文書とタスク管理表を作成し、後続フェーズの準備を完了する。

**成果物**:
- `docs/ciqa/ciqa_requirements.md`
- `docs/ciqa/ciqa_spec.md`
- `docs/ciqa/ciqa_implementation_plan.md`
- `tasks/ciqa_task_tracker.md`

**検証方法**:
- 4ファイルの存在確認
- 要件 ↔ 仕様 ↔ 計画のクロスリファレンス（Check ID / AC 番号の対応）
- 既存ドキュメントとの整合（exit code 契約、Evidence 書式、トラッカー運用ルール）

**Evidence**:
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase0_design.txt`

---

### Phase 1: 最小 Runner + コアチェック（3チェック）

**目的**: CI/QA の実行基盤を構築し、最も重要な3チェックを実装する。

**成果物**:
- `config/ciqa.conf` — 設定ファイル
- `scripts/lib/ciqa_common.sh` — 共通ヘルパー
- `scripts/ciqa_runner.sh` — 実行器
- `scripts/lib/ciqa_checks/cq_tracker.sh` — CQ-TRK
- `scripts/lib/ciqa_checks/cq_evidence.sh` — CQ-EVC
- `scripts/lib/ciqa_checks/cq_ssot.sh` — CQ-SSOT

**ステップ**:
1. `ciqa_common.sh` 作成（ヘッダ出力、verdict 出力、カウント関数）
2. `ciqa_runner.sh` 作成（config 読み込み → チェック実行 → Evidence 保存 → サマリ出力）
3. `cq_tracker.sh` 実装（全トラッカーの `[x]` 行を走査し、判定・Evidence・日時の有無をチェック）
4. `cq_evidence.sh` 実装（トラッカーから参照される Evidence パスの実在確認）
5. `cq_ssot.sh` 実装（kit SSOT/ と repo _handoff_check/ の sha256 比較）
6. 単体テスト（各チェックを個別実行し PASS/FAIL を確認）

**検証方法**:
- `bash scripts/ciqa_runner.sh` で 3 チェックが実行される
- 意図的にトラッカーを壊して CQ-TRK が FAIL を返すことを確認
- Evidence が `logs/evidence/` に正しく保存される

**Evidence**:
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase1_runner_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase1_cq_trk_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase1_cq_evc_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase1_cq_ssot_test.txt`

---

### Phase 2: kit 統合 + 追加チェック（3チェック）

**目的**: `./kit ciqa` サブコマンドを追加し、残りの QA チェックを実装する。

**成果物**:
- `kit` の修正（ciqa サブコマンド + all 統合 + status 統合）
- `scripts/lib/handoff_builder.sh` の修正（CIQA トラッカー追加）
- `scripts/lib/ciqa_checks/cq_docs.sh` — CQ-DOC
- `scripts/lib/ciqa_checks/cq_lint.sh` — CQ-LINT
- `scripts/lib/ciqa_checks/cq_naming.sh` — CQ-NAME

**ステップ**:
1. `kit` に `ciqa` サブコマンド追加（`ciqa_runner.sh` を呼び出し）
2. `kit_all()` に ciqa ステップ追加（verify → test → ciqa → handoff）
3. `kit_status()` に CIQA トラッカー追加
4. `handoff_builder.sh` の `emit_trackers_digest()` に CIQA トラッカー追加
5. `cq_docs.sh` 実装（req ↔ spec のセクション対応チェック）
6. `cq_lint.sh` 実装（shellcheck 実行 + 結果集計）
7. `cq_naming.sh` 実装（Evidence ファイル名の規約チェック）
8. 統合テスト（`./kit ciqa` で 6 チェックが実行される）

**検証方法**:
- `./kit ciqa` で全チェックが実行される
- `./kit all` に ciqa が含まれている
- `./kit status` に CIQA トラッカーが表示される
- `handoff/latest.md` の Trackers Digest に CIQA が含まれる

**Evidence**:
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase2_kit_integration.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase2_cq_doc_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase2_cq_lint_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase2_cq_name_test.txt`

---

### Phase 3: 回帰検出 + 受け入れ検証

**目的**: CI の核心機能（回帰検出）を実装し、AC-CQ01〜CQ08 の全受け入れ条件を検証する。

**成果物**:
- `scripts/lib/ciqa_checks/cq_regression.sh` — CQ-REG
- `logs/ciqa/baseline/last_run.json` — ベースラインファイル

**ステップ**:
1. `cq_regression.sh` 実装（前回結果の読み込み → 今回結果との比較 → 回帰検出）
2. ベースライン保存ロジック（ciqa_runner.sh に追加: 実行完了後に last_run.json を更新）
3. `last_run.json` の書式定義:
   ```json
   {
     "timestamp": "2026-02-04T15:00:00Z",
     "checks": {
       "CQ-TRK": "PASS",
       "CQ-EVC": "PASS",
       "CQ-SSOT": "PASS",
       "CQ-DOC": "PASS",
       "CQ-LINT": "PASS",
       "CQ-NAME": "PASS",
       "CQ-REG": "PASS"
     }
   }
   ```
4. 受け入れ検証（AC-CQ01〜CQ08 を順に確認）

**検証方法**:
- 前回 PASS → 意図的 FAIL → CQ-REG が `REGRESSION` を検出
- AC-CQ01〜CQ08 の全項目を確認
- `./kit all` の一気通貫が成功

**Evidence**:
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase3_regression_test.txt`
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase3_acceptance_ac01_08.txt`

---

### Phase 4: 拡張（プラグイン方式 + カスタムルール）

**目的**: ユーザがカスタムチェックを追加できるプラグイン機構を構築する。

**成果物**:
- config での有効/無効切り替え
- `scripts/lib/ciqa_checks/` に新規スクリプトを置くだけで自動検出される仕組み
- カスタムルールのテンプレート

**ステップ**:
1. `ciqa_runner.sh` にプラグイン自動検出ロジック追加（`ciqa_checks/cq_*.sh` を glob で取得）
2. config の `checks=` で個別に有効/無効を制御
3. カスタムチェックテンプレート `scripts/lib/ciqa_checks/_template.sh` を作成
4. ドキュメント更新（プラグイン追加手順の記載）

**検証方法**:
- テスト用カスタムチェックを追加し、自動検出されることを確認
- config で特定チェックを無効化し、スキップされることを確認

**Evidence**:
- `logs/evidence/YYYYMMDD-HHMMSS_ciqa_phase4_plugin_test.txt`

---

## 3. 実装順序と依存関係

```
Phase 0 (設計文書)
    ↓
Phase 1 (最小 Runner + コアチェック 3つ)
    ↓
Phase 2 (kit 統合 + 追加チェック 3つ) ← Phase 1 に依存
    ↓
Phase 3 (回帰検出 + 受け入れ検証) ← Phase 2 に依存
    ↓
Phase 4 (プラグイン拡張) ← Phase 3 に依存（任意）
```

---

## 4. リスクと対策

| リスク | 影響 | 対策 |
|--------|------|------|
| shellcheck が未インストール | CQ-LINT が実行できない | shellcheck 未検出時は SKIP（WARN 扱い、FAIL にしない） |
| トラッカーの書式が想定外 | CQ-TRK が誤判定 | 書式バリエーション（インデント違い等）を許容する正規表現 |
| Evidence ファイルが大量（250+件） | CQ-EVC の実行が遅い | ファイル数が多い場合はサンプリングチェック or 並列化 |
| `./kit all` に ciqa を追加すると実行時間が増える | 開発者体験の悪化 | ciqa はデフォルトで軽量チェックのみ、`--full` で全チェック |
| 本体repoへの誤書き込み | SSOT 汚染 | CI/QA スクリプトは MAIN_REPO に対して read-only 操作のみ（git status/diff/log） |
| jq が未インストール | last_run.json の読み書きができない | jq 未検出時は bash の文字列処理でフォールバック |

---

## 5. 変更履歴

- v1.0（2026-02-04 JST）：CI/QA 実装計画 初版
