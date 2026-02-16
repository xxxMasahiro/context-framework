# as-built 実装計画書（正式版）— Temporary Verification Kit

version: 2.2
date: 2026-02-14
status: 正式版（v2.2: cf_/cf- プレフィックス除去 — SSOT 3 ファイル名・ツール参照を新名に更新）

---

## 0. 目的・位置づけ

本書は検証キットの **現状（as-built）実装計画** を記述する。
各 Phase の実装状態、標準手順、失敗時の切り分け、証跡の残し方、保守（Gate/チェック追加の作法）を定義する。

- SSOT（運用の正）は `verify/verify_implementation_plan.md`。
- 対応要件は `as_built/as_built_requirements.md`（REQ-xxx）、対応仕様は `as_built/as_built_spec.md`（SPEC-xxx）で参照。

---

## 1. 前提条件

### PLAN-PRE01: 環境

| 項目 | 要件 | 根拠 |
|------|------|------|
| OS | bash が動作する環境（Ubuntu/WSL） | verify_spec.md:134 |
| KIT_ROOT | `/home/masahiro/.gate-audit_root/.gate-audit/`（CF repo 内 `.gate-audit/` は snapshot） | kit:18-20 |
| MAIN_REPO | 本体 repo（自動発見: evidence.sh:18-38） | evidence.sh:18-38 |
| Git | 参照系コマンドのみ使用（status/diff/log/rev-parse） | evidence.sh:250-310 |
| shellcheck | CQ-LINT チェックで使用（未インストール時は SKIP） | self_check_spec.md:228 |

### PLAN-PRE02: 安全性契約

- 本体 repo への書き込み操作は一切禁止（REQ-S02）。
- 検索コマンドは `|| true` 付与（REQ-S03）。
- Kit 内の書き込み先は `logs/evidence/`、`handoff/`、`tasks/`（トラッカー更新）、`logs/self-check/baseline/` に限定。

---

## 2. Phase 別実装状態

### PLAN-P1: Phase 1 — ブートストラップ（キット生成）— 完了

| タスク | 状態 | 根拠 |
|--------|------|------|
| KIT_ROOT 確認・Kit 生成 | 完了 | Kit が repo 外に存在 |
| SSOT 3 ファイルを SSOT/ へコピー | 完了 | SSOT/handoff_prompt.md 等 3 ファイル |
| context/ 作成 | 完了 | context/run_rules.md, codex_high_prompt.md |
| tasks/ 作成 | 完了 | tasks/verify_task_tracker.md 他 6 ファイル |
| scripts/ 作成 | 完了 | verify_all.sh, verify_gate.sh, generate_handoff.sh, run_tests.sh, self-check.sh, lib/ 配下 |
| .gitignore 設置 | 完了 | .gitignore 存在 |

**SSOT との差分**:
- `scripts/verify.sh`（単一）→ `verify_all.sh` + `verify_gate.sh` に分離（SPEC 差分 #1）
- `scripts/collect_evidence.sh` → `lib/evidence.sh` にライブラリ化（SPEC 差分 #2）
- README.md は Kit root に不在（SPEC 差分 #7）

### PLAN-P2: Phase 2 — 最小検証（スモーク）— 完了

| タスク | 状態 | 根拠 |
|--------|------|------|
| Repo Lock Evidence 化 | PASS | verify_task_tracker.md:27-29 |
| doctor STEP-G003 Evidence 化 | PASS | verify_task_tracker.md:31-33 |
| Gate C（アダプタ参照整合）read-only 確認 | PASS | verify_task_tracker.md:35-38 |
| Gate G（ログ導線）read-only 確認 | PASS | verify_task_tracker.md:39-42 |
| handoff/latest.md 生成 | 完了 | generate_handoff.sh で生成済み |

### PLAN-P3: Phase 3 — 全体検証（フル）— 完了

| Gate | req1 | req2 | req3 | 根拠 |
|------|------|------|------|------|
| A | PASS | PASS | PASS | verify_task_tracker.md:48-56 |
| B | PASS | PASS | PASS | verify_task_tracker.md:58-67 |
| C | PASS | PASS | PASS | verify_task_tracker.md:69-78 |
| D | PASS | PASS | PASS | verify_task_tracker.md:80-90 |
| E | PASS | PASS | PASS | verify_task_tracker.md:92-100 |
| F | PASS | PASS | PASS | verify_task_tracker.md:101-112 |
| G | PASS | PASS | PASS | verify_task_tracker.md:114-123 |
| H | PASS | PASS | PASS | verify_task_tracker.md:125-134 |
| I | PASS | PASS | PASS | verify_task_tracker.md:136-145 |

- 最新一括検証: 2026-02-02T17:20 JST（checksums.sha256 修正＋厳格化後）
- 結果: **Gate A〜I 全 PASS（9/9）+ checksums.sha256 全件 OK**
- 根拠: verify_task_tracker.md:12-18

### PLAN-P4: Phase 4 — Self-check（CI/QA レイヤー）— 完了

| サブフェーズ | タスク | 状態 | 根拠 |
|-------------|--------|------|------|
| Phase 0 | 設計文書作成 (requirements/spec/plan) | 完了 | docs/self-check/ 配下 4 ファイル |
| Phase 1 | 最小 Runner + コアチェック 3 つ (CQ-TRK/EVC/SSOT) | 完了 | self-check.sh, cq_tracker.sh, cq_evidence.sh, cq_ssot.sh |
| Phase 2 | kit 統合 + 追加チェック 3 つ (CQ-DOC/LINT/NAME) | 完了 | kit self-check サブコマンド, cq_docs.sh, cq_lint.sh, cq_naming.sh |
| Phase 3 | 回帰検出 (CQ-REG) | 完了 | cq_regression.sh, logs/self-check/baseline/ |
| Phase 4 | プラグイン自動発見 | 完了 | self-check.sh:48-107 (メタデータパース) |
| Phase 4a | プラグインソート (@check_order) | 完了 | self-check.sh:93-104 (sort -t: -k1,1n -k2,2) |
| Phase 4b | config 否定構文 (checks=!key) | 完了 | self-check.sh:146-193 |
| Phase 4c | CQ-DOC REQ-ID 範囲展開 | 完了 | cq_docs.sh:84-99 (〜/~ 記法対応) |
| Phase 4d | CQ-RO Read-only Compliance チェック | 完了 | cq_readonly.sh:1-127 (13 種 write パターン検出) |
| Phase 4e | Phase 1 ro mount 検証統合 | 完了 | run_tests.sh:112-128 (オプション、sudo NOPASSWD 依存) |
| Phase 4f | バグ修正 8 件（Gate 判定厳格化 + exit code + パス + サマリ抽出 + 階層） | 完了 | verify_gate.sh, run_tests.sh, evidence.sh, kit, gate_a/b/g/i.sh |
| Phase 4g | Gate 動的スケーラビリティ（run_tests.sh A-I 固定→動的化、tracker_updater.sh セクション自動生成、gate_registry.sh ID バリデーション一貫化） | 完了 | run_tests.sh:17,152-161,211-215,376-384, tracker_updater.sh:110-169, gate_registry.sh:16-19,41,67-70 |

### PLAN-P5: Phase 5 — ロックダウン（隔離）— 完了（v1.9）

| タスク | 状態 | 根拠 |
|--------|------|------|
| scripts/lockdown.sh | 完了 | lockdown.sh:1-97（quarantine 移動 + chmod go-rwx + LOCKED.flag + README_LOCKED.md） |
| scripts/unlock.sh | 完了 | unlock.sh:1-100（二段階解除: LOCKED.flag 確認 + パスフレーズ UNLOCK-VERIFY-KIT） |
| LOCKED.flag / README_LOCKED.md | lockdown 時に自動生成 | lockdown.sh:78-96 |
| ./kit lockdown / unlock サブコマンド | 完了 | kit:308-319 |
| MAIN_REPO バリデーション強化 | 完了 | evidence.sh:17-97（_validate_main_repo 4 段階検証: .git + _handoff_check/ + 構造マーカー + SSOT sha256 照合） |

**SSOT 準拠**: verify_spec.md:93-108 の仕様を完全実装。

---

## 3. 標準手順

### PLAN-PROC01: 進捗確認（副作用なし）

```bash
./kit status
```

- 6 トラッカーの進捗を表示。
- 副作用なし。
- 根拠: kit:188-244, SPEC-S07

### PLAN-PROC02: Gate 検証

```bash
# 全 Gate
./kit verify

# 個別 Gate (例: Gate C のみ)
./kit verify C

# 複数 Gate
./kit verify A B C
```

**処理フロー**:
1. 本体 repo 発見 → repo 参照証跡記録
2. SSOT 比較（kit SSOT/ vs repo _handoff_check/）
3. 指定 Gate の `verify_gate_<id>()` 実行
4. Evidence を `logs/evidence/<ts>_gate<ID>/` に保存
5. handoff/latest.md を再生成

根拠: kit:67-86, verify_all.sh:1-148, verify_gate.sh:1-144

### PLAN-PROC03: テスト実行

```bash
# 全 Phase
./kit test

# Phase 単独
./kit test 1   # 環境/スモーク
./kit test 2   # Gate 固有
./kit test 3   # E2E/再現性
```

**処理フロー**:
1. 指定 Phase のテスト関数を実行
2. Evidence を `logs/evidence/<ts>_test_phase<N>.txt` に保存
3. handoff/latest.md を再生成

根拠: kit:88-112, run_tests.sh:1-513

### PLAN-PROC04: CI/QA チェック

```bash
# 全チェック
./kit self-check

# 個別チェック
./kit self-check tracker evidence

# config で除外指定（否定構文）
# config/self-check.conf: checks=!lint,!naming  → lint と naming 以外を実行
# 注意: 正と負の混在（例: tracker,!lint）はエラー
./kit self-check
```

**処理フロー**:
1. config/self-check.conf を読み込み
2. 実行対象チェックを決定（CLI 引数 > config > all）
3. 各チェックの `run_check()` を実行
4. 個別 Evidence + サマリ Evidence を保存
5. ベースライン（last_run.json）を更新
6. handoff/latest.md を再生成

根拠: kit:114-132, self-check.sh:1-401

### PLAN-PROC05: 一気通貫

```bash
./kit all
```

**処理フロー**:
1. Step 1/4: verify（全 Gate）
2. Step 2/4: test（全 Phase）
3. Step 3/4: self-check（全チェック）
4. Step 4/4: handoff（最終生成）

FAIL があっても最後の handoff まで実行する。

根拠: kit:134-186, SPEC-S06

### PLAN-PROC06: handoff 生成

```bash
./kit handoff
```

- `handoff/latest.md` と `handoff/latest.txt` を再生成。
- 根拠: kit:60-64, generate_handoff.sh:1-62

---

## 4. 失敗時の切り分け

### PLAN-FAIL01: Gate 検証 FAIL

1. サマリ出力で FAIL した Gate を特定:
   ```
   Gate C: FAIL
   ```
2. 個別 Gate を再実行:
   ```bash
   ./kit verify C
   ```
3. Evidence を確認:
   ```bash
   ls -la logs/evidence/*gateC*/
   cat logs/evidence/*gateC*/judgement.txt
   ```
4. req1/req2/req3 のどれが FAIL かを judgement.txt から特定。
5. FAIL の原因（ファイル不在/checksum 不一致/参照切れ等）に対応。

### PLAN-FAIL02: テスト FAIL

1. Phase 番号を特定:
   ```
   Phase 1: FAIL
   ```
2. Evidence ファイルを確認:
   ```bash
   cat logs/evidence/*test_phase1*.txt
   ```
3. FAIL セクション（環境前提 / スモーク / Gate 固有 / E2E / 再現性）を特定。

### PLAN-FAIL03: Self-check FAIL

1. FAIL したチェック ID を特定:
   ```
   CQ-TRK (Tracker Integrity): FAIL
   ```
2. 個別チェックを再実行:
   ```bash
   ./kit self-check tracker
   ```
3. Evidence を確認:
   ```bash
   cat logs/evidence/*sc_CQ-TRK*.txt
   ```
4. 失敗シグネチャ（CQ-TRK:MISSING_EVIDENCE 等）から原因を特定。

### PLAN-FAIL04: 本体 repo 発見失敗

```
FATAL: Cannot locate main repo (context-framework).
```

- 原因: `discover_main_repo()` のハードコード候補リスト（evidence.sh:19-22）に本体 repo パスが含まれていない。
- 対処: 候補リストにパスを追加するか、find フォールバック（evidence.sh:30-34）の検索範囲を確認。

---

## 5. 証跡の残し方

### PLAN-EV01: Gate 検証の証跡

- 自動: `verify_gate_<id>()` 内で `init_evidence()` → `record_ref()` → `write_judgement()` → `gate_summary()` の順に呼ばれ、以下が自動生成される:
  - `meta.txt` — タイムスタンプ、repo HEAD、repo status
  - `checksums.sha256` — 参照ファイルの sha256
  - `commands.txt` — 実行コマンドログ
  - `judgement.txt` — req1/req2/req3 + 総合判定
  - `req1_summary.txt` / `req2_consistency.txt` / `req3_functional.txt` — 個別結果
  - `references/` — 参照した本体 repo ファイルのコピー

### PLAN-EV02: テストの証跡

- `run_tests.sh` の各 Phase 関数が `_rt_save_evidence()` で Evidence ファイルを保存。
- 形式: `logs/evidence/<ts>_test_phase<N>.txt`

### PLAN-EV03: Self-check の証跡

- `self-check.sh` の `run_single_check()` が個別 Evidence を保存。
- `main()` がサマリ Evidence を保存。
- 形式: `logs/evidence/<ts>_sc_<check_id>.txt` + `<ts>_sc_summary.txt`

### PLAN-EV04: ベースライン（回帰検出用）

- `self-check.sh` の最後に `logs/self-check/baseline/last_run.json` を更新。
- 次回 `CQ-REG` チェック時に前回結果と比較。
- 根拠: self-check.sh:362-393

---

## 6. 保守

### PLAN-MAINT01: 新 Gate 追加

1. `scripts/lib/gate_<id>.sh` を作成（`<id>` は英数字・アンダースコアのみ。正規表現メタ文字は不可）
2. ファイル内に `verify_gate_<id>()` 関数を定義
3. 関数は以下のパターンに従う:
   - `init_evidence("gate<ID>")`
   - req1/req2/req3 のチェック + `write_judgement()`
   - `gate_summary("Gate <ID>", pass, fail, total)`
4. **他ファイルの変更は不要**（gate_registry.sh が自動発見、run_tests.sh・tracker_updater.sh が自動追従）
5. 根拠: gate_registry.sh:1-79

### PLAN-MAINT02: 新 Self-check チェック追加

1. `scripts/lib/self_checks/cq_<key>.sh` を作成
2. ファイル先頭 30 行以内にメタデータヘッダを記述:
   ```bash
   # @check_key: <key>
   # @check_id: CQ-<XXX>
   # @check_display: <Human Readable Name>
   # @check_order: <N>  (ソート順、小さいほど先)
   ```
3. `run_check()` 関数を定義（戻り値 0=PASS, 1=FAIL、stdout がチェック詳細）
4. **他ファイルの変更は不要**（self-check.sh が自動発見）
5. **実行順序の制御**: `@check_order` を設定（小さいほど先に実行）。同一 order はキー名アルファベット順。既定値は 50。
   - 現在の順序: tracker(10) → readonly(15) → evidence(20) → ssot(30) → docs(40) → lint(50) → naming(50) → regression(60)
6. 根拠: self-check.sh:48-107, docs/self-check/self_check_plugin_guide.md

### PLAN-MAINT03: トラッカー更新ルール

- `[ ]` → `[x]` 変更時に以下を必須:
  - 判定: PASS | FAIL
  - Evidence: logs/evidence/ 内のパス
  - 日時: JST タイムスタンプ
- `[x]` → `[ ]` への戻しは禁止。再検証は新規項目を追加。
- `tracker_updater.sh` が自動更新を提供（`./kit verify` / `./kit test` 実行時）。
- 新 Gate 追加時、トラッカーに `### Gate <ID>` セクションが存在しない場合は `_tu_auto_create_gate_section()` が標準テンプレート（要件①②③）で自動生成する。
- 根拠: tracker_updater.sh:41-143, docs/rebuild/rebuild_spec.md:135-162

#### 自動更新パイプライン（SPEC-S15）

`./kit verify` / `./kit test` 実行時に以下が自動的に行われる（手動操作不要）:

1. **verify 時**: `gate_summary()` が `GATE_EVIDENCE:<ID>:<path>` マーカーを出力 → `kit:30-48` がパースし `update_verify_tracker()` で `[ ]` → `[x]` 変換 + メタデータ挿入 → `append_progress_log()` でサマリ追記
2. **test 時**: `run_tests.sh` が `Phase N: PASS/FAIL Evidence: <path>` を出力 → `kit:52-71` がパースし `update_test_tracker()` で更新 → `append_progress_log()` でサマリ追記
3. 全呼出に `|| true` 付与: 更新失敗が検証結果（exit code）に影響しない

#### 進捗ログ書式

```markdown
## Progress Log

- 2026-02-05 20:01 JST | kit verify: Total: 9/9 PASS
- 2026-02-05 20:02 JST | kit test: Total: 3/3 PASS
```

- タイムゾーン: JST 固定（`_tu_ts_jst_short()` → `TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M'`）
- セクション不在時は自動作成（tracker_updater.sh:179-181）

### PLAN-MAINT04: SSOT 同期

- Kit `SSOT/` と本体 `_handoff_check/` が不一致の場合（CQ-SSOT: FAIL）:
  ```bash
  cp ~/projects/context-framework/_handoff_check/*.md SSOT/
  ```
- 同期後に `./kit self-check ssot` で MATCH を確認。

---

## 7. 未実装・不足一覧

| # | 項目 | 優先度 | 内容 | SSOT 参照 |
|---|------|--------|------|-----------|
| ~~1~~ | ~~lockdown.sh / unlock.sh~~ | ~~低~~ | ~~Phase 5~~ → **v1.9 で実装完了** | verify_spec.md:93-108 |
| 2 | GATE_AUDIT_ROOT 統一 | 低 | generate_handoff.sh 以外は SCRIPT_DIR 自己解決 | verify_requirements.md:35 |
| 3 | logs/runs/ ディレクトリ | 低 | SSOT 仕様では定義あるが未使用。機能的に充足 | verify_spec.md:36-38 |
| 4 | Kit root README.md | 低 | SSOT で必須だが不在 | verify_implementation_plan.md:20 |
| 5 | verify.sh --mode smoke/full | 低 | SSOT では smoke/full モード切替を定義。実態は全 Gate 実行のみ | verify_spec.md:78 |

---

## 8. リスクと対策（as-built 評価）

| リスク | SSOT 定義 | 対策状態 | 評価 |
|--------|-----------|----------|------|
| 検証キットが repo に混入 | verify_implementation_plan.md:88 | .gitignore 設置済み、repo 外生成を既定 | 充足 |
| 検証が "ドキュメント確認" だけで終わる | verify_implementation_plan.md:91 | verify_all.sh による自動検証 + checksums 検算 + Self-check 自動チェック | 充足 |
| 検証が長期化して状況不明 | verify_implementation_plan.md:93 | verify_task_tracker.md + handoff 自動生成 + ./kit status | 充足 |
| lockdown ~~未実装~~による残留リスク | verify_spec.md:93-108 | v1.9 で lockdown.sh / unlock.sh 実装完了。`./kit lockdown` で隔離可能 | 充足 |
| 回帰（PASS → FAIL）の見逃し | - | CQ-REG（回帰検出）チェックが自動検出 | 充足 |
| SSOT ドリフト | - | CQ-SSOT チェックが sha256 比較で検出 | 充足 |
| トラッカーの Evidence 欠損 | - | CQ-TRK + CQ-EVC チェックで自動検出 | 充足 |
| セキュリティ脆弱性 | - | 2026-02-06 総合調査: 全 17 件 Pass（Critical/High 0、Medium 3 受容、Low 11 受容、Info 3 受容） | 充足（REQ-S05） |

### PLAN-SEC01: セキュリティ総合調査（2026-02-06 実施・完了）

| タスク | 状態 | 結果 |
|--------|------|------|
| シェルスクリプト 28 本の脆弱性調査 | 完了 | 14 件指摘、全件 Pass（Medium 3 / Low 8 / Info 2） |
| 設定・データファイルの脆弱性調査 | 完了 | 3 件指摘、全件 Pass（Low 3 / Info 1） |
| セキュリティ姿勢（良好点）の確認 | 完了 | eval 不使用、set -euo pipefail 統一、変数クォート適切、read-only 設計等を確認 |
| 受容判定と文書化 | 完了 | 全 17 件の受容理由を文書化（SPEC-D03、verify_task_tracker.md に記録） |

**調査対象**:
- kit（メイン CLI）、scripts/*.sh、scripts/lib/*.sh、scripts/lib/self_checks/cq_*.sh、tools/*.sh
- config/self-check.conf、.gitignore、Git 追跡ファイル（.bak, .pyc）、ファイル権限

**受容判定の基準**:
- 固定値使用（ユーザー入力経路なし）→ 受容
- 信頼境界内（git 管理下・キット管理下）→ 受容
- 運用制約（単一ユーザー・ローカル環境）→ 受容
- 衛生面のみの指摘（セキュリティリスクなし）→ 受容

---

## 9. REQ↔SPEC↔PLAN 対応表

| REQ | SPEC | PLAN |
|-----|------|------|
| REQ-S01 (生成場所) | SPEC-D01 | PLAN-P1 (ブートストラップ) |
| REQ-S02 (read-only) | SPEC-D02 | PLAN-PRE02 (安全性契約) |
| REQ-S03 (検索安全) | SPEC-D02 | PLAN-PRE02 |
| REQ-S04 (Repo Lock) | SPEC-S03 (verify_all.sh) | PLAN-P2 (スモーク), PLAN-PROC02 |
| REQ-S05 (セキュリティ姿勢) | SPEC-D02, SPEC-D03 | PLAN-SEC01 |
| REQ-T01 (Evidence 保存) | SPEC-S10 (evidence.sh), SPEC-E01〜E04 | PLAN-EV01〜EV04 |
| REQ-T02 (Evidence 命名) | SPEC-E01, SPEC-E02 | PLAN-EV01, PLAN-EV02 |
| REQ-T03 (Checksum) | SPEC-E03 | PLAN-EV01 |
| REQ-T04 (Tracker) | SPEC-S11 (tracker_updater.sh) | PLAN-MAINT03 |
| REQ-T05 (handoff) | SPEC-S12 (handoff_builder.sh), SPEC セクション 7 | PLAN-PROC06 |
| REQ-O01 (1 手ずつ) | - (運用ルール) | PLAN-PRE02 (run_rules.md) |
| REQ-O03 (handoff 統一) | SPEC-S12 | PLAN-PROC06 |
| REQ-F01 (./kit) | SPEC-S01 | PLAN-PROC01〜06 |
| REQ-F02 (verify) | SPEC-S02, SPEC-S03, SPEC-G01〜G02 | PLAN-PROC02, PLAN-P3 |
| REQ-F03 (test) | SPEC-S04 | PLAN-PROC03, PLAN-P2 |
| REQ-F04 (self-check) | SPEC-S05, SPEC セクション 5 | PLAN-PROC04, PLAN-P4 |
| REQ-F05 (all) | SPEC-S06 | PLAN-PROC05 |
| REQ-F06 (status) | SPEC-S07 | PLAN-PROC01 |
| REQ-F07 (Gate 自動発見) | SPEC-S08 | PLAN-MAINT01 |
| REQ-F08 (Self-check 自動発見) | SPEC-S09 | PLAN-MAINT02 |
| REQ-F09 (トラッカー自動更新) | SPEC-S11, SPEC-S15 | PLAN-MAINT03 |
| REQ-F10 (プラグインソート) | SPEC-S09 | PLAN-MAINT02, PLAN-P4 Phase 4a |
| REQ-F11 (否定構文) | SPEC-S05 | PLAN-PROC04, PLAN-P4 Phase 4b |
| REQ-F12 (REQ-ID 範囲展開) | SPEC-CQ01 | PLAN-P4 Phase 4c |
| REQ-F13 (GATE_EVIDENCE マーカー) | SPEC-S10, SPEC-S15 | PLAN-EV01, PLAN-MAINT03 |
| REQ-F14 (進捗ログ自動記録) | SPEC-S11 | PLAN-MAINT03 |
| REQ-F15 (CQ-RO) | SPEC-CQ02 | PLAN-P4 Phase 4d |
| REQ-F16 (MAIN_REPO バリデーション) | SPEC-S16 | PLAN-P5 |

---

## 10. 変更履歴

- v0.1（2026-02-03 JST）: 旧版（Claude Code 作成、as-built 暫定版）
- v0.2（2026-02-04 JST）: Codex 版
- v1.0（2026-02-05 JST）: 正式版（Claude Code / Codex を統合し repo 実態に基づき再作成。Phase 体系化、標準手順明文化、失敗切り分け・保守手順追加、REQ↔SPEC↔PLAN 対応表追加）
- v1.1（2026-02-06 JST）: 未文書化機能 6 件の実装詳細追加（PLAN-MAINT03 自動更新パイプライン・進捗ログ書式、PLAN-MAINT02 プラグインソート、PLAN-PROC04 否定構文、PLAN-P4 Phase 4a-4c サブフェーズ追加、REQ↔SPEC↔PLAN 対応表に REQ-F09〜F14 追加）
- v1.2（2026-02-06 JST）: セキュリティ総合調査結果追加（PLAN-SEC01: 17 件の受容判定、リスクと対策テーブルにセキュリティ行追加、REQ↔SPEC↔PLAN 対応表に REQ-S05 追加）
- v1.3（2026-02-07 JST）: REQ-S02 強化実装追加（Phase 4d: CQ-RO チェック、Phase 4e: Phase 1 ro mount 検証統合、REQ↔SPEC↔PLAN 対応表に REQ-F15 追加）
- v1.4（2026-02-07 JST）: バグ修正 8 件の反映（Phase 4f 追加: verify_gate.sh 未知 Gate exit 1 化、run_tests.sh guard.sh パス統一、evidence.sh 階層+コメント修正、kit サマリ抽出修正、gate_a/b/g/i.sh 判定厳格化）
- v1.5（2026-02-07 JST）: Gate 動的スケーラビリティ対応（Phase 4g 追加: run_tests.sh A-I 固定 3 箇所→gate_registry.sh 動的検出に置換、tracker_updater.sh に Gate セクション自動生成 `_tu_auto_create_gate_section()` 追加、gate_registry.sh に Gate ID バリデーション追加〈`_gr_is_safe_gate_id()` ヘルパー、列挙時+source 前の 2 箇所で一貫適用〉、PLAN-MAINT01/03 にセクション自動生成・ID 制約手順追加）
- v1.6（2026-02-07 JST）: Codex 評価指摘 4 件修正（Phase 4h 追加: verify_all.sh に Gate 0 件ガード + SSOT MATCH 必須化〈fail-closed〉、gate_registry.sh unsafe ID を WARN→FATAL+exit 1 + `for→while IFS= read -r` 堅牢化）
- v1.7（2026-02-07 JST）: run_tests.sh Phase 2 Gate 0 件ガード追加（Phase 4i: プロセス置換 `< <(gr_list_gate_ids)` の exit code 非伝播による偽 PASS 防止）
- v1.8（2026-02-07 JST）: gate_a.sh/gate_b.sh req② の `repo_grep` 呼び出しバグ修正（Phase 4j: `-i` フラグ誤渡しにより引数ずれ→常時 FAIL を解消。9 PASS / 0 FAIL + SSOT MATCH 達成）
- v1.9（2026-02-07 JST）: Phase 5 lockdown/unlock 実装（PLAN-P5 完了: lockdown.sh quarantine 移動 + unlock.sh 二段階解除、SSOT verify_spec.md:93-108 準拠）+ MAIN_REPO バリデーション強化（REQ-F16/SPEC-S16: _validate_main_repo 4 段階検証 — SSOT sha256 照合で誤 repo 接続防止、find 全候補走査化）+ kit lockdown/unlock サブコマンド追加 + 未実装一覧 #1 解消 + リスクテーブル lockdown 行を「充足」に更新
- v2.2（2026-02-14 JST）: cf_/cf- プレフィックス除去 — SSOT 3 ファイル名・ツール参照を新名に更新。
- v2.1（2026-02-14 JST）: PLAN-PRE01 配置モデル明確化 — CF repo 内 `.gate-audit/` は snapshot と注記（CODEX F-02 対応）。
- v2.0（2026-02-14 JST）: 3 層リネーム + 構造簡素化（`.cfctx_verify` → `.gate-audit`、`.cfctx` → `.repo-id`、内部 CIQA → self-check〈ファイル・関数 9 件・変数 13 件・CLI `ciqa` → `self-check`〉、環境変数 `CFCTX_*` → `GATE_AUDIT_*` / `SC_*`、ディレクトリ 3 段→2 段簡素化、全 Phase・手順のパス名・コマンド例更新）
