# 検証キット再構築 仕様

## 0. 概要

本仕様は、検証キット再構築（REQ-R01〜R07）を実現するための構造・インターフェイス・動作を定義する。

---

## 1. latest.md 新セクション構成

再構築後の `handoff/latest.md` は以下のセクション構成とする:

```markdown
# Verification Kit Handoff

## 1. Meta
- generated: <UTC> / <JST>
- kit_root: <path>
- kit_branch: <branch>
- kit_HEAD: <short_hash>

## 2. Main Repo Snapshot
- path: /home/masahiro/projects/_cfctx/cf-context-framework
- HEAD: <short> (<full>)
- branch: <branch_name>
- status: clean | dirty (<dirty_count> files)
- repo_lock: OK | NG
- SSOT fingerprint:
  - cf_handoff_prompt.md: <sha256_first8>
  - cf_update_runbook.md: <sha256_first8>
  - cf_task_tracker_v5.md: <sha256_first8>
- SSOT match: YES | NO (kit SSOT/ vs repo _handoff_check/)

## 3. Trackers Digest
### 3.1 Verification Tracker (tasks/verify_task_tracker.md)
- progress: <done>/<total> (<pct>%)
- status: ALL_PASS | HAS_FAIL | IN_PROGRESS
- pending items:
  - (none) | <list of unchecked items>
- last_updated: <timestamp>

### 3.2 Test Tracker (tasks/test_task_tracker.md)
- progress: <done>/<total> (<pct>%)
- status: ALL_PASS | HAS_FAIL | IN_PROGRESS
- pending items:
  - (none) | <list of unchecked items>
- last_updated: <timestamp>

### 3.3 As-built Tracker (tasks/as_built_task_tracker.md)
- progress: <done>/<total> (<pct>%)
- status: ALL_PASS | HAS_FAIL | IN_PROGRESS
- pending items:
  - (none) | <list of unchecked items>
- last_updated: <timestamp>

## 4. Evidence Index
| # | Timestamp | Purpose | Command | Verdict | SHA256 (first 16) | Path |
|---|-----------|---------|---------|---------|-------------------|------|
| 1 | ... | ... | ... | PASS | abcdef0123456789 | logs/evidence/... |
| 2 | ... | ... | ... | FAIL | ... | ... |

Total: <N> evidences (<pass_count> PASS, <fail_count> FAIL)

## 5. Kit Files
- SSOT/cf_handoff_prompt.md
- SSOT/cf_update_runbook.md
- SSOT/cf_task_tracker_v5.md
- verify/verify_requirements.md
- verify/verify_spec.md
- verify/verify_implementation_plan.md
- context/run_rules.md
- context/codex_high_prompt.md

## 6. Commands
```
./kit handoff          latest.md を再生成
./kit verify [GATE]    検証実行 (例: ./kit verify C)
./kit test [PHASE]     テスト実行 (例: ./kit test 2)
./kit all              verify + test + handoff 一気通貫
./kit status           進捗サマリ表示
```

## 7. Notes
- This kit is generated outside repo by default (safety).
- Evidence is saved under logs/evidence/ and referenced from trackers.
```

---

## 2. Evidence 仕様

### 2.1 命名規則

```
YYYYMMDD-HHMMSS_<purpose>.txt
```

- `YYYYMMDD-HHMMSS`: JST タイムスタンプ（秒まで）
- `<purpose>`: スネークケース、内容を端的に表す（例: `gateC_req3_functional`, `phase1_env_prereq`）
- ディレクトリ型Evidence（既存互換）: `YYYYMMDDT HHMMSSZ_<gate>/` も許容

### 2.2 sha256 の取り方

```bash
sha256sum <evidence_file> | cut -c1-16
```

- 先頭16文字を Evidence Index に記録する
- ディレクトリ型の場合は、ディレクトリ内の全 `.txt` を結合して sha256 を計算:
  ```bash
  cat <dir>/*.txt | sha256sum | cut -c1-16
  ```

### 2.3 失敗時の扱い

- FAIL 判定でも Evidence ファイルを必ず作成する
- Evidence の先頭行に `VERDICT: FAIL` を記載する
- Evidence Index の Verdict 列に `FAIL` を記載する
- FAIL Evidence のファイル名に `_FAIL` サフィックスは付けない（命名規則統一）

### 2.4 Evidence ヘッダテンプレート

```
=== <Purpose> ===
Timestamp (JST): <YYYY-MM-DD HH:MM:SS JST>
Timestamp (UTC): <YYYY-MM-DDTHH:MM:SSZ>
Command: <executed command>
VERDICT: PASS | FAIL
---
<output>
```

---

## 3. トラッカー更新ルール

### 3.1 チェックボックス更新

- `[ ]` → `[x]` 変更時に以下を同一行または直下に記載:
  ```markdown
  - [x] <項目名>
    - 判定: PASS | FAIL
    - Evidence: logs/evidence/<filename>
    - 日時: <YYYY-MM-DD HH:MM JST>
  ```
- `[x]` → `[ ]` への戻しは禁止。再検証は新規項目を追加する。

### 3.2 Progress Log

- トラッカー末尾の `## Progress Log` セクションに追記:
  ```
  - <YYYY-MM-DD HH:MM JST> | <何をやったか> | <判定> | Evidence: <path>
  ```

### 3.3 自動更新

- `./kit verify` / `./kit test` 実行時、スクリプトが自動でトラッカーを更新する
- 自動更新の範囲:
  - 該当チェックボックスの `[ ]` → `[x]`
  - Evidence パスの記載
  - Progress Log への追記

---

## 4. 統合コマンド `./kit` インターフェイス

### 4.1 基本仕様

- ファイル: `kit` （検証キットルート直下、実行可能）
- シバン: `#!/usr/bin/env bash`
- `set -euo pipefail`

### 4.2 サブコマンド詳細

#### `./kit handoff`

- 機能: `handoff/latest.md` と `handoff/latest.txt` を再生成
- 引数: なし
- 戻り値: 0（成功）/ 1（失敗）
- 出力先: `handoff/latest.md`, `handoff/latest.txt`
- ログ: stdout に `OK: wrote handoff/latest.md` を出力

#### `./kit verify [GATE]`

- 機能: Gate 検証を実行
- 引数:
  - `GATE`（任意）: A〜I の1文字。省略時は全Gate（A〜I）
- 戻り値: 0（全PASS）/ 1（1件以上FAIL）
- 処理フロー:
  1. SSOT比較（kit SSOT/ vs repo _handoff_check/）
  2. 指定Gate の scripts/lib/gate_<letter>.sh を実行
  3. Evidence を logs/evidence/ に保存
  4. verify_task_tracker.md を更新
  5. `./kit handoff` を内部で呼び出し latest.md を再生成
- ログ: stdout + logs/runs/<timestamp>/verify.log

#### `./kit test [PHASE]`

- 機能: テスト実行
- 引数:
  - `PHASE`（任意）: 1, 2, 3, all。省略時は `all`
- 戻り値: 0（全PASS）/ 1（1件以上FAIL）
- 処理フロー:
  1. 指定 Phase のテストを実行
  2. Evidence を logs/evidence/ に保存
  3. test_task_tracker.md を更新
  4. `./kit handoff` を内部で呼び出し latest.md を再生成
- ログ: stdout + logs/runs/<timestamp>/test.log

#### `./kit all`

- 機能: verify + test + handoff の一気通貫実行
- 引数: なし
- 戻り値: 0（全PASS）/ 1（1件以上FAIL）
- 処理フロー:
  1. `./kit verify`（全Gate）
  2. `./kit test all`
  3. `./kit handoff`（最終版生成）
- ログ: stdout + logs/runs/<timestamp>/all.log

#### `./kit status`

- 機能: 各トラッカーの進捗サマリを表示
- 引数: なし
- 戻り値: 常に 0
- 出力例:
  ```
  === Kit Status ===
  Verify:  27/27 (100%) ALL_PASS
  Test:     6/6  (100%) ALL_PASS
  As-built: 9/9  (100%) ALL_PASS
  ```

### 4.3 共通動作

- 実行前に `CFCTX_VERIFY_ROOT` の設定を確認（未設定は FAIL）
- 本体repoの存在確認（不在は FAIL）
- エラー時はメッセージを stderr に出力し exit 1

---

## 5. generate_handoff.sh 改修仕様

### 5.1 変更概要

現行の `scripts/generate_handoff.sh` を全面改修し、セクション1で定義した新フォーマットの latest.md を生成する。

### 5.2 情報収集手順

1. **Meta**: date コマンドで UTC/JST を取得、git rev-parse で kit の HEAD/branch を取得
2. **Main Repo Snapshot**:
   - `MAIN_REPO` パスの特定（既知パスまたは環境変数）
   - `git -C $MAIN_REPO rev-parse --short HEAD` / `rev-parse HEAD`
   - `git -C $MAIN_REPO symbolic-ref --short HEAD`
   - `git -C $MAIN_REPO status --porcelain`
   - `$MAIN_REPO/tools/cf-guard.sh --check` の結果をパース
   - SSOT/ 内3ファイルの sha256（先頭8桁）
   - Kit SSOT/ vs Repo _handoff_check/ の diff
3. **Trackers Digest**:
   - 各トラッカーの `[x]` と `[ ]` を grep でカウント
   - 未完了項目（`[ ]` 行）を抽出
   - ファイルの最終更新日時を取得
4. **Evidence Index**:
   - `logs/evidence/` 配下の全ファイルを走査
   - 各ファイルの先頭行から Purpose を抽出（`=== <Purpose> ===` パターン）
   - Command 行を抽出
   - VERDICT 行を抽出
   - sha256 を計算
5. **Kit Files**: 固定リスト出力
6. **Commands**: 固定テキスト出力

### 5.3 Evidence Index 生成の詳細

- ディレクトリ型Evidence の場合:
  - Purpose はディレクトリ名から推定（`gateC` → `Gate C verification`）
  - sha256 はディレクトリ内の全 .txt を結合して計算
- ファイル型Evidence の場合:
  - ヘッダから Purpose / Command / VERDICT を抽出
  - ヘッダがない旧形式のファイルは、ファイル名から Purpose を推定、VERDICT は `UNKNOWN`
- 一覧は新しい順（降順）でソート

---

## 6. 変更履歴

- v1.0（2026-02-03 JST）：再構築仕様 初版
