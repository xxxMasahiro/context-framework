# 再構築タスク管理表（Rebuild Task Tracker）

## 目的
検証キットを「latest.md 単体で完璧に把握できる」状態へ再構築するためのタスク管理。
各タスクは「要件→仕様→実装→検証→完了」のフローで進める。

## 運用ルール
- `[ ]` → `[x]` 更新時は必ず「判定 / Evidence / 日時」を併記する
- `[x]` → `[ ]` への戻しは禁止（再検証は新規項目を追加）
- Progress Log に更新履歴を追記する

---

## Phase 0: 設計（要件・仕様・計画策定）

- [x] 現状分析（既存ファイル構造・latest.md の課題洗い出し）
  - 判定: PASS
  - Evidence: docs/rebuild/ 内の3ドキュメントに課題を記載
  - 日時: 2026-02-03 JST

- [x] 再構築要件定義（rebuild_requirements.md）作成
  - 判定: PASS
  - Evidence: docs/rebuild/rebuild_requirements.md
  - 日時: 2026-02-03 JST

- [x] 再構築仕様（rebuild_spec.md）作成
  - 判定: PASS
  - Evidence: docs/rebuild/rebuild_spec.md
  - 日時: 2026-02-03 JST

- [x] 再構築実装計画（rebuild_implementation_plan.md）作成
  - 判定: PASS
  - Evidence: docs/rebuild/rebuild_implementation_plan.md
  - 日時: 2026-02-03 JST

- [x] 再構築タスク管理表（本ファイル）作成
  - 判定: PASS
  - Evidence: tasks/rebuild_task_tracker.md
  - 日時: 2026-02-03 JST

## Phase 1: handoff_builder.sh 作成（Step 1）

- [x] emit_meta() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST
- [x] emit_main_repo_snapshot() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST
- [x] emit_trackers_digest() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST
- [x] emit_evidence_index() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST
- [x] emit_kit_files() / emit_commands() / emit_notes() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST
- [x] handoff_builder.sh 単体テスト
  - 判定: PASS (7/7 functions OK)
  - Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
  - 日時: 2026-02-03 22:14 JST

## Phase 2: generate_handoff.sh 改修（Step 2）

- [x] 旧 generate_handoff.sh のバックアップ作成
  - 判定: PASS
  - Evidence: logs/evidence/20260203-222430_step2_backup_created.txt
  - バックアップ: scripts/generate_handoff.sh.bak.20260203T132421Z (sha256: 4d4abb7a...)
  - 日時: 2026-02-03 22:24 JST
- [x] generate_handoff.sh を handoff_builder.sh 呼び出しに置き換え
  - 判定: PASS
  - Evidence: logs/evidence/20260203-222644_step2_generate_handoff_test.txt
  - 日時: 2026-02-03 22:26 JST
- [x] 新フォーマット latest.md の検証
  - 判定: PASS (7セクション全含: Meta/Main Repo Snapshot/Trackers Digest/Evidence Index/Kit Files/Commands/Notes)
  - Evidence: logs/evidence/20260203-222644_step2_generate_handoff_test.txt
  - AC-01(repo状態): PASS, AC-02(tracker進捗): PASS, AC-03(Evidence sha256): PASS
  - 日時: 2026-02-03 22:26 JST

## Phase 3: tracker_updater.sh 作成（Step 3）

- [x] update_verify_tracker() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt
  - 日時: 2026-02-03 23:43 JST
- [x] update_test_tracker() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt
  - 日時: 2026-02-03 23:43 JST
- [x] append_progress_log() 関数実装
  - 判定: PASS
  - Evidence: logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt
  - 日時: 2026-02-03 23:43 JST
- [x] tracker_updater.sh 単体テスト
  - 判定: PASS (6/6 tests: update_verify Gate A/B, update_test Phase 1, append_progress_log, idempotency, missing section)
  - Evidence: logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt
  - 日時: 2026-02-03 23:43 JST

## Phase 4: kit コマンド作成（Step 4）

- [x] kit サブコマンド分岐（handoff / verify / test / all / status）実装
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] ./kit handoff の動作確認
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] ./kit status の動作確認
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] ./kit verify の動作確認（全Gate + 個別Gate）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] ./kit test の動作確認
  - 判定: PASS (graceful degradation — no test runner yet, expected behavior)
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] ./kit all の動作確認（一気通貫）
  - 判定: PASS (verify runs, test runner warns, handoff regenerates)
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST

## Phase 5: I/F調整（Step 5）

- [x] verify_all.sh の exit code 統一（0: PASS / 1: FAIL）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] verify_gate.sh の exit code 統一
  - 判定: PASS
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST
- [x] 後方互換テスト（単独実行が従来通り動くこと）
  - 判定: PASS (bash scripts/verify_gate.sh C → exit 0, output unchanged)
  - Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
  - 日時: 2026-02-04 00:27 JST

## Phase 6: 統合テスト・受け入れ検証（Step 6）

- [x] AC-01: latest.md だけで本体repoの状態が分かる
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: Main Repo Snapshot に HEAD/branch/status/repo_lock/SSOT fingerprint/SSOT match を網羅
  - 日時: 2026-02-04 00:48 JST
- [x] AC-02: latest.md だけで全トラッカーの進捗が分かる
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: Trackers Digest 4件の done/total が実ファイルの grep 結果と完全一致
  - 日時: 2026-02-04 00:48 JST
- [x] AC-03: latest.md だけで全Evidence の目的・判定・sha256が分かる
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: Evidence Index 242件 = 実ファイル 242件（完全一致）、各行に Purpose/Verdict/SHA256 記載
  - 日時: 2026-02-04 00:48 JST
- [x] AC-04: ./kit all で一気通貫が完了する
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: ./kit all → verify 9/9 PASS + handoff 生成 → exit 0
  - 日時: 2026-02-04 00:48 JST
- [x] AC-05: ./kit verify C で Gate C 単独が完了する
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: ./kit verify C → Gate C: PASS (req①②③ 全PASS) → handoff再生成 → exit 0
  - 日時: 2026-02-04 00:48 JST
- [x] AC-06: verify/ 配下3ドキュメントが変更されていない
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: 3ファイル sha256 が checkpoint/pre-claude-rebuild と完全一致 + git diff 差分なし
  - 日時: 2026-02-04 00:48 JST
- [x] AC-07: 本体repoに変更が入っていない
  - 判定: PASS
  - Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt
  - 根拠: latest.md Main Repo Snapshot: status=clean, repo_lock=OK, SSOT match=YES
  - 日時: 2026-02-04 00:48 JST

---

## Progress Log

- 2026-02-03 JST | Phase 0 完了: 要件定義・仕様・実装計画・タスク管理表を作成 | 判定: PASS | Evidence: docs/rebuild/ 配下 + tasks/rebuild_task_tracker.md
- 2026-02-03 22:14 JST | Phase 1 完了: handoff_builder.sh 作成（7 emit関数実装＋単体テスト PASS） | 判定: PASS | Evidence: logs/evidence/20260203-221430_step1_handoff_builder_unit_test.txt
- 2026-02-03 22:26 JST | Phase 2 完了: generate_handoff.sh v2 改修（バックアップ→改修→新フォーマット検証 全PASS） | 判定: PASS | Evidence: logs/evidence/20260203-222430_step2_backup_created.txt, logs/evidence/20260203-222644_step2_generate_handoff_test.txt
- 2026-02-03 23:23 JST | Phase 2 補足: repo_lock NG 修正（guard.sh をサブシェルで MAIN_REPO から実行するよう変更 → repo_lock: OK） | 判定: PASS | Evidence: logs/evidence/20260203-232326_step2_repo_lock_fix.txt
- 2026-02-03 23:43 JST | Phase 3 完了: tracker_updater.sh 作成（3関数実装＋単体テスト 6/6 PASS） | 判定: PASS | Evidence: logs/evidence/20260203-234314_step3_tracker_updater_unit_test.txt
- 2026-02-04 00:27 JST | Phase 4+5 完了: ./kit CLI 作成（5サブコマンド実装）＋ I/F調整（exit code 統一 + 後方互換テスト） 8/8 PASS | 判定: PASS | Evidence: logs/evidence/20260204-002755_step4_kit_cli_test.txt
- 2026-02-04 00:48 JST | Phase 6 完了: 統合テスト・受け入れ検証 AC-01〜AC-07 全 PASS | 判定: PASS | Evidence: logs/evidence/20260204-004817_step6_acceptance_ac01_07.txt | sha256(16): fae51d90a3c6ba2c
