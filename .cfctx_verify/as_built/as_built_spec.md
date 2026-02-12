# as-built 仕様書（正式版）— Temporary Verification Kit

version: 1.9
date: 2026-02-07
status: 正式版（v1.9: Phase 5 lockdown/unlock 実装 + MAIN_REPO バリデーション強化 — SSOT fingerprint 照合で誤 repo 接続防止）

---

## 0. 目的・位置づけ

本書は検証キットの **現状（as-built）仕様** を、実装に基づく事実として記述する。
ディレクトリ責務、`./kit` サブコマンド仕様、各スクリプトの入出力、Evidence フォーマット、CIQA 設定とチェック一覧を定義する。

- SSOT（運用の正）は `verify/verify_spec.md`。
- 対応要件は `as_built/as_built_requirements.md`（REQ-xxx）で参照。

---

## 1. ディレクトリ構造（as-built）

### SPEC-D01: ディレクトリ責務一覧

```
/home/masahiro/.cfctx_verify_root/.cfctx_verify/   <- KIT_ROOT
  kit                          <- 統合 CLI エントリポイント (kit:1-271)
  .gitignore                   <- git 除外設定
  SSOT/                        <- 本体 _handoff_check/ のスナップショット (3 ファイル)
    cf_handoff_prompt.md
    cf_update_runbook.md
    cf_task_tracker_v5.md
  context/                     <- 運用ルール・プロンプト
    run_rules.md               <- 運用ルール集 (run_rules.md:1-32)
    codex_high_prompt.md       <- Codex high 向けプロンプト
  tasks/                       <- トラッカー群 (6 ファイル)
    verify_task_tracker.md     <- Gate A-I 検証トラッカー
    test_task_tracker.md       <- テスト実行トラッカー
    as_built_task_tracker.md   <- as-built 作成トラッカー
    rebuild_task_tracker.md    <- 再構築タスク管理
    post_rebuild_task_tracker.md <- 再構築後タスク管理
    ciqa_task_tracker.md       <- CI/QA タスク管理
  as_built/                    <- as-built 文書 (要件/仕様/計画 + gate_map)
    as_built_requirements.md
    as_built_spec.md           <- 本書
    as_built_implementation_plan.md
    as_built_gate_map.md       <- Gate Map (根拠 file:line 付き)
  verify/                      <- SSOT verify_* のkit内参照コピー
    verify_requirements.md
    verify_spec.md
    verify_implementation_plan.md
  docs/                        <- 設計文書
    rebuild/                   <- 再構築設計 (3 ファイル)
      rebuild_requirements.md
      rebuild_spec.md
      rebuild_implementation_plan.md
    ciqa/                      <- CI/QA 設計 (4 ファイル)
      ciqa_requirements.md
      ciqa_spec.md
      ciqa_implementation_plan.md
      ciqa_plugin_guide.md
  config/                      <- 設定
    ciqa.conf                  <- CI/QA 設定 (config/ciqa.conf:1-22)
  scripts/                     <- スクリプト群
    verify_all.sh              <- Gate A-I 一括検証 (verify_all.sh:1-160)
    verify_gate.sh             <- 個別 Gate 検証 (verify_gate.sh:1-144)
    generate_handoff.sh        <- handoff 生成 (generate_handoff.sh:1-62)
    run_tests.sh               <- テストランナー Phase 1-3 (run_tests.sh:1-475)
    ciqa_runner.sh             <- CI/QA 実行器 (ciqa_runner.sh:1-401)
    lockdown.sh                <- 検証キット隔離 (lockdown.sh:1-97, Phase 5)
    unlock.sh                  <- 検証キット隔離解除 (unlock.sh:1-100, Phase 5)
    lib/
      evidence.sh              <- 共通関数 (証跡管理/判定/ファイル操作)
      ssot_check.sh            <- SSOT 整合比較
      gate_registry.sh         <- Gate 自動発見レジストリ
      handoff_builder.sh       <- latest.md 生成ロジック
      tracker_updater.sh       <- トラッカー自動更新
      ciqa_common.sh           <- CI/QA 共通ヘルパー
      gate_a.sh - gate_i.sh   <- 各 Gate 検証ロジック (9 ファイル)
      ciqa_checks/             <- CIQA チェックプラグイン
        cq_tracker.sh          <- CQ-TRK: トラッカー整合性
        cq_evidence.sh         <- CQ-EVC: Evidence chain
        cq_ssot.sh             <- CQ-SSOT: SSOT ドリフト
        cq_docs.sh             <- CQ-DOC: ドキュメント整合
        cq_lint.sh             <- CQ-LINT: スクリプト品質
        cq_naming.sh           <- CQ-NAME: 命名規約
        cq_regression.sh       <- CQ-REG: 回帰検出
        cq_readonly.sh         <- CQ-RO: Read-only Compliance
        _template.sh           <- プラグインテンプレート
  logs/
    evidence/                  <- 検証証跡 (タイムスタンプ付き)
      <YYYYMMDTHHMMSSZ>_<gate>/   <- ディレクトリ型 Evidence
      <YYYYMMDD-HHMMSS>_<purpose>.txt  <- ファイル型 Evidence
      INDEX.md                 <- Evidence インデックス
    ciqa/
      baseline/
        last_run.json          <- CIQA 回帰検出用ベースライン
  handoff/
    latest.md                  <- 引継ぎ文書 (自己完結型)
    latest.txt                 <- 同内容テキスト版
```

### SPEC-D02: 安全性制約

- 全検証スクリプトは read-only。write 操作は Kit 配下の `logs/evidence/`、`handoff/`、`tasks/`（トラッカー更新）のみ。
- git 操作は `status`, `diff`, `rev-parse`, `log`, `symbolic-ref`, `porcelain` に限定。
- 本体 repo への `cd` は禁止。全操作は `git -C` または絶対パス参照。
- 根拠: evidence.sh:250-310, handoff_builder.sh:70-128

### SPEC-D03: セキュリティ監査結果（2026-02-06 総合調査）

2026-02-06 実施のセキュリティ総合調査（シェルスクリプト 28 本 + 設定・データファイル）の結果、全 17 件を精査し全件 Pass と判定。Critical/High の脆弱性はゼロ。

#### セキュリティ姿勢（良好点）

| 項目 | 状態 | 根拠 |
|------|------|------|
| eval 不使用 | 確認済み（全スクリプト検索ゼロ） | コマンドインジェクション耐性 |
| set -euo pipefail | 全メインスクリプトで統一採用 | kit, verify_all.sh, verify_gate.sh, run_tests.sh, ciqa_runner.sh, generate_handoff.sh, evidence.sh |
| 変数クォート | 大部分がダブルクォート適切化 | シェル変数展開の安全性 |
| バッククォート | 不使用（$() 構文統一） | 可読性・安全性 |
| read-only 設計 | 本体 repo への書き込み・push なし | REQ-S02 準拠 |
| 機密情報 | パスワード・トークン・API キー漏洩なし | リポジトリ全体検索 |
| ファイル権限 | world-writable ファイルなし | 権限昇格防止 |
| /tmp 不使用 | 一時ファイルはキット管理下ディレクトリに限定 | シンボリックリンク攻撃防止 |

#### 受容判定サマリ

| 重要度 | 件数 | 判定 | 受容理由 |
|--------|------|------|----------|
| Critical | 0 | — | — |
| High | 0 | — | — |
| Medium | 3 | 全件 Pass | 固定値使用・信頼境界内・運用制約上の受容 |
| Low | 11 | 全件 Pass | 外部入力経路なし・自ユーザー権限内・衛生面 |
| Info | 3 | 全件 Pass | 実害なし |

#### Medium 指摘の詳細

| ID | 指摘 | ファイル | 受容理由 |
|----|------|----------|----------|
| Medium-1 | sudo mount に渡す CORE 変数の未検証 | tools/verify_ro_mount_nopasswd_template_v5.sh | tools/ テンプレート、単一ユーザー・ローカル環境で実害リスク極低 |
| Medium-2 | CIQA プラグインの無検証 source | scripts/ciqa_runner.sh:250 | ciqa_checks/ は git 管理下、外部配置シナリオなし（REQ-F10, SPEC-S09 準拠） |
| Medium-3 | awk 内への変数の安全でない展開 | scripts/verify_all.sh:68, verify_gate.sh:82 | $f は固定値ループ、ユーザー入力経路なし |

#### Low/Info 指摘の概要

| ID | 指摘 | 受容理由 |
|----|------|----------|
| Low-1 | $(command) for ループ分割 | v1.6 で `while IFS= read -r` に修正済み（gate_registry.sh） |
| Low-2 | 予測可能な一時ファイル名 | キット管理下、/tmp 不使用、単一ユーザー |
| Low-3 | gate_label パス未サニタイズ | 内部固定値 "gateA"〜"gateI" のみ |
| Low-4 | desc 変数パス未サニタイズ | ハードコード文字列、外部入力なし |
| Low-5 | シンボリックリンク未検証 cp | git 管理下、自ユーザー権限内 |
| Low-6 | CFCTX_SEARCH_PATH 未サニタイズ find | 読み取り専用操作のみ |
| Low-7 | CIQA_NAMING_PATTERN ReDoS | config は git 管理下、外部攻撃ベクターなし |
| Low-8 | config ファイル入力未検証 | case 文で既知キーのみ処理 |
| Low-9 | .gitignore 不足パターン | .env/Python 不使用、現構成で十分 |
| Low-10 | Git 追跡 .bak ファイル | 機密情報なし、衛生面のみ |
| Low-11 | Git 追跡 .pyc ファイル | Gate H 証跡として意図的保持 |
| Info-1 | repo_grep パターン引数 | 全呼び出し元が固定パターン |
| Info-2 | run_check 関数名衝突 | unset -f で管理済み |
| Info-3 | Markdown 実行権限 | シェル/カーネルが実行しない |

- **対応 REQ**: REQ-S05
- **根拠**: claude_codeの回答.txt（2026-02-06 セキュリティ総合調査レポート）

### SSOT との構造差分

| SSOT 仕様 (verify_spec.md) | as-built | 備考 |
|---|---|---|
| `scripts/verify.sh` | `verify_all.sh` + `verify_gate.sh` | 一括と個別に分離 |
| `scripts/collect_evidence.sh` | `scripts/lib/evidence.sh` | ライブラリ化 |
| `scripts/lockdown.sh` / `unlock.sh` | 実装済み (v1.9) | SSOT 準拠: quarantine 移動 + chmod go-rwx + LOCKED.flag + 二段階解除 |
| `logs/runs/<ts>/` | 未使用 | Evidence は `logs/evidence/` に直接保存 |
| `as_built/` ディレクトリ | 存在 | SSOT 仕様に記載なし |
| `docs/` ディレクトリ | 存在 | SSOT 仕様に記載なし |
| `config/` ディレクトリ | 存在 | SSOT 仕様に記載なし |
| `scripts/ciqa_runner.sh` | 存在 | SSOT 仕様に記載なし（CIQA は後続追加） |
| tasks/ に 1 ファイル | 6 ファイル | 追加トラッカー |

---

## 2. ./kit サブコマンド仕様

### SPEC-S01: ./kit 概要

- **ファイル**: `kit`（Kit root 直下、実行可能）
- **シバン**: `#!/usr/bin/env bash`
- **パス解決**: SCRIPT_DIR から KIT_ROOT を算出（kit:18-20）
- **ライブラリ依存**: handoff_builder.sh, tracker_updater.sh, gate_registry.sh を source（kit:23-25）
- **根拠**: kit:1-271

### SPEC-S02: ./kit verify [GATE...]

- **目的**: Gate 検証を実行する。
- **引数**: Gate 文字（A-I）を 0 個以上。省略時は全 Gate。
- **処理**:
  1. 引数なし → `verify_all.sh` を実行（kit:74）
  2. 引数あり → `verify_gate.sh` に引数を渡す（kit:77）
  3. 検証後に `generate_handoff.sh` を実行して latest.md を再生成（kit:83）
- **Exit code**: 0（全 PASS）/ 1（FAIL あり）
- **根拠**: kit:67-86

### SPEC-S03: ./kit verify 内部 — verify_all.sh

- **目的**: 自動発見された全 Gate を順次実行し、PASS/FAIL サマリを出力。
- **処理**:
  1. lib/ 配下のライブラリを source（verify_all.sh:22-25）
  2. `gr_source_all_gates` で全 Gate を source（verify_all.sh:25）
  3. 本体 repo 発見・検証（verify_all.sh:28-35）
  4. Gate ID リストを `gr_list_gate_ids` で取得（verify_all.sh:37）
  5. **Gate 0 件ガード**: Gate が 0 件の場合は即 FATAL + exit 1（verify_all.sh:39-42）
  6. repo 参照証跡を記録（verify_all.sh:58-77）
  7. SSOT 比較を実行（verify_all.sh:82-95）
  8. 各 Gate の `verify_gate_<id>()` を順次実行（verify_all.sh:100-111）
  9. PASS/FAIL サマリ出力（verify_all.sh:113-148）
- **Exit 判定**: 全 Gate PASS **かつ** SSOT MATCH の場合のみ exit 0。Gate FAIL または SSOT DIFFER のいずれかで exit 1（verify_all.sh:155-158）。
- **出力**: stdout（Gate 別 PASS/FAIL + 総合サマリ）、`logs/evidence/` 配下
- **根拠**: verify_all.sh:1-160

### SPEC-S04: ./kit test [PHASE]

- **目的**: テスト実行（Phase 1/2/3/all）。
- **引数**: 1, 2, 3, all（既定: all）
- **処理**:
  1. `run_tests.sh` にフェーズ引数を渡す（kit:104）
  2. テスト後に `generate_handoff.sh` を実行（kit:109）
- **Phase 内容**:
  - **Phase 1** (run_tests.sh:44-182): 環境前提確認（Kit 位置、repo clean、Repo Lock、read-only チェック、OS レベル ro mount 検証〈オプション〉）+ 最小スモーク（verify_all.sh 実行）
  - **Phase 2** (run_tests.sh:200-281): 各 Gate を個別に `verify_gate.sh` で再検証。Gate 一覧は `gate_registry.sh` の `gr_list_gate_ids()` で動的取得（A-I 固定ではない）。Gate 0 件時は即 FAIL（プロセス置換の exit code 非伝播による偽 PASS を防止、run_tests.sh:217-220）。
  - **Phase 3** (run_tests.sh:277-425): E2E 全体導線（構造チェック、SSOT 比較、verify_all.sh、handoff 生成）+ 再現性確認（2 回実行の結果一致）。再現性比較の Gate パターンも `gr_list_gate_ids()` で動的生成。
- **Evidence**: `logs/evidence/<ts>_test_phase<N>.txt`
- **Exit code**: 0（全 PASS）/ 1（FAIL あり）
- **根拠**: kit:88-112, run_tests.sh:1-513, gate_registry.sh:36-47

### SPEC-S05: ./kit ciqa [CHECK...]

- **目的**: CI/QA チェックを実行する。
- **引数**: チェック名（tracker/evidence/ssot/docs/lint/naming/regression）を 0 個以上。省略時は全チェック。
- **処理**:
  1. `ciqa_runner.sh` に引数を渡す（kit:124）
  2. チェック後に `generate_handoff.sh` を実行（kit:129）
- **チェック決定優先度**: CLI 引数 > config `checks=` > all（ciqa_runner.sh:117-221）
- **config negation（否定構文）**: `checks=` フィールドで `!` プレフィックスによる除外指定をサポート（ciqa_runner.sh:146-193）。
  - **構文**: `checks=!lint,!naming` → lint と naming 以外の全チェックを実行
  - **排他ルール**: 正の指定（`tracker`）と負の指定（`!lint`）の混在はエラー（ciqa_runner.sh:159-162）
  - **未知チェック**: 否定モードで未知のキーが指定された場合は WARN を出力して無視（ciqa_runner.sh:178-179）
  - **解決フロー**:
    1. 全 config 項目を走査し `!` の有無を判定（ciqa_runner.sh:147-157）
    2. 否定モード: 全チェックから除外対象を除いたリストを返す（ciqa_runner.sh:164-193）
    3. 正モード: 指定されたチェックのみを返す（ciqa_runner.sh:194-216）
- **Exit code**: 0（全 PASS）/ 1（FAIL あり）
- **根拠**: kit:114-132, ciqa_runner.sh:1-401

### SPEC-S06: ./kit all

- **目的**: verify → test → ciqa → handoff の一気通貫実行。
- **処理** (kit:134-186):
  1. Step 1/4: `verify_all.sh`
  2. Step 2/4: `run_tests.sh all`（存在しない場合は WARN でスキップ）
  3. Step 3/4: `ciqa_runner.sh all`（存在しない場合は WARN でスキップ）
  4. Step 4/4: `generate_handoff.sh`
- **Exit code**: 0（全 PASS）/ 1（FAIL あり。FAIL があっても最後の handoff まで実行する）
- **根拠**: kit:134-186

### SPEC-S07: ./kit status

- **目的**: 全トラッカーの進捗サマリを表示（副作用なし）。
- **処理** (kit:188-244):
  1. 6 トラッカーを走査（Verify, Test, As-built, Rebuild, PostRebld, CIQA）
  2. `[x]` と `[ ]` をカウントし、パーセンテージとステータス（ALL_PASS/HAS_FAIL/IN_PROGRESS/EMPTY）を算出
- **出力例**:
  ```
  === Kit Status ===
    Verify:    33/33 (100%) ALL_PASS
    Test:       6/6  (100%) ALL_PASS
    CIQA:       0/N  (  0%) IN_PROGRESS
  ```
- **根拠**: kit:188-244

### SPEC-S08: Gate 自動発見（gate_registry.sh）

- **目的**: `scripts/lib/gate_*.sh` を glob で取得し、Gate ID と verify 関数を解決する。
- **API**:
  - `_gr_is_safe_gate_id(id)`: Gate ID が安全か判定（`^[a-z0-9_]+$`）。関数名・正規表現の両方で安全な文字のみ許容（gate_registry.sh:16-19）
  - `gr_list_gate_scripts()`: Gate スクリプトの絶対パスを列挙（gate_registry.sh:24-31）
  - `gr_list_gate_ids()`: Gate ID（大文字）を列挙。`_gr_is_safe_gate_id()` で検証し、unsafe ID は **FATAL + exit 1**（gate_registry.sh:36-47）。内部で `while IFS= read -r` を使用（空白パス安全）。
  - `gr_gate_func_for_id <ID>`: Gate ID から関数名（`verify_gate_<id>`）を返す（gate_registry.sh:53-57）
  - `gr_source_all_gates()`: 全 Gate スクリプトを source し関数存在を検証。source 前に `_gr_is_safe_gate_id()` で ID を検証し、unsafe ID は **FATAL + exit 1**（gate_registry.sh:62-78）。内部で `while IFS= read -r` を使用（空白パス安全）。
- **Gate ID 制約**: `[a-zA-Z0-9_]` のみ許容。正規表現メタ文字（`+`, `.`, `*`, `(` 等）を含むファイル名は即座に FATAL エラーとなる（`grep -E` パターン埋め込み時の誤マッチ・パターン破壊を防止、CI 上で silently skip されることを防止）。
- **新 Gate 追加方法**: `scripts/lib/gate_<id>.sh` を作成し `verify_gate_<id>()` を定義するだけ。
- **根拠**: gate_registry.sh:1-79

### SPEC-S09: CIQA プラグイン自動発見

- **目的**: `scripts/lib/ciqa_checks/cq_*.sh` を glob で取得し、メタデータからチェックを登録する。
- **メタデータヘッダ（必須、先頭 30 行以内）**:
  ```bash
  # @check_key: tracker       # config/CLI 識別子
  # @check_id: CQ-TRK         # 短縮 ID
  # @check_display: Tracker Integrity  # 表示名
  # @check_order: 10          # ソート順（小さいほど先。既定 50）
  ```
- **関数契約**: 各スクリプトは `run_check()` を定義。戻り値 0=PASS, 1=FAIL。stdout がチェック詳細。
- **ソートアルゴリズム（プラグインソート）**:
  1. 各プラグインの `@check_order` 値（既定 50）と `@check_key` を `order:key` ペアとして収集（ciqa_runner.sh:95-98）
  2. `sort -t: -k1,1n -k2,2` で数値昇順ソート → 同一 order 内はキー名アルファベット順で安定ソート（ciqa_runner.sh:104）
  3. 結果を `AVAILABLE_CHECKS` 配列に格納し、この順で実行される
  - 現在のソート順: tracker(10) → evidence(20) → readonly(15) → ssot(30) → docs(40) → lint(50) → naming(50) → regression(60)
  - **新プラグイン追加時**: `@check_order` を適切に設定することで任意の位置に挿入可能
- **根拠**: ciqa_runner.sh:48-107

---

## 3. 主要スクリプト入出力

### SPEC-S10: scripts/lib/evidence.sh

- **目的**: 全 Gate 検証の共通基盤（証跡管理・ファイル操作・判定記録）。
- **提供関数**:

| 関数 | 用途 | 根拠 |
|------|------|------|
| `_validate_main_repo(candidate)` | 候補 repo の正当性を 4 段階検証（.git + _handoff_check/ + 構造マーカー + SSOT sha256 照合） | evidence.sh:17-52 |
| `discover_main_repo()` | 本体 repo パスを自動発見（候補リスト + find フォールバック、全候補を `_validate_main_repo` で検証） | evidence.sh:60-97 |
| `ts_utc()` / `ts_jst()` / `ts_label()` | タイムスタンプ生成 | evidence.sh:41-43 |
| `init_evidence(gate_label)` | 証跡ディレクトリ初期化（meta.txt, checksums.sha256, commands.txt 作成） | evidence.sh:47-92 |
| `record_ref(rel_path)` | 参照ファイルを references/ にコピー＋sha256 記録（重複スキップ） | evidence.sh:100-126 |
| `record_cmd(desc)` | 実行コマンドを commands.txt に記録 | evidence.sh:129-132 |
| `run_check(desc, cmd...)` | チェック実行＋出力キャプチャ | evidence.sh:138-162 |
| `write_judgement(PASS\|FAIL, reason, label)` | 判定を judgement.txt に記録＋stdout 出力 | evidence.sh:166-190 |
| `gate_summary(label, pass, fail, total)` | Gate 総合判定（checksums 検算含む）+ GATE_EVIDENCE マーカー出力 | evidence.sh:196-251 |
| `check_file_exists(rel)` | repo 内ファイル存在確認＋参照記録 | evidence.sh:250-264 |
| `check_dir_exists(rel)` | repo 内ディレクトリ存在確認 | evidence.sh:267-279 |
| `repo_grep(pattern, rel)` | repo 内ファイル検索（安全、|| return 1） | evidence.sh:284-295 |
| `repo_grep_capture(pattern, rel)` | repo 内ファイル検索（結果取得） | evidence.sh:300-310 |
| `repo_file_count(rel_dir)` | ディレクトリ内ファイル数 | evidence.sh:313-321 |

#### GATE_EVIDENCE 出力マーカー（evidence.sh:246-248）

`gate_summary()` は判定出力に加え、トラッカー自動更新（SPEC-S15）のためのマーカー行を stdout に出力する。

- **書式**: `GATE_EVIDENCE:<Gate_ID>:<relative_evidence_path>`
- **例**: `GATE_EVIDENCE:A:logs/evidence/20260205T200000Z_gateA`
- **Gate ID 抽出**: Gate ラベル（例: `Gate A`）の末尾空白後の文字列をパラメータ展開 `${gate_label##* }` で取得（evidence.sh:247）
- **パス**: `${EVIDENCE_DIR#${KIT_ROOT}/}` で KIT_ROOT 相対パスに変換（evidence.sh:248）
- **用途**: `kit:35-41` がこのマーカーを `grep '^GATE_EVIDENCE:'` でパースし、`update_verify_tracker()` に渡す
- **根拠**: evidence.sh:246-248, kit:30-48

### SPEC-S11: scripts/lib/tracker_updater.sh

- **目的**: トラッカー自動更新。
- **提供関数**:

| 関数 | 用途 | 根拠 |
|------|------|------|
| `update_verify_tracker(gate, verdict, evidence_path)` | verify_task_tracker.md の Gate セクションを更新（セクション未存在時は自動生成） | tracker_updater.sh:155-169 |
| `update_test_tracker(phase, verdict, evidence_path)` | test_task_tracker.md の Phase セクションを更新 | tracker_updater.sh:181-195 |
| `append_progress_log(tracker_file, message)` | Progress Log に追記 | tracker_updater.sh:206-228 |
| `_tu_auto_create_gate_section(tracker, gate)` | 新 Gate のトラッカーセクションを自動生成（`## Progress Log` の前に挿入） | tracker_updater.sh:110-143 |

- **更新ロジック**: awk でセクション内の `- [ ]` を `- [x]` に変換し、判定/Evidence/日時メタデータを挿入（tracker_updater.sh:83-103）。
- **セクション自動生成**: `update_verify_tracker()` 呼出時にセクション `### Gate <ID>` が存在しない場合、`_tu_auto_create_gate_section()` が標準テンプレート（要件①②③チェックボックス 3 項目）でセクションを自動作成する。`## Progress Log` の直前に挿入される。

#### 自動更新メカニズム（SPEC-S15 参照）

`tracker_updater.sh` の関数群は `kit` スクリプトから自動的に呼び出される。ユーザの手動編集は不要。

- **更新契約**: `[x]` 変換時に以下 3 行のインデント付きメタデータを挿入:
  ```markdown
  - [x] チェック項目
    - 判定: PASS
    - Evidence: logs/evidence/20260205T200000Z_gateA
    - 日時: 2026-02-05 20:00 JST
  ```

#### Progress Log 自動記録（append_progress_log）

- **書式**: `- YYYY-MM-DD HH:MM JST | <message>`
- **例**: `- 2026-02-05 20:01 JST | kit verify: Total: 9/9 PASS`
- **自動作成**: `## Progress Log` セクションが存在しない場合、ファイル末尾に自動追加（tracker_updater.sh:179-181）
- **タイムゾーン**: JST 固定（`TZ=Asia/Tokyo`、`_tu_ts_jst_short()`）
- **呼出元**: `kit:43-47`（verify 後）、`kit:66-70`（test 後）

### SPEC-S12: scripts/lib/handoff_builder.sh

- **目的**: `handoff/latest.md` の各セクションを生成する関数群。
- **提供関数**:

| 関数 | セクション | 根拠 |
|------|-----------|------|
| `emit_meta()` | ## 1. Meta（Kit branch/HEAD/timestamp） | handoff_builder.sh:49-65 |
| `emit_main_repo_snapshot()` | ## 2. Main Repo Snapshot（HEAD/branch/status/lock/SSOT） | handoff_builder.sh:70-128 |
| `emit_trackers_digest()` | ## 3. Trackers Digest（6 トラッカーの進捗集計） | handoff_builder.sh:201-229 |
| `emit_evidence_index()` | ## 4. Evidence Index（全件の目的/判定/sha256/パス） | handoff_builder.sh:330-376 |
| `emit_kit_files()` | ## 5. Kit Files（固定リスト） | handoff_builder.sh:381-393 |
| `emit_commands()` | ## 6. Commands（使い方） | handoff_builder.sh:398-409 |
| `emit_notes()` | ## 7. Notes | handoff_builder.sh:414-421 |

### SPEC-S13: scripts/lib/ssot_check.sh

- **目的**: Kit `SSOT/` と本体 `_handoff_check/` の sha256 比較。
- **入力**: KIT_ROOT, MAIN_REPO（親スクリプトから継承）
- **出力**: `$EVIDENCE_DIR/ssot_comparison.txt`
- **戻り値**: 0=MATCH, 1=DIFFER
- **根拠**: ssot_check.sh:8-83

### SPEC-S14: scripts/lib/ciqa_common.sh

- **目的**: CI/QA 固有のヘルパー関数。
- **提供関数**:

| 関数 | 用途 | 根拠 |
|------|------|------|
| `ciqa_ts_jst()` / `ciqa_ts_utc()` / `ciqa_ts_label()` | タイムスタンプ | ciqa_common.sh:11-13 |
| `ciqa_emit_header(check_name, check_id)` | Evidence ヘッダ出力 | ciqa_common.sh:17-26 |
| `ciqa_emit_verdict(verdict, reason)` | 判定行出力 | ciqa_common.sh:30-36 |
| `ciqa_count_checked(tracker_file)` | `[x]` カウント | ciqa_common.sh:40-43 |
| `ciqa_count_unchecked(tracker_file)` | `[ ]` カウント | ciqa_common.sh:46-49 |
| `ciqa_sha16(file)` | sha256 先頭 16 文字 | ciqa_common.sh:52-54 |
| `ciqa_load_config()` | config/ciqa.conf をパースして変数に設定 | ciqa_common.sh:60-104 |

### SPEC-S15: kit トラッカー自動更新パイプライン

- **目的**: `./kit verify` / `./kit test` の実行出力を自動パースし、トラッカーを手動編集なしで最新状態に更新する。
- **処理フロー（verify）** (kit:27-48):
  1. `verify_all.sh` / `verify_gate.sh` の全出力をキャプチャ（kit:120-123）
  2. `_kit_update_verify_from_output()` が出力から `GATE_EVIDENCE:<ID>:<path>` マーカーを `grep '^GATE_EVIDENCE:'` で抽出（kit:35-41）
  3. 各マーカーの Gate ID に対応する判定を `grep "  Gate ${gate}: "` で取得し PASS/FAIL を抽出
  4. `update_verify_tracker(gate, verdict, evidence_path)` を呼出（kit:39）
  5. `Total:` サマリ行を抽出し `append_progress_log()` で進捗ログに追記（kit:43-47）
- **処理フロー（test）** (kit:52-71):
  1. `run_tests.sh` の全出力をキャプチャ（kit:155）
  2. `_kit_update_test_from_output()` が正規表現 `Phase ([0-9]+): (PASS|FAIL)\s+Evidence: ([^ ]+)` でパース（kit:58）
  3. `update_test_tracker(phase, verdict, evidence_path)` を呼出（kit:62）
  4. `Total:` サマリ行を抽出し `append_progress_log()` で進捗ログに追記（kit:66-70）
- **エラーハンドリング**: 全呼出に `|| true` を付与し、トラッカー更新失敗が検証結果に影響しない。
- **根拠**: kit:27-71, tracker_updater.sh:41-188

### SPEC-S16: MAIN_REPO バリデーション（_validate_main_repo）

- **目的**: `discover_main_repo()` の候補 repo が実際に cf-context-framework であることを検証し、誤った repo への接続を防止する。
- **バリデーション手順**（evidence.sh:17-52）:
  1. `.git` ディレクトリ存在確認（git リポジトリであること）
  2. `_handoff_check/` ディレクトリ存在確認（SSOT ソースの存在）
  3. 構造マーカー確認（`WORKFLOW/`、`controller/`、`rules/` のいずれか存在）
  4. **SSOT fingerprint 照合**: Kit `SSOT/` の 3 ファイル（cf_handoff_prompt.md, cf_update_runbook.md, cf_task_tracker_v5.md）の sha256 と候補 repo `_handoff_check/` の sha256 を比較。全ファイル一致で PASS、1 ファイルでも不一致なら候補を棄却。
- **候補走査**: `discover_main_repo()` のステップ 4（CFCTX_SEARCH_PATH 検索）は `find` の全結果を走査し、最初にバリデーションを通過した候補を採用（`head -1` → `while read` ループに変更）。
- **リスク緩和効果**: 同一検索パス配下に複数の cf-context-framework クローンが存在する場合でも、Kit の SSOT スナップショットと SHA が一致する repo のみが選択される。
- **対応 REQ**: REQ-F16
- **根拠**: evidence.sh:17-97

### SPEC-S17: ./kit lockdown（検証キット隔離 — Phase 5）

- **目的**: 検証完了後に検証キットを隔離し、通常運用からアクセスしにくくする。
- **処理** (lockdown.sh:1-97):
  1. KIT_ROOT の存在確認（不在で FATAL）
  2. LOCKED.flag が既に存在しないことを確認（二重ロック防止）
  3. Quarantine 先ディレクトリが存在しないことを確認
  4. 確認プロンプト（対話時）または `LOCKDOWN_CONFIRM=yes`（非対話時）
  5. `.cfctx_quarantine/verify-<timestamp>/` を作成し KIT_ROOT を移動
  6. `chmod -R go-rwx` を適用（owner のみアクセス可）
  7. `LOCKED.flag`（解除判定メタデータ）と `README_LOCKED.md`（ロック説明）を作成
- **Exit code**: 0（成功）/ 1（中断またはエラー）
- **SSOT 準拠**: verify_spec.md:96-101

### SPEC-S18: ./kit unlock（検証キット隔離解除 — Phase 5）

- **目的**: 隔離された検証キットを元のパスに復元する。
- **二段階解除** (unlock.sh:1-100):
  1. **Stage 1**: `LOCKED.flag` の存在確認（不在で中断）+ `source_path` メタデータ読取
  2. **Stage 2**: パスフレーズ確認（固定フレーズ `UNLOCK-VERIFY-KIT`、対話時は入力、非対話時は `UNLOCK_PASSPHRASE` 環境変数）
- **復元処理**:
  1. `chmod -R u+rwX` で権限を復元
  2. `LOCKED.flag` と `README_LOCKED.md` を削除
  3. Kit を元のパスに移動（元パスが既に存在する場合は FATAL）
  4. Quarantine ベースが空なら削除
- **Exit code**: 0（成功）/ 1（中断またはエラー）
- **SSOT 準拠**: verify_spec.md:103-108

---

## 4. Evidence フォーマット

### SPEC-E01: ディレクトリ型 Evidence（Gate 検証用）

```
logs/evidence/<YYYYMMDTHHMMSSZ>_<gate_label>/
  meta.txt              <- タイムスタンプ、repo HEAD、repo status
  checksums.sha256      <- 参照ファイルの sha256 (references/ 配下パス)
  commands.txt          <- 実行コマンドログ
  judgement.txt         <- req1/req2/req3 + 総合判定
  req1_summary.txt      <- 要件1 結果
  req2_consistency.txt  <- 要件2 結果
  req3_functional.txt   <- 要件3 結果
  references/           <- 参照した本体 repo ファイルのコピー
```

根拠: evidence.sh:47-92, evidence.sh:100-126

### SPEC-E02: ファイル型 Evidence（テスト/CIQA 用）

```
logs/evidence/<YYYYMMDD-HHMMSS>_<purpose>.txt
```

- ヘッダ: `=== <Purpose> ===` + Timestamp + VERDICT
- 根拠: run_tests.sh:27-36, ciqa_common.sh:17-26

### SPEC-E03: Checksum 検算

- `gate_summary()` 内で `sha256sum -c checksums.sha256` を実行。
- `NOT_FOUND` 行はフィルタして検算対象外。
- checksum 不一致 → 当該 Gate は FAIL。
- 根拠: evidence.sh:204-214

### SPEC-E04: CIQA Evidence

```
logs/evidence/<YYYYMMDD-HHMMSS>_ciqa_<check_id>.txt
```

- ヘッダ書式: `=== CIQA: <Check Name> ===` + Timestamp (JST/UTC) + Check ID + VERDICT
- 根拠: ciqa_common.sh:17-26, ciqa_runner.sh:265-278

---

## 5. CIQA チェック一覧

| Check Key | Check ID | 表示名 | 概要 | 根拠 |
|-----------|----------|--------|------|------|
| tracker | CQ-TRK | Tracker Integrity | 全 `[x]` に判定・Evidence・日時があること | cq_tracker.sh |
| evidence | CQ-EVC | Evidence Chain | トラッカー参照の Evidence が実在すること | cq_evidence.sh |
| ssot | CQ-SSOT | SSOT Drift | Kit SSOT/ と repo _handoff_check/ の sha256 一致 | cq_ssot.sh |
| docs | CQ-DOC | Document Consistency | req ↔ spec のセクション対応（REQ-ID 範囲展開対応） | cq_docs.sh |
| lint | CQ-LINT | Script Quality | shellcheck (warning レベル以上) | cq_lint.sh |
| naming | CQ-NAME | Naming Convention | Evidence ファイル名が規約準拠 | cq_naming.sh |
| regression | CQ-REG | Regression Detection | 前回 PASS -> 今回 FAIL の検出 | cq_regression.sh |
| readonly | CQ-RO | Read-only Compliance | gate/verify スクリプトに MAIN_REPO への write 操作がないこと | cq_readonly.sh |

### SPEC-CQ01: CQ-DOC REQ-ID 範囲展開

CQ-DOC チェック（cq_docs.sh）は仕様書内の REQ-ID 範囲記法を自動展開する。

- **対象パターン**: `REQ-<PREFIX><START>[〜~]<PREFIX?><END>`（cq_docs.sh:99）
  - 例: `REQ-R01〜R07`, `REQ-CQ01~CQ08`, `REQ-F09〜F14`
- **展開ロジック** (cq_docs.sh:84-99):
  1. 正規表現 `REQ-[A-Z]+[0-9]+[〜~][A-Z]*[0-9]+` で範囲記法を検出
  2. プレフィックス（`REQ-` 後の英字部分）を `\K[A-Z]+` で抽出
  3. 開始番号・終了番号を抽出し `10#` 演算で整数化
  4. ゼロパディング幅を開始番号の桁数 `${#snum}` から算出
  5. `for ((n=s; n<=e; n++))` でループし `printf "%0${w}d"` でパディング付き ID を生成
- **文字サポート**: `〜`（全角チルダ U+301C）と `~`（半角チルダ U+007E）の両方を認識
- **用途**: 仕様書が `REQ-F09〜F14` と一括参照している場合、要件書の REQ-F09, F10, F11, F12, F13, F14 の全件カバーを検証
- **根拠**: cq_docs.sh:84-99

### SPEC-CQ02: CQ-RO Read-only Compliance チェック

CQ-RO チェック（cq_readonly.sh）は gate/verify スクリプト群を対象に、本体 repo への書き込み操作が存在しないことを静的に検証する。

- **スキャン対象**: gate_*.sh、verify_all.sh、verify_gate.sh、evidence.sh、run_tests.sh、ciqa_runner.sh
- **検出パターン（13 種）**:
  1. `git push/commit/add/reset/clean/checkout/merge/rebase/stash`
  2. `git -C ... push/commit/add/reset/clean/checkout`
  3. リダイレクト `>` / `>>` で `$MAIN_REPO` への書き込み
  4. `tee/cp/mv/rm/mkdir/touch/chmod/chown/sed -i` で `$MAIN_REPO` を対象とするもの
- **除外フィルタ**: コメント行（`#` 先頭）、文字列リテラル内（`details+=`、`output+=`、`echo`）は検出対象外
- **判定**: 全スキャン対象で書き込みパターンが 0 件なら PASS、1 件以上なら FAIL
- **メタデータ**: `@check_key: readonly`, `@check_id: CQ-RO`, `@check_order: 15`
- **対応 REQ**: REQ-F15, REQ-S02
- **根拠**: cq_readonly.sh:1-127

### CIQA 設定（config/ciqa.conf）

```ini
checks=all                    # 実行チェック (all / 個別列挙 / !除外)
lint_severity=warning         # shellcheck 閾値
regression_baseline_dir=logs/ciqa/baseline  # ベースライン保存先
tracker_files=tasks/verify_task_tracker.md,...  # 対象トラッカー (6 ファイル)
lint_targets=scripts/*.sh,...                    # lint 対象 glob
naming_pattern=^[0-9]{8}[-T][0-9]{6}Z?_        # Evidence 命名 PCRE
doc_pairs=docs/rebuild/...:...,docs/ciqa/...:...  # doc 整合ペア
```

根拠: config/ciqa.conf:1-22, ciqa_common.sh:60-104

---

## 6. Gate 検証ロジック共通パターン

### SPEC-G01: Gate スクリプト構造

各 `scripts/lib/gate_<id>.sh` は以下のパターンに従う（gate_a.sh:5-152 を代表例として）:

1. `verify_gate_<id>()` 関数を 1 つ定義
2. `init_evidence("gate<ID>")` で証跡ディレクトリを初期化
3. **req1（機能要約）**: 対象アーティファクトの存在確認・内容チェック → `write_judgement`
4. **req2（体系整合）**: クロスリファレンス（GATES.md, runbook, tracker）→ `write_judgement`
5. **req3（機能性）**: ファイル存在・非空・構造チェック → `write_judgement`
6. `gate_summary("Gate <ID>", pass, fail, total)` で総合判定（checksums 検算含む）
7. 最終行の stdout 出力が `PASS` または `FAIL`

### SPEC-G02: Gate 一覧と対象

| Gate | テーマ | 主な対象アーティファクト |
|------|--------|------------------------|
| A | Task Lists Agreement | ARTIFACTS/TASK_LISTS.md |
| B | Workflow Definition | WORKFLOW/GATES.md |
| C | Adapter Reference | アダプタ参照整合 |
| D | Audit Gate | 監査ゲート |
| E | Language Policy | 言語ポリシー |
| F | Framework Consistency | フレームワーク整合性 |
| G | Log Navigation | ログ導線（索引/ログ/ルール） |
| H | Handoff Check | Handoff 整合 |
| I | Integration Gate | 統合ゲート |

---

## 7. handoff/latest.md セクション構成

latest.md は以下の 7 セクションで構成される（handoff_builder.sh に基づく）:

| # | セクション | 内容 | 根拠 |
|---|-----------|------|------|
| 1 | Meta | 生成日時、Kit branch/HEAD | handoff_builder.sh:49-65 |
| 2 | Main Repo Snapshot | path, HEAD, branch, status, repo_lock, SSOT fingerprint, SSOT match | handoff_builder.sh:70-128 |
| 3 | Trackers Digest | 6 トラッカーの進捗（完了/総数/未完了項目） | handoff_builder.sh:201-229 |
| 4 | Evidence Index | 全 Evidence の一覧（目的/コマンド/判定/sha256/パス） | handoff_builder.sh:330-376 |
| 5 | Kit Files | SSOT / verify / context の固定リスト | handoff_builder.sh:381-393 |
| 6 | Commands | ./kit のサブコマンド一覧 | handoff_builder.sh:398-409 |
| 7 | Notes | 安全性・運用上の注意 | handoff_builder.sh:414-421 |

---

## 8. 差分/曖昧/未実装一覧

| # | 項目 | SSOT (verify_spec.md) | as-built | 影響度 |
|---|------|----------------------|----------|--------|
| 1 | verify.sh | 単一スクリプト (verify_spec.md:29) | verify_all.sh + verify_gate.sh に分離 | なし（機能向上） |
| 2 | collect_evidence.sh | 独立スクリプト (verify_spec.md:30) | lib/evidence.sh にライブラリ化 | なし（機能向上） |
| 3 | lockdown.sh / unlock.sh | 定義あり (verify_spec.md:93-108) | 実装済み (v1.9) | 解消 |
| 4 | logs/runs/ | 定義あり (verify_spec.md:36-38) | 未使用 | なし |
| 5 | CFCTX_VERIFY_ROOT 強制 | 全スクリプト必須 (verify_spec.md:12) | generate_handoff.sh のみ（SCRIPT_DIR フォールバックあり） | 低 |
| 6 | verify.sh --mode smoke/full | 定義あり (verify_spec.md:78) | 未実装（verify_all.sh は常に全 Gate 実行） | 低 |
| 7 | README.md | 必須 (verify_spec.md:17) | Kit root に不在 | 低 |

---

## 9. 変更履歴

- v0.1（2026-02-03 JST）: 旧版（Claude Code 作成、as-built 暫定版）
- v0.2（2026-02-04 JST）: Codex 版
- v1.0（2026-02-05 JST）: 正式版（Claude Code / Codex を統合し repo 実態に基づき再作成。SPEC 番号体系化、全スクリプト入出力明文化、CIQA チェック一覧追加）
- v1.1（2026-02-06 JST）: 未文書化機能 6 件の仕様追加（SPEC-S15: トラッカー自動更新パイプライン、SPEC-CQ01: REQ-ID 範囲展開、SPEC-S05 否定構文詳細、SPEC-S09 プラグインソート詳細、SPEC-S10 GATE_EVIDENCE マーカー、SPEC-S11 進捗ログ詳細）
- v1.2（2026-02-06 JST）: セキュリティ総合調査結果の仕様追加（SPEC-D03: 17 件の受容判定サマリ、Medium 指摘詳細、セキュリティ姿勢の良好点）
- v1.3（2026-02-07 JST）: CQ-RO チェック仕様追加（SPEC-CQ02: Read-only Compliance、13 種 write パターン検出）、Phase 1 ro mount 検証統合、CIQA チェック一覧に CQ-RO 追加、ソート順更新
- v1.4（2026-02-07 JST）: バグ修正 8 件の反映（verify_gate.sh 未知 Gate exit 1 化、run_tests.sh cf-guard.sh パス統一、evidence.sh discover_main_repo 階層修正+コメント修正、kit テストサマリ抽出修正、gate_a/b req② 代替 PASS 分岐削除、gate_g req② LOG-009 両方必須化、gate_i req① 閾値 ==6 化）
- v1.5（2026-02-07 JST）: Gate 動的スケーラビリティ対応（run_tests.sh の A-I 固定 3 箇所を gate_registry.sh 動的検出に置換、tracker_updater.sh に Gate セクション自動生成機能 `_tu_auto_create_gate_section()` 追加、gate_registry.sh に Gate ID バリデーション追加〈`_gr_is_safe_gate_id()` ヘルパー、列挙時+source 前の 2 箇所で一貫適用〉）
- v1.6（2026-02-07 JST）: Codex 評価指摘 4 件修正（SPEC-S03: verify_all.sh に Gate 0 件ガード追加 + SSOT MATCH を exit 0 の必須条件化、SPEC-S08: gate_registry.sh の unsafe ID を WARN→FATAL+exit 1 に昇格 + `for f in $(...)` を `while IFS= read -r f` に変更して空白パス安全化）
- v1.7（2026-02-07 JST）: run_tests.sh Phase 2 Gate 0 件ガード追加（SPEC-S04: プロセス置換 `< <(gr_list_gate_ids)` の exit code 非伝播による偽 PASS を防止。Gate 配列が空の場合は即 FAIL）
- v1.8（2026-02-07 JST）: gate_a.sh:90/gate_b.sh:57 の `repo_grep` 呼び出しバグ修正（SPEC-S06/S07: `-i` フラグが `repo_grep` 非対応のため引数が 1 つずれ常に FAIL。`-i` 除去で解消）
- v1.9（2026-02-07 JST）: Phase 5 lockdown/unlock 実装（SPEC-S17/S18: quarantine 移動 + 二段階解除、SSOT 準拠）+ MAIN_REPO バリデーション強化（SPEC-S16: _validate_main_repo 4 段階検証 — SSOT sha256 照合で誤 repo 接続防止、find 全候補走査化）+ SPEC-D01 ディレクトリ構造に lockdown.sh/unlock.sh 追加 + SSOT 差分テーブル更新（lockdown 行を「実装済み」に変更）
