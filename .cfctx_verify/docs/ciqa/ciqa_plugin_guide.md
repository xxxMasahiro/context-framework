# CIQA プラグイン追加手順（Plugin Guide）

## 1. 概要

CIQA はプラグイン方式でチェックを管理する。
`scripts/lib/ciqa_checks/cq_*.sh` に配置されたスクリプトは、起動時に自動検出され実行対象となる。

新しいチェックの追加は「スクリプトを 1 つ追加」するだけで完了する。

---

## 2. プラグイン追加手順

### Step 1: テンプレートをコピー

```bash
cd scripts/lib/ciqa_checks/
cp _template.sh cq_mycheck.sh
```

ファイル名は必ず `cq_` で始め `.sh` で終わること。

### Step 2: メタデータヘッダを編集

ファイル先頭 30 行以内に以下の 4 つのメタデータを記述する:

```bash
# @check_key: mycheck
# @check_id: CQ-MYCK
# @check_display: My Custom Check
# @check_order: 50
```

| フィールド | 必須 | 説明 |
|-----------|------|------|
| `@check_key` | Yes | config/CLI で使う短縮名（英数小文字、例: `tracker`） |
| `@check_id` | Yes | Evidence に記録される ID（例: `CQ-TRK`） |
| `@check_display` | Yes | 人間可読な表示名（例: `Tracker Integrity`） |
| `@check_order` | No | 実行順（数値、小さい順。デフォルト 50。regression は 99 で最後） |

### Step 3: run_check() を実装

```bash
run_check() {
  local verdict="PASS"
  local fail_count=0
  local details=""

  # チェックロジック ...

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
```

**契約**:
- `run_check()` 関数を 1 つだけ定義する
- stdout にチェック詳細を出力する（Evidence に保存される）
- exit 0 = PASS, exit 1 = FAIL

### Step 4: 動作確認

```bash
# 新しいチェックだけ実行
./kit ciqa mycheck

# 全チェック実行（自動検出で新チェックも含まれる）
./kit ciqa
```

---

## 3. config による有効/無効切り替え

`config/ciqa.conf` の `checks=` で実行するチェックを制御できる。

### 全チェック実行（デフォルト）

```ini
checks=all
```

### 特定チェックのみ実行

```ini
checks=tracker,ssot,evidence
```

### 特定チェックを除外（否定記法）

```ini
checks=!lint,!naming
```

> 否定記法と肯定記法の混在（例: `tracker,!lint`）はエラーになる。

### CLI 引数（最優先）

```bash
# config を無視して指定チェックのみ実行
./kit ciqa tracker evidence

# 全チェック実行
./kit ciqa all
```

**優先順位**: CLI 引数 > config `checks=` > all（デフォルト）

---

## 4. 利用可能な環境変数

`ciqa_runner.sh` が各チェック実行前に以下を export する:

| 変数 | 説明 |
|------|------|
| `KIT_ROOT` | 検証キットルートディレクトリ |
| `MAIN_REPO` | 本体リポジトリパス（**read-only**） |
| `CIQA_CHECK_ID` | 実行中チェックの ID（例: `CQ-TRK`） |
| `CIQA_EVIDENCE_DIR` | Evidence 出力先ディレクトリ |
| `CIQA_BASELINE_DIR_ABS` | 回帰検出ベースラインディレクトリ（絶対パス） |

---

## 5. ヘルパー関数（ciqa_common.sh）

| 関数 | 説明 |
|------|------|
| `ciqa_ts_jst` | JST タイムスタンプ |
| `ciqa_ts_utc` | UTC タイムスタンプ |
| `ciqa_ts_label` | ファイル名用タイムスタンプ（`YYYYMMDD-HHMMSS`） |
| `ciqa_emit_header <name> <id>` | Evidence ヘッダ出力 |
| `ciqa_emit_verdict <PASS/FAIL> <reason>` | 判定行出力 |
| `ciqa_count_checked <file>` | `[x]` 項目カウント |
| `ciqa_count_unchecked <file>` | `[ ]` 項目カウント |
| `ciqa_sha16 <file>` | sha256 先頭 16 文字 |

---

## 6. 実行順序

チェックは `@check_order` の昇順で実行される。
同一 order の場合は `@check_key` のアルファベット順。

| order | check | 備考 |
|-------|-------|------|
| 10 | tracker | |
| 20 | evidence | |
| 30 | ssot | |
| 40 | docs | |
| 50 | lint | カスタムチェックのデフォルト |
| 60 | naming | |
| 99 | regression | 常に最後（他チェック結果を参照） |

---

## 7. 注意事項

- `MAIN_REPO` への書き込みは禁止（read-only 厳守）
- テンプレート `_template.sh` は `cq_` で始まらないため自動検出されない
- メタデータ 3 項目（key/id/display）が欠けているスクリプトは WARN を出してスキップされる
- 新チェック追加後は `./kit ciqa` で全チェック PASS を確認すること

---

## 8. 変更履歴

- v1.0（2026-02-04 JST）：プラグインガイド初版
