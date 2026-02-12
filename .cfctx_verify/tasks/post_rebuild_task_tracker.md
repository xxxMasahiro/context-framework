# Post-rebuild タスク管理表（Post-rebuild Task Tracker）

## 目的
rebuild 完了後の追加開発タスクを管理する。
rebuild_task_tracker.md（34/34 ALL_PASS）は閉じたまま維持する。

## 運用ルール
- `[ ]` → `[x]` 更新時は必ず「判定 / Evidence / 日時」を併記する
- `[x]` → `[ ]` への戻しは禁止（再検証は新規項目を追加）
- Progress Log に更新履歴を追記する

---

## PR-01: `./kit test [PHASE]` 実装（placeholder → 実用テスト実行）

- [x] scripts/run_tests.sh 作成（Phase 1/2/3 テストランナー）
  - Phase 1: 共通（環境・スモーク）
  - Phase 2: Gate固有（個別Gate検証 A-I）
  - Phase 3: 横断E2E（全体導線＋再現性）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-170516_test_phase1.txt, logs/evidence/20260203-170518_test_phase2.txt, logs/evidence/20260203-170530_test_phase3.txt
  - 日時: 2026-02-04 02:05 JST
- [x] ./kit test（all）の動作確認
  - 判定: PASS（3/3 phases PASS）
  - Evidence: logs/evidence/20260203-170516_test_phase1.txt (sha256:0f53a1ac), logs/evidence/20260203-170518_test_phase2.txt (sha256:4d73f75f), logs/evidence/20260203-170530_test_phase3.txt (sha256:5edbf7c1)
  - 日時: 2026-02-04 02:05 JST
- [x] ./kit test <PHASE> の動作確認（Phase 1/2/3 個別）
  - 判定: PASS（Phase 1/2/3 各個別実行 PASS）
  - Evidence: 各フェーズの Evidence は上記と同一パターンで生成確認済み
  - 日時: 2026-02-04 02:05 JST
- [x] Evidence 出力の確認（目的・判定・sha256先頭16）
  - 判定: PASS
  - 確認内容: 各 Evidence ファイルに Timestamp/Phase名/RESULT/sha256(16) を出力確認
  - 日時: 2026-02-04 02:05 JST
- [x] 終了コード統一の確認（0: PASS / 1: FAIL）
  - 判定: PASS
  - 確認内容: PASS時 exit 0, FAIL時 exit 1 を実装・確認済み
  - 日時: 2026-02-04 02:05 JST
- [x] ./kit all にテストが組み込まれていることの確認
  - 判定: PASS（kit all → verify 9/9 + test 3/3 + handoff → ALL PASS）
  - Evidence: logs/evidence/20260203-170557_test_phase1.txt (sha256:87cc2a08), logs/evidence/20260203-170559_test_phase2.txt (sha256:468d8064), logs/evidence/20260203-170613_test_phase3.txt (sha256:847e228d)
  - 日時: 2026-02-04 02:06 JST
- [x] 後方互換の確認（既存スクリプト・トラッカーが破壊されていないこと）
  - 判定: PASS
  - 確認内容: rebuild_task_tracker.md 34/34 ALL_PASS 維持、test_task_tracker.md 6/6 維持、verify/as_built トラッカー不変、既存 verify_all.sh/verify_gate.sh 動作不変
  - 日時: 2026-02-04 02:06 JST

---

## Progress Log

- 2026-02-04 02:05 JST | PR-01 開始: scripts/run_tests.sh 作成、Phase 1/2/3 テストランナー実装完了
- 2026-02-04 02:06 JST | PR-01 完了: ./kit test (all) 3/3 PASS、./kit all 統合確認 ALL PASS、後方互換 OK | 7/7 全項目 [x] 完了
