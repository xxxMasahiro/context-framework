# as-built 要件定義書（正式版）— Temporary Verification Kit

version: 2.2
date: 2026-02-14
status: 正式版（v2.2: cf_/cf- プレフィックス除去 — SSOT 3 ファイル名・ツール参照を新名に更新）

---

## 0. 目的・位置づけ

本書は検証キット（Temporary Verification Kit）の **現状（as-built）要件** を、リポジトリ内のスクリプト・文書・トラッカーから読み取れる事実に基づいて記述する。

- 「こうあるべき（to-be）」ではなく「こうなっている（as-is）」を記載する。
- SSOT（運用の正）は `verify/verify_requirements.md` であり、差分がある場合は本書の「差分/曖昧/未実装一覧」で明示する。
- 本書は `as_built/as_built_spec.md`（仕様）・`as_built/as_built_implementation_plan.md`（実装計画）とトレーサブルである。

---

## 1. スコープ

### 1.1 対象

- Gate A〜I の検証・テスト（Phase 1〜3: ブートストラップ→スモーク→フル検証）
- 検証結果の証跡管理（Evidence）・進捗管理（Tracker）・引継ぎ（handoff/latest.md）
- CI/QA レイヤー（Self-check: 品質チェック 8 種）
- 統合 CLI（`./kit`）による一気通貫パイプライン

### 1.2 非対象（Non-goals）

- 本体 repo（context-framework）のファイル変更・コミット・PR 作成
- SSOT 3 ファイル（`_handoff_check/`）の内容変更（検証キットでは参照コピーとして固定）
- 外部 CI サービス（GitHub Actions 等）への統合

---

## 2. 用語定義

| 用語 | 定義 | 根拠 |
|------|------|------|
| **KIT_ROOT** | 検証キットのルートディレクトリ。`SCRIPT_DIR` から自動解決される。 | kit:18-20, verify_all.sh:17-19 |
| **MAIN_REPO** | 本体 repo（context-framework）のパス。`discover_main_repo()` で自動解決。 | evidence.sh:18-38 |
| **GATE_AUDIT_ROOT** | 環境変数。`generate_handoff.sh` が参照するが、他スクリプトでは不要。 | generate_handoff.sh:15-21 |
| **SSOT** | Single Source of Truth。本体 repo の `_handoff_check/` 3 ファイル。Kit では `SSOT/` にスナップショットを保持。 | ssot_check.sh:9-10 |
| **Evidence** | 検証コマンド結果の証跡。`logs/evidence/<timestamp>_<label>/` に保存。 | evidence.sh:47-92 |
| **Tracker** | 検証・テスト・Self-check 等のチェックリスト（`tasks/*.md`）。 | tracker_updater.sh:107-130 |
| **handoff** | 引継ぎ文書（`handoff/latest.md`）。Kit の全状態を自己完結的に記載。 | handoff_builder.sh:49-65 |
| **Gate** | 検証を段階化した単位（A〜I）。各 Gate に req1/req2/req3 の 3 観点。 | gate_registry.sh:1-8 |
| **Phase** | テスト実行の段階（Phase 1: 環境/スモーク、Phase 2: Gate 固有、Phase 3: E2E）。 | run_tests.sh:44-387 |
| **Self-check** | CI/QA レイヤー。7 種のチェック（CQ-TRK/EVC/SSOT/DOC/LINT/NAME/REG）。 | self-check.sh:1-22 |

---

## 3. 安全性要件（MUST）

### REQ-S01: 検証キットの生成場所

- **要件**: 検証キットは本体 repo の外部に生成すること。
- **受入条件**: KIT_ROOT が本体 repo の git working tree に含まれない。
- **実装状態**: 充足。Kit は `/home/masahiro/.gate-audit_root/.gate-audit/` に存在（repo 外）。CF repo 内 `.gate-audit/` はバージョン管理用 snapshot であり、運用時の KIT_ROOT ではない。
- **根拠**: kit:18-20, evidence.sh:52
- **SSOT との差分**: `verify_requirements.md:34-35` は「GATE_AUDIT_ROOT 未設定時に FAIL」と記載。実態は `generate_handoff.sh` のみが GATE_AUDIT_ROOT を参照し、他スクリプトは SCRIPT_DIR ベースで自己解決する（→ REQ-D01）。

### REQ-S02: 本体 repo 不変更（read-only）

- **要件**: 検証キットは本体 repo に対して参照系操作のみを行い、書き込み操作を禁止する。
- **受入条件**: Gate スクリプトに `git commit/push/reset/clean/checkout` やファイル書き込みが存在しない。
- **実装状態**: 充足。全 Gate スクリプト（gate_a.sh〜gate_i.sh）は `check_file_exists`、`repo_grep`、`repo_grep_capture` 等の参照系関数のみ使用。3 層の検証で担保:
  1. **静的検査（CQ-RO）**: Self-check チェック CQ-RO（cq_readonly.sh）が全 gate/verify/evidence/test/self-check スクリプトを 13 種の書き込みパターンでスキャンし、write 操作の不在を自動検証。
  2. **ランタイム検査（Phase 1）**: `run_tests.sh` Phase 1 で gate_*.sh に対する `git push/commit/checkout/reset` の grep チェックを実施。
  3. **OS レベル検査（Phase 1, オプション）**: `run_tests.sh` Phase 1 で `tools/verify_ro_mount_nopasswd_template_v5.sh` による bind mount ro/rw/umount サイクルを実施（sudo NOPASSWD 未構成時は SKIP）。
- **根拠**: evidence.sh:250-310, verify_all.sh:47-48, cq_readonly.sh:1-127, run_tests.sh:102-128

### REQ-S03: 検索コマンドの安全終了

- **要件**: `rg`/`grep` 等の検索は「見つからなくても OK」の用途では `|| true` を付与して 0 終了とする。
- **受入条件**: 検索コマンドが非ゼロ終了でスクリプト全体が中断しない。
- **実装状態**: 充足。`repo_grep()` は内部で `|| return 1` を使用し、呼び出し元で `|| true` パターンを適用。
- **根拠**: evidence.sh:284-295, evidence.sh:300-310, context/run_rules.md:10-11

### REQ-S04: Repo Lock 確認

- **要件**: 検証開始時に `./tools/guard.sh --check` の結果を Evidence 化する。
- **受入条件**: handoff 生成時に repo_lock 状態が記録される。
- **実装状態**: 充足。`handoff_builder.sh:89-95` が guard チェックを実施、`run_tests.sh:90-96` も Phase 1 で確認。
- **根拠**: handoff_builder.sh:89-95, verify_requirements.md:43

### REQ-S05: セキュリティ姿勢の確認

- **要件**: 検証キットのシェルスクリプト群および設定・データファイルに対してセキュリティ総合調査を実施し、Critical/High の脆弱性が存在しないことを確認する。
- **受入条件**: 以下のセキュリティ姿勢が維持されている:
  - eval コマンド不使用（コマンドインジェクション耐性）
  - set -euo pipefail 全メインスクリプトで統一採用
  - 変数のダブルクォート適切化
  - バッククォート不使用（$() 構文統一）
  - 本体 repo への read-only 設計
  - パスワード・トークン・API キーの漏洩なし
  - world-writable ファイルなし
  - /tmp 不使用（一時ファイルはキット管理下ディレクトリに限定）
- **実装状態**: 充足。2026-02-06 のセキュリティ総合調査（シェルスクリプト 28 本 + 設定・データファイル）にて全 17 件を精査し、全件 Pass と判定。
  - Critical: 0 件、High: 0 件
  - Medium: 3 件（sudo mount 変数未検証、Self-check プラグイン無検証 source、awk 変数展開）→ 全件受容（固定値使用・信頼境界内・運用制約上の受容）
  - Low: 11 件（ワード分割、一時ファイル、パス未サニタイズ、ReDoS 等）→ 全件受容（外部入力経路なし・自ユーザー権限内・衛生面）
  - Info: 3 件（パターン引数、関数名衝突、Markdown 実行権限）→ 全件受容（実害なし）
- **根拠**: claude_codeの回答.txt（2026-02-06 セキュリティ総合調査レポート）
- **対応 SPEC**: SPEC-D02, SPEC-D03

---

## 4. 再現性・追跡性要件（MUST）

### REQ-T01: Evidence 保存

- **要件**: すべての検証コマンド結果を `logs/evidence/` に保存する。
- **受入条件**: Gate 検証・テスト・Self-check 実行後に、タイムスタンプ付きの Evidence ディレクトリ/ファイルが作成される。
- **実装状態**: 充足。`init_evidence()` が `logs/evidence/<ts>_<gate>/` を作成し、meta.txt / checksums.sha256 / commands.txt / judgement.txt + 個別チェック結果を保存。
- **根拠**: evidence.sh:47-92

### REQ-T02: Evidence ファイル命名

- **要件**: Evidence ファイル名に UTC タイムスタンプを含め、衝突を避ける。
- **受入条件**: ディレクトリ型 `YYYYMMDTHHMMSSZ_<gate>/`、ファイル型 `YYYYMMDD-HHMMSS_<purpose>.txt` の 2 形式。
- **実装状態**: 充足。`ts_label()` が `date -u +"%Y%m%dT%H%M%SZ"` を返す。Self-check は `sc_ts_label()` で `date -u +"%Y%m%d-%H%M%S"` を使用。
- **根拠**: evidence.sh:43, self_check_common.sh:13

### REQ-T03: Checksum 整合性

- **要件**: 参照ファイルの sha256 を `checksums.sha256` に記録し、検算可能とする。
- **受入条件**: `gate_summary()` 内で `sha256sum -c` が実行され、不一致があれば当該 Gate は FAIL。
- **実装状態**: 充足。`record_ref()` がコピーを `references/` に配置し sha256 を記録、`gate_summary()` で検算。
- **根拠**: evidence.sh:100-126, evidence.sh:196-247

### REQ-T04: Tracker 管理

- **要件**: `tasks/verify_task_tracker.md` に Gate A〜I の `[ ]/[x]`、Evidence パス、判定を記録する。追記式を基本とし、過去証跡は消さない。
- **受入条件**: Tracker 更新時に判定・Evidence・日時の 3 点が必須。`[x]` → `[ ]` の戻しは禁止。
- **実装状態**: 充足。`tracker_updater.sh` が自動更新を提供。`_tu_update_section_checkboxes()` がセクション内の未チェック項目を更新。新 Gate 追加時はセクション未存在でも `_tu_auto_create_gate_section()` が標準テンプレート（要件①②③）で自動生成する。
- **根拠**: tracker_updater.sh:41-143, verify_task_tracker.md:3

### REQ-T05: handoff 引継ぎ

- **要件**: `handoff/latest.md` に Kit の全状態を自己完結的に記載し、新チャットへの引継ぎソースとする。
- **受入条件**: latest.md 単体で Main Repo Snapshot / Trackers Digest / Evidence Index / Commands が把握できる。
- **実装状態**: 充足。`handoff_builder.sh` の emit_* 関数群が各セクションを生成。
- **根拠**: handoff_builder.sh:49-421, docs/rebuild/rebuild_requirements.md:33-43

---

## 5. 運用要件（MUST/SHOULD）

### REQ-O01: 1 手ずつ進行（MUST）

- **要件**: 指示は「次にやること 1 つだけ」。出力は「根拠 / 判定 / 変更提案」。
- **実装状態**: 充足。`context/run_rules.md` に明文化。
- **根拠**: context/run_rules.md:5-8

### REQ-O02: コピーブロック必須（MUST）

- **要件**: コピーが必要なコマンドや文面は必ずコードブロックで提示する。
- **実装状態**: 充足。`context/run_rules.md:17-18` に明記。
- **根拠**: context/run_rules.md:17-18

### REQ-O03: handoff 出力の統一（MUST）

- **要件**: handoff は原則 `scripts/generate_handoff.sh` で生成し、出力源を `handoff/latest.md` に統一する。
- **実装状態**: 充足。`generate_handoff.sh` が `handoff_builder.sh` を source して latest.md + latest.txt を生成。
- **根拠**: generate_handoff.sh:38-61, context/run_rules.md:29-31

---

## 6. 機能要件（MUST）

### REQ-F01: 統合 CLI（./kit）

- **要件**: `./kit` が handoff / verify / test / self-check / all / status / lockdown / unlock の各サブコマンドを提供する。
- **受入条件**: 各サブコマンドが正常に動作し、exit code 0（成功）/ 1（失敗）を返す。
- **実装状態**: 充足。`kit` スクリプトが全 6 サブコマンドを実装。
- **根拠**: kit:4-15, kit:246-270
- **対応 SPEC**: SPEC-S01

### REQ-F02: Gate 検証（verify）

- **要件**: Gate A〜I の 3 観点（req1: 機能要約、req2: 体系整合、req3: 機能性）を Evidence 付きで検証できる。
- **受入条件**: `./kit verify` で全 Gate が PASS/FAIL 判定され、Evidence が保存される。
- **実装状態**: 充足。`verify_all.sh` が全 Gate を自動発見して順次実行（Gate 0 件時は即 FATAL + exit 1、SSOT DIFFER 時も exit 1）。`verify_gate.sh` が個別 Gate を実行。Gate 自動発見は `gate_registry.sh` による。
- **根拠**: verify_all.sh:1-160, gate_registry.sh:1-79, gate_a.sh:5-152（代表例）
- **対応 SPEC**: SPEC-S02, SPEC-S03

### REQ-F03: テスト実行（test）

- **要件**: Phase 1（環境/スモーク）、Phase 2（Gate 固有）、Phase 3（E2E/再現性）のテストを実行できる。
- **受入条件**: `./kit test` で全 Phase が PASS/FAIL 判定され、Evidence が保存される。
- **実装状態**: 充足。`run_tests.sh` が 3 Phase を実装。各 Phase は独立した Evidence を生成。Phase 2 の Gate 一覧と Phase 1/3 の Gate パターンは `gate_registry.sh` の `gr_list_gate_ids()` で動的取得（Gate 追加時に自動追従）。Phase 2 はプロセス置換の exit code 非伝播に対する Gate 0 件ガードを実装（run_tests.sh:217-220）。
- **根拠**: run_tests.sh:44-431, gate_registry.sh:36-47
- **対応 SPEC**: SPEC-S04

### REQ-F04: CI/QA チェック（self-check）

- **要件**: 8 種のチェック（tracker/evidence/ssot/docs/lint/naming/regression/readonly）を実行できる。
- **受入条件**: `./kit self-check` で全チェックが PASS/FAIL 判定され、Evidence が保存される。config で有効/無効の切り替えが可能。
- **実装状態**: 充足。`self-check.sh` がプラグイン自動発見（`cq_*.sh`）を実装。`config/self-check.conf` で設定。
- **根拠**: self-check.sh:1-401, config/self-check.conf:1-22
- **対応 SPEC**: SPEC-S05

### REQ-F05: 一気通貫パイプライン（all）

- **要件**: `./kit all` で verify → test → self-check → handoff を順次実行できる。
- **受入条件**: 全ステップが完了し、最終的に latest.md が再生成される。FAIL があっても handoff まで実行する。
- **実装状態**: 充足。`kit_all()` が 4 ステップを順次実行。
- **根拠**: kit:134-186
- **対応 SPEC**: SPEC-S06

### REQ-F06: 進捗サマリ（status）

- **要件**: `./kit status` で全トラッカーの進捗（完了数/総数/パーセント/ステータス）を表示できる。
- **受入条件**: 副作用なしで進捗が確認できる。
- **実装状態**: 充足。`kit_status()` が 6 トラッカーを走査して表示。
- **根拠**: kit:188-244
- **対応 SPEC**: SPEC-S07

### REQ-F07: Gate 自動発見

- **要件**: 新 Gate の追加は `scripts/lib/gate_<id>.sh` を置いて `verify_gate_<id>()` を定義するだけで完了する。`verify_all.sh`、`verify_gate.sh`、`kit` への変更は不要。
- **受入条件**: Gate ファイルの追加のみで `./kit verify` に自動的に含まれる。
- **実装状態**: 充足。`gate_registry.sh` が `gate_*.sh` を glob で取得し Gate ID / 関数名を解決。Gate ID は `_gr_is_safe_gate_id()` で `^[a-z0-9_]+$` を検証し、unsafe ID は列挙時（`gr_list_gate_ids`）と source 前（`gr_source_all_gates`）の 2 箇所で即 FATAL + exit 1（fail-closed）。文字列分割は `while IFS= read -r` で空白パス安全。
- **根拠**: gate_registry.sh:1-79
- **対応 SPEC**: SPEC-S08

### REQ-F08: Self-check プラグイン自動発見

- **要件**: 新チェックの追加は `scripts/lib/self_checks/cq_*.sh` にメタデータヘッダ付きスクリプトを置くだけで完了する。
- **受入条件**: チェックファイルの追加のみで `./kit self-check` に自動的に含まれる。
- **実装状態**: 充足。`self-check.sh:48-107` が `@check_key`/`@check_id`/`@check_display`/`@check_order` メタデータをパースして自動登録。
- **根拠**: self-check.sh:48-107, docs/self-check/self_check_plugin_guide.md
- **対応 SPEC**: SPEC-S09

### REQ-F09: トラッカー自動更新（GATE_EVIDENCE マーカー連動）

- **要件**: `./kit verify` / `./kit test` 実行時に、出力から検証結果を自動パースし `tasks/verify_task_tracker.md` / `tasks/test_task_tracker.md` の `[ ]` を `[x]` に変換、判定・Evidence パス・日時メタデータを自動挿入する。
- **受入条件**: 手動のトラッカー編集なしで、`./kit verify` / `./kit test` 実行後にトラッカーが最新状態に更新される。
- **実装状態**: 充足。`kit:27-48`（`_kit_update_verify_from_output`）が `GATE_EVIDENCE:` マーカーをパースし `update_verify_tracker()` を呼出。`kit:52-71`（`_kit_update_test_from_output`）が `Phase N: PASS/FAIL Evidence: <path>` をパースし `update_test_tracker()` を呼出。
- **根拠**: kit:27-71, tracker_updater.sh:41-195
- **対応 SPEC**: SPEC-S11, SPEC-S15

### REQ-F10: Self-check プラグインソート（@check_order）

- **要件**: Self-check チェックプラグインの実行順序を `@check_order` メタデータで制御できる。値が小さいほど先に実行される。
- **受入条件**: `@check_order: 10` のプラグインは `@check_order: 50` のプラグインより先に実行される。同一 order のプラグインはキー名のアルファベット順で安定ソートされる。
- **実装状態**: 充足。`self-check.sh:93-104` が `sort -t: -k1,1n -k2,2` で数値ソート後にアルファベットソートし、安定した実行順序を保証。
- **根拠**: self-check.sh:93-104
- **対応 SPEC**: SPEC-S09

### REQ-F11: Self-check config 否定構文（checks=!key）

- **要件**: `config/self-check.conf` の `checks=` で `!` プレフィックスによるチェック除外指定をサポートする。
- **受入条件**: `checks=!lint,!naming` で lint と naming 以外の全チェックが実行される。正と負の混在（例: `tracker,!lint`）はエラーとなる。
- **実装状態**: 充足。`self-check.sh:146-193` が否定検出・排他モード処理・混在エラー検出を実装。
- **根拠**: self-check.sh:114-221
- **対応 SPEC**: SPEC-S05

### REQ-F12: CQ-DOC REQ-ID 範囲展開

- **要件**: CQ-DOC チェックにおいて、仕様書中の `REQ-R01〜R07` のような範囲記法を個別 ID（`REQ-R01`, `REQ-R02`, ..., `REQ-R07`）に展開して網羅性を検証できる。
- **受入条件**: 仕様書が `REQ-R01〜R07` と記載している場合、要件書の `REQ-R01` 〜 `REQ-R07` 全件がカバーされているとみなされる。`〜`（全角チルダ）と `~`（半角チルダ）の両方をサポート。
- **実装状態**: 充足。`cq_docs.sh:84-99` が正規表現でプレフィックス・開始番号・終了番号を抽出し、ゼロパディング幅を保持してループ展開する。
- **根拠**: cq_docs.sh:84-99
- **対応 SPEC**: SPEC-CQ01

### REQ-F13: GATE_EVIDENCE 出力マーカー

- **要件**: Gate 検証完了時に `gate_summary()` が標準出力に `GATE_EVIDENCE:<Gate_ID>:<relative_evidence_path>` 形式のマーカーを出力する。これは `kit` のトラッカー自動更新（REQ-F09）の入力となる。
- **受入条件**: `gate_summary()` の出力に `GATE_EVIDENCE:` プレフィックス行が含まれる。
- **実装状態**: 充足。`evidence.sh:246-248` が Gate ラベルから Gate ID を抽出し、KIT_ROOT 相対パスとともにマーカーを出力。
- **根拠**: evidence.sh:246-248
- **対応 SPEC**: SPEC-S10, SPEC-S15

### REQ-F14: 進捗ログ自動記録

- **要件**: `./kit verify` / `./kit test` 実行時に、トラッカーの `## Progress Log` セクションにタイムスタンプ付きサマリを自動追記する。セクションが存在しない場合は自動作成する。
- **受入条件**: `./kit verify` 実行後に `tasks/verify_task_tracker.md` の末尾に `- YYYY-MM-DD HH:MM JST | kit verify: Total: ...` 形式のエントリが追記される。
- **実装状態**: 充足。`tracker_updater.sh:167-188`（`append_progress_log()`）がセクション存在確認と自動作成を行い、`_tu_ts_jst_short()` による JST タイムスタンプ付きエントリを追記。`kit:43-47, 66-70` から自動呼出。
- **根拠**: tracker_updater.sh:167-188, kit:43-47, kit:66-70
- **対応 SPEC**: SPEC-S11

### REQ-F15: CQ-RO（Read-only Compliance チェック）

- **要件**: Self-check チェック CQ-RO が、全 gate/verify/evidence/test/self-check スクリプトを対象に、本体 repo への書き込み操作（13 種パターン）が存在しないことを自動検証できる。
- **受入条件**: `./kit self-check readonly` で CQ-RO チェックが PASS/FAIL 判定される。検出対象は `git push/commit/add/reset/clean/checkout/merge/rebase/stash`、リダイレクト（`>` / `>>`）、`tee/cp/mv/rm/mkdir/touch/chmod/chown/sed -i` のうち `$MAIN_REPO` を対象とするもの。コメント行・文字列リテラル内は除外。
- **実装状態**: 充足。`cq_readonly.sh` が 13 種の write パターンでスキャン。gate_*.sh、verify_all.sh、verify_gate.sh、evidence.sh、run_tests.sh、self-check.sh を対象。
- **根拠**: cq_readonly.sh:1-127
- **対応 SPEC**: SPEC-CQ02

### REQ-F16: MAIN_REPO バリデーション（対象 repo 正当性検証）

- **要件**: `discover_main_repo()` が検出した本体 repo 候補を、構造マーカーおよび SSOT fingerprint で検証し、誤った repo を検査対象にするリスクを排除する。
- **受入条件**: `_handoff_check/` 不在、構造マーカー（WORKFLOW/controller/rules）不在、SSOT sha256 不一致のいずれかで候補を棄却し、次の候補を探索する。全候補が不合格の場合は FATAL エラーで停止する。
- **実装状態**: 充足。`evidence.sh` の `_validate_main_repo()` が 4 段階バリデーションを実施:
  1. .git ディレクトリ存在確認
  2. `_handoff_check/` ディレクトリ存在確認
  3. 構造マーカー（WORKFLOW/controller/rules のいずれか）存在確認
  4. Kit SSOT/ と候補 repo `_handoff_check/` の sha256 照合（3 ファイル全一致必須）
- **実効性**: 同一検索パス配下に複数の context-framework が存在する環境でも、SSOT 版と一致する repo のみが選択される。
- **根拠**: evidence.sh:17-52（`_validate_main_repo`）, evidence.sh:60-97（`discover_main_repo` 内 4 段階呼出）
- **対応 SPEC**: SPEC-S16

---

## 7. Exit Code 契約

| コマンド | 0 | 1 |
|----------|---|---|
| `./kit verify` | 全 Gate PASS | 1 件以上 FAIL |
| `./kit test` | 全 Phase PASS | 1 件以上 FAIL |
| `./kit self-check` | 全チェック PASS | 1 件以上 FAIL |
| `./kit all` | 全ステップ PASS | 1 件以上 FAIL |
| `./kit handoff` | 生成成功 | 生成失敗 |
| `./kit status` | 常に 0 | - |

根拠: kit:86, kit:111, kit:131, kit:185, verify_all.sh:144-148, run_tests.sh:471, self-check.sh:395-398

---

## 8. 合格条件（Acceptance Criteria）

| # | 条件 | 状態 | 根拠 |
|---|------|------|------|
| AC-01 | KIT_ROOT が repo 外に存在 | OK | Kit が `/home/masahiro/.gate-audit_root/.gate-audit/` に存在 |
| AC-02 | SSOT/ に 3 ファイル | OK | SSOT/handoff_prompt.md, update_runbook.md, task_tracker.md |
| AC-03 | context/ に run_rules.md + codex_high_prompt.md | OK | 両ファイル存在 |
| AC-04 | tasks/ にトラッカー群（verify/test/as_built/rebuild/post_rebuild/self_check） | OK | 6 ファイル存在 |
| AC-05 | logs/evidence/ に Evidence 蓄積 | OK | 多数の evidence ディレクトリ/ファイルが存在 |
| AC-06 | handoff/latest.md が生成可能 | OK | generate_handoff.sh → handoff_builder.sh |
| AC-07 | `./kit verify` で Gate A〜I が PASS/FAIL 判定可能 | OK | verify_task_tracker.md:12-18 (全 PASS) |
| AC-08 | `./kit test` で Phase 1-3 が PASS/FAIL 判定可能 | OK | run_tests.sh 実装済み |
| AC-09 | `./kit self-check` で 8 チェックが PASS/FAIL 判定可能 | OK | self-check.sh + cq_*.sh 8 ファイル |
| AC-10 | `./kit all` で一気通貫が完了する | OK | kit:134-186 |
| AC-11 | `./kit status` で全トラッカー進捗が表示される | OK | kit:188-244 |

---

## 9. 差分/曖昧/未実装一覧

### REQ-D01: GATE_AUDIT_ROOT の扱い不統一

- **SSOT**: verify_requirements.md:34-35 は「GATE_AUDIT_ROOT 未設定時にスクリプトは中断（FAIL）する」と記載。
- **実態**: `generate_handoff.sh` のみが GATE_AUDIT_ROOT を参照（15-21 行）。ただし SCRIPT_DIR フォールバックあり。他スクリプト（verify_all.sh, verify_gate.sh, kit）は SCRIPT_DIR ベースで自己解決。
- **影響度**: 低（検証は環境変数なしで動作する）
- **提案**: SSOT を実態に合わせて更新するか、全スクリプトに GATE_AUDIT_ROOT サポートを追加する。

### REQ-D02: lockdown/unlock ~~未実装~~ → 実装済み（v1.9）

- **SSOT**: verify_spec.md:93-108 が lockdown.sh / unlock.sh を定義。
- **実態**: v1.9 で実装完了。`scripts/lockdown.sh`（quarantine 移動 + chmod go-rwx + LOCKED.flag/README_LOCKED.md 作成）と `scripts/unlock.sh`（二段階解除: LOCKED.flag 確認 + パスフレーズ UNLOCK-VERIFY-KIT）が SSOT 仕様に準拠。`./kit lockdown` / `./kit unlock` サブコマンドとしても利用可能。
- **影響度**: 解消（Phase 5 完了）

### REQ-D03: logs/runs/ ディレクトリ未使用

- **SSOT**: verify_spec.md:36-38 が `logs/runs/<ts>/verify.log` を定義。
- **実態**: 未使用。Evidence は `logs/evidence/<ts>_<gate>/` に直接保存。
- **影響度**: なし（機能的に充足）

### REQ-D04: Kit root README.md 不在

- **SSOT**: verify_implementation_plan.md:20 が README.md 必須を示唆。
- **実態**: Kit root に README.md なし（`.gate-audit/` サブコピー内にのみ存在）。
- **影響度**: 低

### REQ-D05: verify.sh → verify_all.sh + verify_gate.sh に分離

- **SSOT**: verify_spec.md:29 が `scripts/verify.sh` を定義。
- **実態**: `scripts/verify_all.sh`（一括）と `scripts/verify_gate.sh`（個別）に分離されている。
- **影響度**: なし（機能向上）

### REQ-D06: collect_evidence.sh → lib/evidence.sh にライブラリ化

- **SSOT**: verify_spec.md:30 が `scripts/collect_evidence.sh` を定義。
- **実態**: `scripts/lib/evidence.sh` としてライブラリ化。
- **影響度**: なし（機能向上）

---

## 10. トレーサビリティ（REQ → SPEC → PLAN）

| 要件 | 対応 SPEC | 対応 PLAN |
|------|-----------|-----------|
| REQ-S01 (生成場所) | SPEC-D01 | PLAN-P1 |
| REQ-S02 (read-only) | SPEC-D02 | PLAN-P1 |
| REQ-S03 (検索安全) | SPEC-D02 | PLAN-P1 |
| REQ-S04 (Repo Lock) | SPEC-S02 | PLAN-P2 |
| REQ-S05 (セキュリティ姿勢) | SPEC-D02, SPEC-D03 | PLAN-SEC01 |
| REQ-T01 (Evidence) | SPEC-S10 | PLAN-P2 |
| REQ-T02 (命名) | SPEC-S10 | PLAN-P2 |
| REQ-T03 (Checksum) | SPEC-S10 | PLAN-P2 |
| REQ-T04 (Tracker) | SPEC-S11 | PLAN-P2 |
| REQ-T05 (handoff) | SPEC-S12 | PLAN-P3 |
| REQ-F01 (./kit) | SPEC-S01 | PLAN-P3 |
| REQ-F02 (verify) | SPEC-S02, S03 | PLAN-P3 |
| REQ-F03 (test) | SPEC-S04 | PLAN-P3 |
| REQ-F04 (self-check) | SPEC-S05 | PLAN-P4 |
| REQ-F05 (all) | SPEC-S06 | PLAN-P3 |
| REQ-F06 (status) | SPEC-S07 | PLAN-P3 |
| REQ-F07 (Gate 自動発見) | SPEC-S08 | PLAN-P3 |
| REQ-F08 (Self-check 自動発見) | SPEC-S09 | PLAN-P4 |
| REQ-F09 (トラッカー自動更新) | SPEC-S11, SPEC-S15 | PLAN-MAINT03 |
| REQ-F10 (プラグインソート) | SPEC-S09 | PLAN-MAINT02 |
| REQ-F11 (否定構文) | SPEC-S05 | PLAN-PROC04 |
| REQ-F12 (REQ-ID 範囲展開) | SPEC-CQ01 | PLAN-P4 |
| REQ-F13 (GATE_EVIDENCE マーカー) | SPEC-S10, SPEC-S15 | PLAN-EV01 |
| REQ-F14 (進捗ログ自動記録) | SPEC-S11 | PLAN-MAINT03 |
| REQ-F15 (CQ-RO) | SPEC-CQ02 | PLAN-P4 Phase 4d |
| REQ-F16 (MAIN_REPO バリデーション) | SPEC-S16 | PLAN-P5 |

---

## 11. 変更履歴

- v0.1（2026-02-03 JST）: 旧版（Claude Code 作成、as-built 暫定版）
- v0.2（2026-02-04 JST）: Codex 版（as_bulit_codex/ に生成）
- v1.0（2026-02-05 JST）: 正式版（Claude Code / Codex を統合し repo 実態に基づき再作成。REQ 番号体系化、差分明示、トレーサビリティ追加）
- v1.1（2026-02-06 JST）: 未文書化機能 6 件を追加（REQ-F09〜F14: トラッカー自動更新、プラグインソート、否定構文、REQ-ID 範囲展開、GATE_EVIDENCE マーカー、進捗ログ自動記録）
- v1.2（2026-02-06 JST）: セキュリティ総合調査結果を追加（REQ-S05: セキュリティ姿勢の確認、17 件の受容判定結果）
- v1.3（2026-02-07 JST）: REQ-S02 強化（read-only 3 層検証: CQ-RO 静的検査 + Phase 1 ランタイム + OS レベル ro mount）、REQ-F15 追加（CQ-RO チェック）、REQ-F04 を 7→8 種に更新
- v1.4（2026-02-07 JST）: バグ修正 8 件の反映（verify_gate.sh 未知 Gate exit code、run_tests.sh guard.sh パス、evidence.sh discover_main_repo 階層、kit テストサマリ抽出、gate_a/b req② 判定厳格化、gate_g req② LOG-009 両方必須、gate_i req① 閾値 ==6）
- v1.5（2026-02-07 JST）: Gate 動的スケーラビリティ対応（REQ-F03: run_tests.sh Phase 1/2/3 の A-I 固定を gate_registry.sh 動的検出に置換、REQ-T04: tracker_updater.sh に Gate セクション自動生成機能追加、REQ-F07: gate_registry.sh に Gate ID バリデーション追加〈`_gr_is_safe_gate_id()` ヘルパー、列挙時+source 前の 2 箇所で一貫適用〉）
- v1.6（2026-02-07 JST）: Codex 評価指摘 4 件修正（REQ-F02: verify_all.sh に Gate 0 件ガード + SSOT MATCH 必須化〈fail-closed〉、REQ-F07: gate_registry.sh unsafe ID を WARN→FATAL+exit 1 に昇格 + `for f in $(...)` を `while IFS= read -r f` に変更〈空白パス安全化〉）
- v1.7（2026-02-07 JST）: run_tests.sh Phase 2 Gate 0 件ガード追加（REQ-F03: プロセス置換 `< <(gr_list_gate_ids)` の exit code 非伝播による偽 PASS 防止）
- v1.8（2026-02-07 JST）: gate_a.sh/gate_b.sh req② の `repo_grep` 呼び出しバグ修正（`-i` フラグが `repo_grep` 非対応のため、パターンとファイルパスが 1 つずれて常に FAIL していた。`-i` 除去で解消。パターン自体に大小文字両方含むため動作変更なし）
- v1.9（2026-02-07 JST）: Phase 5 lockdown/unlock 実装（REQ-D02 解消）+ MAIN_REPO バリデーション強化（REQ-F16: _validate_main_repo() 4 段階検証 — .git + _handoff_check/ + 構造マーカー + SSOT sha256 照合。find 結果を全候補走査に変更し、誤 repo 接続を防止）+ `./kit lockdown` / `./kit unlock` サブコマンド追加（REQ-F01 更新）
- v2.2（2026-02-14 JST）: cf_/cf- プレフィックス除去 — SSOT 3 ファイル名（handoff_prompt.md / update_runbook.md / task_tracker.md）およびツール参照を新名に更新。
- v2.1（2026-02-14 JST）: REQ-S01 配置モデル明確化 — CF repo 内 `.gate-audit/` は snapshot であり運用時の KIT_ROOT ではないことを注記（CODEX F-02 対応）。
- v2.0（2026-02-14 JST）: 3 層リネーム + 構造簡素化（`.cfctx_verify` → `.gate-audit`、`.cfctx` → `.repo-id`、内部 CIQA → self-check〈ファイル・関数 9 件・変数 13 件・CLI サブコマンド〉、環境変数 `CFCTX_*` → `GATE_AUDIT_*` / `SC_*`、ディレクトリ 3 段→2 段簡素化）
