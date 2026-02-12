# CI/QA 仕様（CIQA Specification）

## 0. 概要

本仕様は、CI/QA 要件定義（REQ-CQ01〜CQ08）を実現するためのコマンド設計、チェック構成、入出力、ディレクトリ規約、Runner API を定義する。

---

## 1. コマンド設計

### 1.1 サブコマンド

```
./kit ciqa [CHECK...]
```

| 引数 | 動作 |
|------|------|
| (なし) | 全チェックを実行 |
| `tracker` | トラッカー整合性チェックのみ |
| `evidence` | Evidence chain チェックのみ |
| `ssot` | SSOT ドリフトチェックのみ |
| `docs` | ドキュメント整合チェックのみ |
| `lint` | スクリプト品質チェックのみ |
| `naming` | 命名規約チェックのみ |
| `regression` | 回帰検出チェックのみ |
| `tracker evidence` | 複数チェックの組み合わせ |

### 1.2 `./kit all` への統合

```
./kit all  →  verify → test → ciqa → handoff
```

- ciqa は test の後、handoff の前に実行される
- ciqa の FAIL は `./kit all` の exit code に反映される（1 を返す）
- ciqa が FAIL でも handoff は実行する（最終状態を記録するため）

### 1.3 Exit Code

| Code | 意味 |
|------|------|
| 0 | 全チェック PASS |
| 1 | 1件以上 FAIL |

---

## 2. チェック一覧（Check ID）

| Check ID | カテゴリ | 説明 | 判定基準 |
|----------|----------|------|----------|
| `CQ-TRK` | QA | トラッカー整合性 | 全 `[x]` に判定・Evidence・日時がある |
| `CQ-EVC` | QA | Evidence chain | トラッカーが参照する Evidence ファイルが実在する |
| `CQ-SSOT` | QA | SSOT ドリフト | kit SSOT/ と repo _handoff_check/ の sha256 が一致 |
| `CQ-DOC` | QA | ドキュメント整合 | req ↔ spec のセクション対応が取れている |
| `CQ-LINT` | QA | スクリプト品質 | shellcheck で error/warning が 0 |
| `CQ-NAME` | QA | 命名規約 | Evidence ファイル名が `YYYYMMDD-HHMMSS_*.txt` or `YYYYMMDTHHMMSSZ_*` |
| `CQ-REG` | CI | 回帰検出 | 前回 PASS だったチェックが今回 FAIL になっていない |

---

## 3. 入力（Config）

### 3.1 設定ファイル

```
config/ciqa.conf
```

INI 風の設定ファイル（Phase 1 では固定値、Phase 4 で外部化）:

```ini
# CI/QA Configuration
# enabled checks (comma-separated check IDs, or "all")
checks=all

# shellcheck severity threshold: error | warning | info | style
lint_severity=warning

# regression baseline directory
regression_baseline_dir=logs/ciqa/baseline

# tracker files to check (comma-separated relative paths)
tracker_files=tasks/verify_task_tracker.md,tasks/test_task_tracker.md,tasks/as_built_task_tracker.md,tasks/rebuild_task_tracker.md,tasks/post_rebuild_task_tracker.md,tasks/ciqa_task_tracker.md

# doc pairs to cross-reference (format: req_path:spec_path, comma-separated)
doc_pairs=docs/rebuild/rebuild_requirements.md:docs/rebuild/rebuild_spec.md,docs/ciqa/ciqa_requirements.md:docs/ciqa/ciqa_spec.md
```

### 3.2 設定の読み込み順序

1. `config/ciqa.conf`（デフォルト）
2. 環境変数 `CIQA_CONFIG` で指定されたファイル（上書き）
3. コマンドライン引数（最優先）

---

## 4. 出力

### 4.1 Evidence

各チェックの結果を個別の Evidence ファイルに保存:

```
logs/evidence/YYYYMMDD-HHMMSS_ciqa_<check_id>.txt
```

例:
```
logs/evidence/20260204-150000_ciqa_CQ-TRK.txt
logs/evidence/20260204-150000_ciqa_CQ-EVC.txt
```

### 4.2 Evidence ヘッダ書式

```
=== CIQA: <Check Name> ===
Timestamp (JST): 2026-02-04 15:00:00 JST
Timestamp (UTC): 2026-02-04T06:00:00Z
Check: <CQ-XXX>
VERDICT: PASS | FAIL
---
<check output details>
```

### 4.3 サマリ出力（stdout）

```
=== kit ciqa ===

  CQ-TRK  (Tracker Integrity)     : PASS
  CQ-EVC  (Evidence Chain)         : PASS
  CQ-SSOT (SSOT Drift)            : PASS
  CQ-DOC  (Document Consistency)   : PASS
  CQ-LINT (Script Quality)         : PASS
  CQ-NAME (Naming Convention)      : PASS
  CQ-REG  (Regression Detection)   : PASS

CIQA Summary: 7/7 PASS, 0 FAIL
Evidence: logs/evidence/20260204-150000_ciqa_summary.txt

--- Regenerating handoff ---
OK: wrote handoff/latest.md
```

### 4.4 サマリ Evidence

全チェック完了後、サマリを1ファイルにまとめた Evidence も保存:

```
logs/evidence/YYYYMMDD-HHMMSS_ciqa_summary.txt
```

---

## 5. ディレクトリ規約

### 5.1 新規追加ディレクトリ/ファイル

```
.cfctx_verify/
├── config/
│   └── ciqa.conf                      # CI/QA 設定
├── docs/ciqa/
│   ├── ciqa_requirements.md           # CI/QA 要件定義
│   ├── ciqa_spec.md                   # CI/QA 仕様（本ファイル）
│   └── ciqa_implementation_plan.md    # CI/QA 実装計画
├── logs/ciqa/
│   └── baseline/                      # 回帰検出用ベースライン
│       └── last_run.json              # 前回実行結果
├── scripts/
│   ├── ciqa_runner.sh                 # CI/QA 実行器（メインエントリ）
│   └── lib/ciqa_checks/              # 個別チェックスクリプト
│       ├── cq_tracker.sh             # CQ-TRK
│       ├── cq_evidence.sh            # CQ-EVC
│       ├── cq_ssot.sh                # CQ-SSOT
│       ├── cq_docs.sh                # CQ-DOC
│       ├── cq_lint.sh                # CQ-LINT
│       ├── cq_naming.sh              # CQ-NAME
│       └── cq_regression.sh          # CQ-REG
└── tasks/
    └── ciqa_task_tracker.md           # CI/QA タスク管理表
```

### 5.2 既存ファイルへの変更

| ファイル | 変更内容 |
|----------|----------|
| `kit` | `ciqa` サブコマンドの追加、`all` に ciqa ステップ追加 |
| `kit` の `kit_status()` | CIQA トラッカーの表示追加 |

---

## 6. Runner API（チェックスクリプトのインタフェース）

### 6.1 共通インタフェース

各チェックスクリプト (`scripts/lib/ciqa_checks/cq_*.sh`) は以下の契約に従う:

#### 関数シグネチャ

```bash
# 各スクリプトは run_check() 関数をエクスポートする
# 引数: なし（設定は環境変数・グローバル変数で渡す）
# 戻り値: 0 = PASS, 1 = FAIL
# stdout: チェック結果の詳細（Evidence に記録される）
run_check() {
  local verdict="PASS"
  local details=""

  # ... チェックロジック ...

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
```

#### 利用可能な環境変数

| 変数 | 説明 |
|------|------|
| `KIT_ROOT` | 検証キットルート |
| `MAIN_REPO` | 本体repo パス |
| `CIQA_CHECK_ID` | 実行中のチェック ID（例: `CQ-TRK`） |
| `CIQA_EVIDENCE_DIR` | Evidence 出力先ディレクトリ |
| `CIQA_BASELINE_DIR` | 回帰検出用ベースラインディレクトリ |

#### 共通ライブラリ

- `scripts/lib/evidence.sh` を source して `discover_main_repo()` 等を利用可能
- `scripts/lib/ciqa_common.sh`（新規）で CI/QA 固有のヘルパー関数を提供:
  - `ciqa_emit_header <check_name>` — Evidence ヘッダ出力
  - `ciqa_emit_verdict <PASS|FAIL> <reason>` — 判定行出力
  - `ciqa_count_checked <tracker_file>` — `[x]` カウント
  - `ciqa_count_unchecked <tracker_file>` — `[ ]` カウント

### 6.2 Runner（ciqa_runner.sh）の動作

```
1. config/ciqa.conf を読み込む
2. 実行対象チェックを決定（引数 or config）
3. 各チェックスクリプトを source し run_check() を呼び出す
4. 結果を Evidence に保存
5. サマリを stdout に出力
6. 全チェック完了後にサマリ Evidence を保存
7. FAIL があれば exit 1、なければ exit 0
```

---

## 7. 失敗分類（Failure Signature）

| Signature | 意味 | 対処 |
|-----------|------|------|
| `CQ-TRK:MISSING_EVIDENCE` | `[x]` 項目に Evidence パスがない | トラッカーに Evidence を追記 |
| `CQ-TRK:MISSING_VERDICT` | `[x]` 項目に判定がない | トラッカーに判定を追記 |
| `CQ-TRK:MISSING_DATE` | `[x]` 項目に日時がない | トラッカーに日時を追記 |
| `CQ-EVC:FILE_NOT_FOUND` | 参照された Evidence ファイルが存在しない | ファイルパスを修正 or Evidence を再生成 |
| `CQ-EVC:SHA256_MISMATCH` | Evidence の sha256 が latest.md の記録と不一致 | Evidence を再生成 or latest.md を再生成 |
| `CQ-SSOT:DRIFT` | kit SSOT/ と repo _handoff_check/ が不一致 | SSOT を同期（cp） |
| `CQ-DOC:SECTION_MISSING` | spec に req で定義されたセクションが存在しない | spec を更新 |
| `CQ-LINT:SHELLCHECK_ERROR` | shellcheck で error が検出された | スクリプトを修正 |
| `CQ-LINT:SHELLCHECK_WARNING` | shellcheck で warning が検出された | スクリプトを修正 |
| `CQ-NAME:INVALID_FORMAT` | Evidence ファイル名が規約に違反 | ファイルをリネーム |
| `CQ-REG:REGRESSION` | 前回 PASS → 今回 FAIL | 回帰の原因を調査 |

---

## 8. `./kit status` への統合

```
=== Kit Status ===

  Verify:    33/33 (100%) ALL_PASS
  Test:       6/6  (100%) ALL_PASS
  As-built:  10/10 (100%) ALL_PASS
  Rebuild:   34/34 (100%) ALL_PASS
  PostRebld:  7/7  (100%) ALL_PASS
  CIQA:       0/N  (  0%) IN_PROGRESS     ← 新規追加
```

---

## 9. latest.md への統合

Trackers Digest に CIQA トラッカーを追加:

```markdown
### 3.N CIQA Tracker (tasks/ciqa_task_tracker.md)
- progress: <done>/<total> (<pct>%)
- status: ALL_PASS | HAS_FAIL | IN_PROGRESS
- pending items:
  - ...
- last_updated: <timestamp>
```

---

## 10. 変更履歴

- v1.0（2026-02-04 JST）：CI/QA 仕様 初版
