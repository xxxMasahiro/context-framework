# cf_handoff_prompt.md（このチャットの引継ぎメモ）

## 0. 目的
- 引継ぎ運用を「_handoff_check の3ファイル添付」に簡略化した。
- 今後 Prompt.md は使わない（参照禁止）。

## 1. 今回の変更サマリ（何を追加/削除/修正したか）
- 修正対象は _handoff_check の2ファイルのみ：
  - _handoff_check/cf_update_runbook.md
  - _handoff_check/cf_task_tracker_v5.md
- 変更内容（要約）：
  - Prompt.md 参照を runbook/tracker から排除（運用からPrompt.md撤廃）
  - 「新チャット引継ぎ = 3ファイル添付（runbook/tracker + cf_handoff_prompt）」のテンプレを両ファイルへ統一
  - tracker の Progress Log/Updates に「引継ぎ簡略運用」系の更新を反映

## 2. エビデンス（コミット/状態）
- 直近コミット：
  - 0f70baa docs: handoff simplification (drop prompt refs)
  - c15a9c3 docs: tracker log evidence for handoff simplification
- push は最終的に成功（DNS失敗が出たが再実行で解消）。
- 現状：main ブランチ、作業ツリー clean。

## 3. 同一性確認（引用個所と同じ最新版か）
- sha256（引用スクショで示されていた値と一致）：
  - cf_update_runbook.md: 2347a6ac7021d9304f67f60dba77346d34dd5d97163eaa7bf7cd06e66e307673
  - cf_task_tracker_v5.md: 2f7a01112a589e02ecf1fced3608435a2b98e2f262fbfc7859fc582320e22fc0
→ 「引用個所のファイル」と同一の最新版。

## 4. 懸念点/次にやる候補（未実施）
※致命ではないが、将来の混乱を減らす改善候補（必要なら最小差分）
- tracker 冒頭に「v3」表記が残っている箇所があれば「v5」に寄せる
- runbook に旧運用の言い回し（例：添付3ZIP/next1-3 等）が残っていれば、新運用（添付3ファイル）へ文言を寄せる
（※矛盾まではしていない前提。実際に残っているかはSSOTの現物で確認して判断する）

## 5. 新チャット側への要求（最重要）
- 添付3ファイルを最初に読むこと
- runbook/tracker をSSOTとして準拠すること（cf_handoff_prompt はメモであり、整合性チェック対象外だが運用はSSOT準拠）
- 次にやることは「1つ（1コマンド/1操作）」で提示すること
- 最初の安全確認として Repo Lock を実行する（`./tools/cf-guard.sh --check`）
- 役割は初期設定ファイルに従う（`WORKFLOW/TOOLING/INITIAL_SETTINGS.md` を参照）

---

## 追記: 2026-01-20 PR#25（例外：PR後の後処理を“ガード付きで一括提示”してよいケース）

### 変更点（何を追加・削除・修正したか）
- Mod: `_handoff_check/cf_task_tracker_v5.md`
  - 「次にやることは1つ（1コマンド/1操作）」原則の**例外**として、Developerが明示的に依頼した場合のみ
    「PR作成→merge→branch削除→main同期→prune→status」を**まとめて提示してよい**旨を追記（詳細は runbook 8.1）。
- Mod: `_handoff_check/cf_update_runbook.md`
  - `8.1 例外: PR後の後処理をまとめて提示する場合（ガード付き一括手続きテンプレ）` を追記。
  - main保護、`--ff-only`、開始ブランチ（`TOPIC_BRANCH` / `start_branch`）、削除条件、想定repoガード等を明文化。

### エビデンス
- PR: #25（merged）
- commit: `eb6fc91`（docs: add guarded batch cleanup exception）
- merge commit: `8d888ab`
- 作業ブランチ: `wip/exception-batch-postpr-cleanup`（削除済み）
- 最終状態: `main` が `origin/main` と一致（`git status -sb` で確認）

## 5. 追記（2026-01-21）｜「役割は固定しない」方針と初期設定ファイル導入（新規タスク化）
- 背景:
  - 現状 runbook 4.2 に「エージェント→参考例（固定しない）」があり、将来の方針（Developerが役割割当を決める）と衝突し得る。
- 方針（合意したい方向）:
  - Developer は、どのエージェントにも任意の役割を割り当て可能（固定対応はしない）。
  - 役割は「初期設定ファイル（SSOT）」で決まり、CLAUDE.md / AGENTS.md / GEMINI.md は “入口/運用アダプタ” として初期設定を参照する。
  - 役割セットは以下（将来拡張可）:
    - Architect / Crafter / Orchestrator / CI/QA / Auditor
- 次の作業（大きめ・Codex推奨）:
  1) cf_task_tracker_v5.md を「まず再構築」し、この論点を新規タスクとして「## 5. タスク一覧（Gate別）」へ正規追加
  2) runbook 4.2 を「固定の想定」ではなく「デフォルト例/参考」へ格下げし、初期設定ファイルをSSOTとして明記
  3) CLAUDE.md / AGENTS.md / GEMINI.md（＋template群）を、初期設定ファイル前提で矛盾なく更新
- 安全:
  - 新チャット開始時の最初の安全確認は `./tools/cf-guard.sh --check`
  - 破壊的操作（restore/reset/clean/rm等）は Guard 経由を推奨
