# Self-check タスク管理表（Self-check Task Tracker）

## 目的
検証キットの self-check（内部品質検査）レイヤー構築を管理する。
既存の verify / test の上位で動作する品質ゲートキーパーを段階的に実装する。

## 運用ルール
- `[ ]` → `[x]` 更新時は必ず「判定 / Evidence / 日時」を併記する
- `[x]` → `[ ]` への戻しは禁止（再検証は新規項目を追加）
- Progress Log に更新履歴を追記する

---

## Phase 0: 設計（要件・仕様・計画策定）

- [x] 既存構造の調査（kit CLI / scripts / docs / tasks / evidence）
  - 判定: PASS
  - Evidence: docs/self-check/ 内の4ドキュメントに調査結果を反映
  - 日時: 2026-02-04 JST

- [x] Self-check 要件定義（self_check_requirements.md）作成
  - 判定: PASS
  - Evidence: docs/self-check/self_check_requirements.md
  - 日時: 2026-02-04 JST

- [x] Self-check 仕様（self_check_spec.md）作成
  - 判定: PASS
  - Evidence: docs/self-check/self_check_spec.md
  - 日時: 2026-02-04 JST

- [x] Self-check 実装計画（self_check_implementation_plan.md）作成
  - 判定: PASS
  - Evidence: docs/self-check/self_check_implementation_plan.md
  - 日時: 2026-02-04 JST

- [x] Self-check タスク管理表（本ファイル）作成
  - 判定: PASS
  - Evidence: tasks/self_check_task_tracker.md
  - 日時: 2026-02-04 JST

- [x] Phase 0 Evidence 保存・コミット・handoff 更新
  - 判定: PASS
  - Evidence: logs/evidence/20260203-184649_ciqa_phase0_design.txt (sha256:e3814f882a3617a8)
  - 日時: 2026-02-04 03:46 JST

## Phase 1: 最小 Runner + コアチェック

- [x] self_check_common.sh 作成（ヘッダ出力、verdict 出力、カウント関数）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] self-check.sh 作成（config 読み込み → チェック実行 → Evidence 保存）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] config/self-check.conf 作成（デフォルト設定）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] cq_tracker.sh 実装（CQ-TRK: トラッカー整合性チェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] cq_evidence.sh 実装（CQ-EVC: Evidence chain チェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] cq_ssot.sh 実装（CQ-SSOT: SSOT ドリフトチェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] Phase 1 単体テスト（Runner + 3チェック個別実行）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt (sha256:f26efaccc0c219f0)
  - 日時: 2026-02-04 04:55 JST

## Phase 1.5: kit 統合（Phase 2 から前倒し）

- [x] kit に self-check サブコマンド追加
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] kit_all() に self-check ステップ追加（verify → test → self-check → handoff）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] kit_status() に self-check トラッカー表示追加
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

- [x] handoff_builder.sh に self-check トラッカー追加
  - 判定: PASS
  - Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt
  - 日時: 2026-02-04 04:55 JST

## Phase 2: 追加チェック

- [x] cq_docs.sh 実装（CQ-DOC: ドキュメント整合チェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-060216_ciqa_CQ-DOC.txt, logs/evidence/20260204-060216_ciqa_summary.txt
  - 日時: 2026-02-04 15:02 JST
- [x] cq_lint.sh 実装（CQ-LINT: スクリプト品質チェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-083000_ciqa_CQ-LINT.txt (sha256:e71f7313026b309f)
  - 日時: 2026-02-04 17:30 JST
- [x] cq_naming.sh 実装（CQ-NAME: 命名規約チェック）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-083000_ciqa_CQ-NAME.txt (sha256:7d8b53c561f3f7d1)
  - 日時: 2026-02-04 17:30 JST
- [x] Phase 2 統合テスト（./kit self-check で 6 チェック実行）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-083000_ciqa_summary.txt (sha256:f01ad57b9e0cbad1)
  - 日時: 2026-02-04 17:30 JST

## Phase 3: 回帰検出 + 受け入れ検証

- [x] cq_regression.sh 実装（CQ-REG: 回帰検出）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-090452_ciqa_phase3_acceptance.txt (sha256:e670ce612c6ba8bc)
  - 日時: 2026-02-04 18:05 JST
- [x] ベースライン保存ロジック（last_run.json 更新）
  - 判定: PASS
  - Evidence: logs/ciqa/baseline/last_run.json, logs/evidence/20260204-090452_ciqa_phase3_acceptance.txt
  - 日時: 2026-02-04 18:05 JST
- [x] 受け入れ検証 AC-CQ01（./kit self-check で全チェック実行 + Evidence 保存）
  - 判定: PASS
  - Evidence: logs/evidence/20260204-090404_ciqa_summary.txt (sha256:c4dbd65f8b7a1040)
  - 日時: 2026-02-04 18:04 JST
- [x] 受け入れ検証 AC-CQ02（exit code が 0/1 で正しい）
  - 判定: PASS
  - 確認内容: exit 0 on all PASS, exit 1 on forced CQ-SSOT FAIL
  - 日時: 2026-02-04 18:02 JST
- [x] 受け入れ検証 AC-CQ03（Evidence 欠損を CQ-TRK が検出）
  - 判定: PASS
  - 確認内容: CQ-TRK checks MISSING_VERDICT/MISSING_EVIDENCE/MISSING_DATE on [x] items
  - 日時: 2026-02-04 18:04 JST
- [x] 受け入れ検証 AC-CQ04（SSOT 不一致を CQ-SSOT が検出）
  - 判定: PASS
  - 確認内容: SSOT file removal triggered CQ-SSOT FAIL (exit 1)
  - 日時: 2026-02-04 18:02 JST
- [x] 受け入れ検証 AC-CQ05（回帰を CQ-REG が検出）
  - 判定: PASS
  - 確認内容: CQ-REG detected REGRESSION: CQ-SSOT PASS→FAIL with baseline
  - 日時: 2026-02-04 18:03 JST
- [x] 受け入れ検証 AC-CQ06（./kit all に self-check が統合されている）
  - 判定: PASS
  - Evidence: ./kit all Step 3/4 runs self-check 7/7 PASS
  - 日時: 2026-02-04 18:04 JST
- [x] 受け入れ検証 AC-CQ07（既存 verify / test / handoff が破壊されていない）
  - 判定: PASS
  - Evidence: ./kit all: verify 9/9, test 3/3, self-check 7/7, handoff OK
  - 日時: 2026-02-04 18:04 JST
- [x] 受け入れ検証 AC-CQ08（self_check_task_tracker.md の全 Phase 0 項目が [x]）
  - 判定: PASS
  - 確認内容: Phase 0 (6/6), Phase 1 (7/7), Phase 1.5 (4/4), Phase 2 (4/4), Phase 3 (10/10) all [x]
  - 日時: 2026-02-04 18:05 JST

## Phase 4: 拡張（プラグイン方式）

- [x] self-check.sh にプラグイン自動検出ロジック追加
  - 判定: PASS
  - Evidence: logs/evidence/20260204-145013_ciqa_phase4_plugin.txt (sha256:8a183590de32dfbd)
  - 日時: 2026-02-04 23:50 JST
- [x] config での有効/無効切り替え
  - 判定: PASS
  - Evidence: logs/evidence/20260204-145013_ciqa_phase4_plugin.txt (sha256:8a183590de32dfbd)
  - 日時: 2026-02-04 23:50 JST
- [x] カスタムチェックテンプレート作成
  - 判定: PASS
  - Evidence: scripts/lib/self_checks/_template.sh, logs/evidence/20260204-145013_ciqa_phase4_plugin.txt
  - 日時: 2026-02-04 23:50 JST
- [x] プラグイン追加手順のドキュメント
  - 判定: PASS
  - Evidence: docs/self-check/self_check_plugin_guide.md, logs/evidence/20260204-145013_ciqa_phase4_plugin.txt
  - 日時: 2026-02-04 23:50 JST

---

## Progress Log

- 2026-02-04 JST | Phase 0 開始: 既存構造調査 + 4ドキュメント作成 | 判定: PASS | Evidence: docs/self-check/ 配下 + tasks/self_check_task_tracker.md
- 2026-02-04 03:46 JST | Phase 0 完了: 4ドキュメント作成＋Evidence保存＋コミット＋handoff更新 (6/6 全項目 [x]) | 判定: PASS | Evidence: logs/evidence/20260203-184649_ciqa_phase0_design.txt | sha256(16): e3814f882a3617a8
- 2026-02-04 04:55 JST | Phase 1 完了: Runner基盤＋3コアチェック＋kit統合 (11/11 全項目 [x]) | 判定: PASS | Evidence: logs/evidence/20260204-035500_ciqa_phase1_implementation.txt | sha256(16): f26efaccc0c219f0
- 2026-02-04 14:11 JST | CQ-TRK/CQ-EVC FAIL根絶: verify/test/as_built 3トラッカーにMISSING_DATE/MISSING_VERDICT/MISSING_EVIDENCE補完(49件)＋Evidence参照パス誤り2件修正 → ./kit self-check 3/3 PASS (exit 0) | Evidence: logs/evidence/20260204-051153_ciqa_summary.txt | sha256(16): b05db5a40c060746
- 2026-02-04 15:02 JST | Phase 2 CQ-DOC実装: cq_docs.sh新規作成＋self-check.sh登録 → ./kit self-check 4/4 PASS (exit 0) | Evidence: logs/evidence/20260204-060216_ciqa_summary.txt | sha256(16): e2430be451fd8de6
- 2026-02-04 17:30 JST | Phase 2 完了: cq_lint.sh/cq_naming.sh新規作成＋self-check.sh拡張＋self-check.conf追記＋Evidence命名規約違反4件修正 → ./kit self-check 6/6 PASS (exit 0) | Evidence: logs/evidence/20260204-083000_ciqa_summary.txt | sha256(16): f01ad57b9e0cbad1
- 2026-02-04 18:05 JST | Phase 3 完了: cq_regression.sh新規作成＋self-check.shにCQ-REG登録＋ベースライン保存ロジック追加＋受け入れ検証AC-CQ01〜08全PASS＋./kit all 一気通貫 ALL PASS → ./kit self-check 7/7 PASS (exit 0) | Evidence: logs/evidence/20260204-090452_ciqa_phase3_acceptance.txt | sha256(16): e670ce612c6ba8bc
- 2026-02-04 23:50 JST | Phase 4 完了: self-check.shをプラグイン自動検出方式に改修（glob cq_*.sh＋@metadata解析＋order順ソート）＋config否定記法(!lint等)対応＋_template.sh新規作成＋self_check_plugin_guide.md新規作成＋全7チェックに@metadataヘッダ追加 → ./kit self-check 7/7 PASS (exit 0)＋./kit all ALL PASS | Evidence: logs/evidence/20260204-145013_ciqa_phase4_plugin.txt | sha256(16): 8a183590de32dfbd
