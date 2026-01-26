<!-- CFCTX_LANG_POLICY_CANONICAL_V1 -->
## 表記ポリシー（日本語統一 / SSOT）

- 新しいチャットへ引き継ぐ場合は、**_handoff_check の3ファイル（cf_update_runbook.md / cf_task_tracker_v5.md / cf_handoff_prompt.md）を必ず添付**する（新運用の固定）。
- 規範文書（Charter/Mode/Workflow/Artifacts/Skills）は **日本語本文が正（SSOT）**。
- `PROMPTS/` や各ツール入口（`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`）は、**日本語本文＋必要最小限の英語要約を併記可**（規範は日本語側）。
- 固有名詞（パス/コマンド/ファイル名/GitHub用語）は **英語表記のまま固定**（無理に日本語化しない）。
- 詳細は `_handoff_check/cf_update_runbook.md` の「言語ポリシー」記載を正とする（このブロックは要約）。


<!-- CFCTX_UPDATE_ZIP_DEPRECATED_V1 -->
## 追記（2026-01-17）：ZIP運用廃止 / SSOTは _handoff_check

## 引継ぎ簡略運用（旧引継ぎ文書不使用）

- 新チャット添付は次の3ファイルのみ（整合性対象は3ファイル）:
  - `_handoff_check/cf_update_runbook.md`
  - `_handoff_check/cf_task_tracker_v5.md`
  - `_handoff_check/cf_handoff_prompt.md`（都度更新の運用メモだが、SSOTパックに含める）
- SSOTは _handoff_check の3ファイル（運用規範は runbook/tracker を優先）
- 引継ぎプロンプト（テンプレ・表記固定）:
  > 前回のチャットからの引継ぎを行います。まずは、添付した3つのファイル（cf_handoff_prompt.md / cf_update_runbook.md / cf_task_tracker_v5.md）をすべて読み込んで確認し、整合性の取れた適切な引継ぎ構成を構築してください。cf_update_runbook.md と cf_task_tracker_v5.md に完全準拠し、cf_handoff_prompt.md を参照してこれまでの経緯と次の指示（次にやること1つ）を提示してください。

- 今後の引継ぎはZIPを作らない。SSOTはリポジトリ直下 `_handoff_check/` の3ファイル。
- `_handoff_cache/` は過去の証跡・互換用（原則参照しない）。
- 文中の `*.zip` は旧称ラベルとして残る場合がある（実体ZIPは前提にしない）。
- バックアップは `git tag`（作業前タグ）を標準とする（zipバックアップは廃止）。


# cf-context-framework アップデート｜タスク管理票 v5（Skills運用統合 / 進捗・証跡ログ付き）

このファイルは、`cf_update_runbook.md` に従って **一気通貫で安全にアップデート**するためのタスク管理票です。  
チェックボックスで進捗を管理し、各ステップの **実行コマンド・結果・証跡（Evidence）** を残せます。  
さらに v3 では、**Skills（再利用可能な導入手順モジュール）**の「適用ログ」と「Skill作成/更新タスク」を統合しています。

---

# cf-context-framework アップデート｜タスク管理票 v5（スリム版）

このファイルは、runbook 8 に完全準拠し、**未完了タスクと直近更新だけを最短で確認**できるよう整理したもの。
詳細テンプレ/完了済み一覧/旧ログは runbook 付録（tracker退避）を参照する。

## 1. 運用ルール（最小）
- runbook 8 完全準拠（1手運用 / 変更点明示 / 復習用の意味）
- Repo Lock: `./tools/cf-guard.sh --check`
- 変更は Add/Del/Mod を明示し、Evidence は更新ログへ残す

## 2. 進捗サマリ
- 未完了タスク: なし
- 次にやる1手: 次の指示待ち（必要なら Gate H / Phase 1 に [ ] を追加）

## 3. タスク一覧（未完了のみ）
- （未完了なし）
- 追加ルール: 新規タスクは Gate H / Phase 1 に追記（詳細テンプレは runbook 付録を参照）

## Gate H（新規タスクの入口）
### Phase 1（未着手タスク）
- [ ] （新規タスクをここへ追記：1行1タスク、Evidenceは必要に応じて）

## 4. 更新ログ（Progress Log/Updates）※直近のみ
- 2026-01-26T22:01:33+0900 | UPD-20260126-03 | Gate H を新規タスク入口へ統一（Gate G 完了扱い） | Evidence: PR予定 wip/gate-h-entrypoint
- 2026-01-26T21:28:50+0900 | UPD-20260126-02 | trackerスリム化（テンプレ/完了タスク/旧ログをrunbook付録へ移設、参照更新） | Evidence: PR予定 wip/slim-tracker-v5
- 2026-01-25T23:57:27+09:00 | UPD-20260125-05 | Gate G: STEP-G007 Signature集計ツールをDone更新 | Evidence: PR #59 / merge 795d53f / topic bc0a5c7
- 2026-01-25T22:23:20+09:00 | UPD-20260125-04 | Gate G: STEP-G006 定義固定をDone更新 | Evidence: PR #57 / merge 6305b49 / topic 1a1f3eb
- 2026-01-25T17:52:33+09:00 | UPD-20260125-03 | Gate G: STEP-G005 受入テスト（チェック項目）追記 | Evidence: PR #54 / merge f14ec13 / topic 69aad10
- 2026-01-25T14:05:42+0900 | UPD-20260125-02 | Gate G: STEP-G201〜G204 Done更新 | Evidence: WORKFLOW/SKILLS_INTEGRATION.md / WORKFLOW/AUDIT.md / commit 97535ef
- 2026-01-25T11:27:33+09:00 | UPD-20260125-01 | Gate G: STEP-G104 受入テスト PASS | Evidence: procedure-mismatch / _handoff_check/cf_update_runbook.md（パッチ事故防止） / HEAD=637b0db
- 2026-01-24T19:10:00+09:00 | UPD-20260124-07 | Gate G: STEP-G103 新カテゴリ追加ルール 判定 | Evidence: Repo Lock OK / SSOT参照 / 判定=必要
- 2026-01-24T18:41:29+09:00 | UPD-20260124-06 | Gate G: STEP-G102 パターン分類案 追記 | Evidence: Gate G Phase2: パターン分類案
- 2026-01-24T18:20:11+09:00 | UPD-20260124-05 | Gate G: STEP-G101 固定カテゴリ案 追記 | Evidence: Gate G Phase2: 固定カテゴリ案

- 旧ログは runbook 付録（tracker退避）へ移設
