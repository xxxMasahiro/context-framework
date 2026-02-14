# as-built 作成トラッカー（Temporary Verification Kit）

## 目的
- 本体repo（read-only）を逆算し、**as-built Gate Map** を根拠（file:line）付きで作る
- 次に **as-built 要件/仕様/実装計画** を作る（SSOT verify_* との差分が出たら判断）
- すべて「1手運用（1コマンド/1操作）」で進め、証跡を残す

## 運用ルール（最小）
- 根拠は必ず `path:line` を付ける
- 検索 `rg/grep` は必ず `|| true`
- 変更が入ったら Add/Del/Mod を明示
- 証跡は `logs/evidence/` に保存し、参照をここへ残す

## タスク
### Step 1: as-built Gate Map（根拠付き）
- [x] A〜D（WORKFLOW系）根拠抽出（file:line）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt
  - 日時: 2026-02-03 05:14 JST
- [x] 0/E/F/G/H/I/J（runbook/tracker系）根拠抽出（file:line）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt
  - 日時: 2026-02-03 05:14 JST
- [x] 実装参照点（controller/rules等）で裏付け（最低 Gate C は済）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt
  - 日時: 2026-02-03 05:16 JST
- [x] Gate Map（Markdown）を1枚に統合（Gateごとに inputs/outputs/依存/導線）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt
  - 日時: 2026-02-03 05:18 JST

### Step 2: as-built 要件/仕様/実装計画
- [x] 要件（as-built requirements）作成
  - 判定: PASS
  - Evidence: logs/evidence/20260203-064358_as_built_inventory_sha256.txt
  - 日時: 2026-02-03 06:43 JST
- [x] 仕様（as-built spec）作成
  - 判定: PASS
  - Evidence: logs/evidence/20260203-064358_as_built_inventory_sha256.txt
  - 日時: 2026-02-03 06:43 JST
- [x] 実装計画（as-built implementation plan）作成
  - 判定: PASS
  - Evidence: logs/evidence/20260203-064358_as_built_inventory_sha256.txt
  - 日時: 2026-02-03 06:43 JST
- [x] SSOT verify_* と差分比較（SSOT修正か実装寄せか判断）
  - 判定: PASS（重大な矛盾なし。差分は「実装寄せ」or「Phase 4保留」）
  - Evidence: logs/evidence/20260203-175331_ssot_vs_asbuilt_diff.txt
  - 差分12件: 実装寄せ7件、Phase4保留3件、軽微不足2件
  - 日時: 2026-02-03 17:53 JST

### Step 3: テストに繋ぐ前提整理
- [x] Phase1〜3 テスト観点の棚卸し（共通→Gate固有→横断E2E）
  - 判定: PASS
  - Evidence: logs/evidence/20260203-175358_step3_test_perspectives.txt
  - 観点: Phase1(環境6項目), Phase2(Gate固有4項目), Phase3(E2E4項目)
  - 日時: 2026-02-03 17:53 JST
- [x] テスト用トラッカー（tasks/test_task_tracker.md）へ反映
  - 判定: PASS
  - Evidence: logs/evidence/20260203-175358_step3_test_perspectives.txt
  - 確認内容: test_task_tracker.md の全6チェック項目を実行→[x]化→Evidence index/Progress Log追記
  - 日時: 2026-02-03 17:53 JST

### Step 4: as-built Gate Map v1.2 全面改訂
- [x] Gate Map を as-built 3 文書（v1.2）準拠に全面改訂
  - 判定: PASS
  - Evidence: as_built/as_built_gate_map.md（v1.2、741 行）
  - 改訂内容: §0 位置づけ、§1 検証キット概説、§2 ディレクトリ構造、§3 コマンド詳細ガイド（6 コマンド各「なぜ/何が/どうして」）、§4 Gate A〜I 詳細、§5 セキュリティ（REQ-S05/SPEC-D03）、§6 NOPASSWD/TTY 詳細解説、§7 トレーサビリティ、§8 FAQ、§9 変更履歴
  - 日時: 2026-02-06 23:17 JST

### Step 5: REQ-S02 強化（CQ-RO + ro mount 検証）
- [x] CQ-RO チェックプラグイン作成 + Phase 1 ro mount 検証統合 + as-built 4 文書 v1.3 更新
  - 判定: PASS
  - Evidence: cq_readonly.sh (CQ-RO PASS), run_tests.sh:112-128 (SKIP), as_built 4 文書 v1.3
  - 日時: 2026-02-07 01:12 JST

### Step 6: バグ修正反映（§H/§I: スクリプト品質修正 + as-built v1.4 更新）
- [x] 8 ファイルのバグ修正（verify_gate.sh, run_tests.sh, evidence.sh, kit, gate_a/b/g/i.sh）+ as-built 4 文書 v1.4 更新
  - 判定: PASS
  - Evidence: claude_codeの回答.txt §H/§I, as_built 4 文書 v1.4
  - 日時: 2026-02-07 JST

### Step 7: Gate 動的スケーラビリティ対応（run_tests.sh + tracker_updater.sh + gate_registry.sh + as-built v1.5 更新）
- [x] run_tests.sh A-I 固定 3 箇所→動的化 + tracker_updater.sh セクション自動生成 + gate_registry.sh Gate ID バリデーション一貫化（_gr_is_safe_gate_id ヘルパー、列挙+source 前 2 箇所）+ as-built 4 文書 v1.5 更新
  - 判定: PASS
  - Evidence: run_tests.sh:17,152-161,211-215,378-384, tracker_updater.sh:110-169, gate_registry.sh:16-19,41,67-70, as_built 4 文書 v1.5
  - 日時: 2026-02-07 JST

### Step 8: Codex 評価指摘 4 件修正（fail-closed 化 + as-built v1.6 更新）
- [x] verify_all.sh Gate 0 件ガード + SSOT MATCH 必須化 + gate_registry.sh unsafe ID→FATAL + while read 堅牢化 + as-built 4 文書 v1.6 更新
  - 判定: PASS
  - Evidence: verify_all.sh:39-42,138,155-158, gate_registry.sh:38,42-43,64,67-69, as_built 4 文書 v1.6
  - 日時: 2026-02-07 JST

### Step 9: Codex 評価追加指摘修正（Phase 2 偽 PASS 防止 + as-built v1.7 更新）
- [x] run_tests.sh Phase 2 Gate 0 件ガード追加 + as-built 4 文書 v1.7 更新
  - 判定: PASS
  - Evidence: run_tests.sh:217-220, as_built 4 文書 v1.7
  - 日時: 2026-02-07 JST

### Step 10: Gate A/B 偽 FAIL バグ修正（repo_grep 引数ずれ + as-built v1.8 更新）
- [x] gate_a.sh:90 + gate_b.sh:57 の `repo_grep -i` 引数ずれ修正（`-i` 除去）+ as-built 4 文書 v1.8 更新
  - 判定: PASS
  - Evidence: gate_a.sh:90, gate_b.sh:57, verify_all.sh 実行結果 9 PASS / 0 FAIL + SSOT MATCH, as_built 4 文書 v1.8
  - 日時: 2026-02-07 JST

### Step 11: Phase 5 lockdown/unlock 実装 + MAIN_REPO バリデーション強化（+ as-built v1.9 更新）
- [x] lockdown.sh + unlock.sh 新規作成 + kit lockdown/unlock サブコマンド + evidence.sh _validate_main_repo 4 段階検証 + discover_main_repo find 全候補走査化 + as-built 4 文書 v1.9 更新
  - 判定: PASS
  - Evidence: scripts/lockdown.sh, scripts/unlock.sh, kit, evidence.sh, as_built/ 4 ファイル v1.9, verify_all.sh 9 PASS / 0 FAIL + SSOT MATCH
  - 日時: 2026-02-07 JST

## Progress Log（記録）
- （ここに追記：日時 | 何をやった | Evidence 参照）

- 2026-02-03 05:14:54 JST | Step1 Gate Map | Gate Map updated (Gate J/J0 evidence) + sha256 recorded | Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt | Artifact: as_built/as_built_gate_map.md

- 2026-02-03 05:16:45 JST | Step1 Gate Map | Step1 checkboxes set to [x] | Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt | Artifact: as_built/as_built_gate_map.md

- 2026-02-03 05:18:45 JST | Step1 Gate Map | FIX: Step1 checkboxes were escaped (\[ \]) -> normalized to [x] | Evidence: logs/evidence/20260203-051454_as_built_gate_map_sha256.txt | Artifact: as_built/as_built_gate_map.md

- 2026-02-03 JST | Step2 as-built 3ファイル完成 | 骨格→完成版に置換: requirements(114行), spec(183行), implementation_plan(122行) | CFCTX_VERIFY_ROOT スクリプト別対応表、SSOT差分表、Phase 1-4 実装状態を記載 | Artifacts: as_built/as_built_requirements.md, as_built/as_built_spec.md, as_built/as_built_implementation_plan.md

- 2026-02-03 17:53 JST | Step2 SSOT差分比較完了 | verify_* 3ファイルと as_built 3ファイルを比較。差分12件（実装寄せ7/保留3/軽微2）。重大矛盾なし | Evidence: logs/evidence/20260203-175331_ssot_vs_asbuilt_diff.txt

- 2026-02-03 17:53 JST | Step3 テスト観点棚卸し＋トラッカー反映完了 | Phase1〜3計14観点を棚卸し。test_task_tracker.md の全6項目を実行→[x]化→Evidence 6件保存 | Evidence: logs/evidence/20260203-175358_step3_test_perspectives.txt

- 2026-02-06 23:17 JST | Step4 Gate Map v1.2 全面改訂 | as-built 3 文書（v1.2）準拠に書き直し。コマンド詳細ガイド（6 コマンド）、Gate A〜I 詳細、セキュリティ姿勢、NOPASSWD/TTY 解説、FAQ 追加。741 行 | Artifact: as_built/as_built_gate_map.md

- 2026-02-07 01:12 JST | Step5 REQ-S02 強化 | CQ-RO チェック作成（cq_readonly.sh: 13 種 write パターン検出）+ Phase 1 ro mount 検証統合（run_tests.sh: オプション）+ as-built 4 文書 v1.3 更新 | Artifacts: scripts/lib/ciqa_checks/cq_readonly.sh, scripts/run_tests.sh, as_built/ 4 ファイル

- 2026-02-07 JST | Step6 バグ修正反映 | 8 ファイル修正（verify_gate.sh, run_tests.sh, evidence.sh, kit, gate_a/b/g/i.sh）+ as-built 4 文書 v1.4 更新 | Artifacts: 修正対象 8 ファイル, as_built/ 4 ファイル

- 2026-02-07 JST | Step7 Gate 動的スケーラビリティ | run_tests.sh A-I 固定 3 箇所→動的化 + tracker_updater.sh セクション自動生成 + gate_registry.sh Gate ID バリデーション一貫化（_gr_is_safe_gate_id ヘルパー、列挙+source 前 2 箇所）+ as-built 4 文書 v1.5 更新 | Artifacts: run_tests.sh, tracker_updater.sh, gate_registry.sh, as_built/ 4 ファイル

- 2026-02-07 JST | Step8 Codex 評価指摘 4 件修正 | verify_all.sh Gate 0 件ガード + SSOT MATCH 必須化 + gate_registry.sh unsafe ID→FATAL + while read 堅牢化 + as-built 4 文書 v1.6 更新 | Artifacts: verify_all.sh, gate_registry.sh, as_built/ 4 ファイル

- 2026-02-07 JST | Step9 Codex 評価追加指摘修正 | run_tests.sh Phase 2 Gate 0 件ガード追加（プロセス置換 exit code 非伝播による偽 PASS 防止）+ as-built 4 文書 v1.7 更新 | Artifacts: run_tests.sh, as_built/ 4 ファイル

- 2026-02-07 JST | Codex 最終評価 | 「条件付きで運用可能」判定。コード修正指摘ゼロ。CI 基盤は本番運用可。as-built 更新なし（v1.7 維持）

- 2026-02-07 JST | Codex 再確認評価（4 回目） | 「条件付きで運用可能」再確認。新規指摘ゼロ。CI 基盤 vs 対象リポジトリの切り分け確定。as-built 更新なし（v1.7 維持）

- 2026-02-07 JST | Step10 Gate A/B 偽 FAIL バグ修正 | gate_a.sh:90, gate_b.sh:57 の `repo_grep -i` 引数ずれ修正（`-i` 除去）。9 PASS / 0 FAIL + SSOT MATCH 達成。as-built 4 文書 v1.8 更新 | Artifacts: scripts/lib/gate_a.sh, scripts/lib/gate_b.sh, as_built/ 4 ファイル

- 2026-02-07 JST | CQ-TRK FAIL 解消 + Go 判定 | verify_task_tracker.md セキュリティ 16 項目の `判定: Pass`→`PASS` 統一。CIQA 8/8 PASS。Codex Go 判定達成。全系統合格（Gate 9/9 + Test 3/3 + CIQA 8/8）

- 2026-02-07 JST | Step11 Phase 5 + MAIN_REPO バリデーション | lockdown.sh（quarantine + chmod go-rwx）+ unlock.sh（二段階解除）+ evidence.sh _validate_main_repo（4 段階: SSOT sha256 照合）+ find 全候補走査 + kit lockdown/unlock + as-built 4 文書 v1.9 | Artifacts: scripts/lockdown.sh, scripts/unlock.sh, kit, evidence.sh, as_built/ 4 ファイル
