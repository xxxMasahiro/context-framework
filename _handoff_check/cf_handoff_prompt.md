# cf_handoff_prompt.md（このチャットの引継ぎメモ）

## 0. 目的
- 引継ぎ運用を「_handoff_check の3ファイル添付」に簡略化した（ZIP不要）。
- 今後 Prompt.md は使わない（参照禁止）。

## 1. 今回の変更サマリ（何を追加/削除/修正したか）
- 修正対象は _handoff_check の3ファイル：
  - _handoff_check/cf_handoff_prompt.md
  - _handoff_check/cf_update_runbook.md
  - _handoff_check/cf_task_tracker_v5.md
- 変更内容（要約）：
  - Gate F（INITIAL_SETTINGS導入・固定ロール撤廃）前提に統一
  - SSOTは _handoff_check の3ファイルで統一（ZIP不要）
  - Gate Fの証跡（PR#28/commit）をタスク表と更新ログに反映

## 2. エビデンス（コミット/状態）
- Gate F（PR#28）:
  - Merge: 18edacb
  - Commit: 463b277（docs: add INITIAL_SETTINGS + role assignment (Gate F)）
- 現状：main ブランチ、作業ツリー clean（作業前提）。

## 3. 同一性確認（引用個所と同じ最新版か）
- sha256 は固定値を書かず、必要時に現物で算出する：
  - `sha256sum _handoff_check/cf_handoff_prompt.md _handoff_check/cf_update_runbook.md _handoff_check/cf_task_tracker_v5.md`

## 4. 懸念点/次にやる候補（未実施）
※致命ではないが、将来の混乱を減らす改善候補（必要なら最小差分）
- tracker 冒頭に「v3」表記が残っている箇所があれば「v5」に寄せる
- runbook に旧運用の言い回し（例：添付3ZIP/next1-3 等）が残っていれば、新運用（添付3ファイル）へ文言を寄せる
（※矛盾まではしていない前提。実際に残っているかはSSOTの現物で確認して判断する）

## 5. 新チャット側への要求（最重要）
- 添付3ファイルを最初に読むこと
- SSOTは _handoff_check の3ファイル（ZIP不要）
- 運用規範は runbook/tracker を優先し、handoff_prompt は経緯メモとして整合させる
- 次にやることは「1つ（1コマンド/1操作）」で提示すること
- 最初の安全確認として Repo Lock を実行する（`./tools/cf-guard.sh --check`）
- 役割は初期設定ファイルに従う（`WORKFLOW/TOOLING/INITIAL_SETTINGS.md` を参照）

### SSOT 3ファイルを添付できない場合の代替手順（必須）
- 代替: リポジトリの `_handoff_check/` から **直接読み込む**
- その前に必ず Guard（誤リポジトリ防止＋Repo Lock）を通す:
  - `cd /home/masahiro/projects/_cfctx/cf-context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/_cfctx/cf-context-framework"`
  - `./tools/cf-guard.sh --check`（Repo Lock: OK）
- 一括処理を希望された場合は、runbook 8.1 の「ガード付き一括テンプレ（コピペ枠）」へ誘導する  
  （一括でも Guard を先頭に置くこと）

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

## 6. 追記（2026-01-21）｜Gate F 完了（役割固定撤廃 / INITIAL_SETTINGS導入）
- 方針:
  - 役割は初期設定ファイルで割り当て（固定しない）
  - 3ファイル（CLAUDE/AGENTS/GEMINI）は入口として初期設定を参照
- エビデンス:
  - PR#28（merged）
  - Merge: 18edacb / Commit: 463b277

---

## 追記（2026-01-22）｜runbook「添付不可時の代替手順」注記の追加

### 目的
- runbook単体で読んだ新エージェントが「3ファイル添付できない」ケースで詰まる確率を下げる。

### 変更点（Add/Del/Mod）
- **Mod**: `_handoff_check/cf_update_runbook.md`
  - 「表記ポリシー（日本語統一 / SSOT）」内の「3ファイル必ず添付」直後に、
    「添付できない場合は `cf_handoff_prompt.md` の『SSOT 3ファイルを添付できない場合の代替手順』に従う。」を**1行**追記。

### 証跡（Evidence）
- Repo Lock: OK
- Commit: 35a6483（docs: runbookに添付不可時の代替手順注記を追記）
- 状態: `main == origin/main`, 作業ツリー clean
- 追記行確認: `rg -n "添付できない場合は.*代替手順" _handoff_check/cf_update_runbook.md` で該当行を確認

