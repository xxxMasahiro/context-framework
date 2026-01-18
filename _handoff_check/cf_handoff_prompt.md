<!-- CFCTX_LANG_POLICY_CANONICAL_V1 -->
## 表記ポリシー（日本語統一 / SSOT）

- 規範文書（Charter/Mode/Workflow/Artifacts/Skills）は **日本語本文が正（SSOT）**。
- `PROMPTS/` や各ツール入口（`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`）は、**日本語本文＋必要最小限の英語要約を併記可**（規範は日本語側）。
- 固有名詞（パス/コマンド/ファイル名/GitHub用語）は **英語表記のまま固定**（無理に日本語化しない）。
- 詳細は `_handoff_check/cf_update_runbook.md` の「言語ポリシー」記載を正とする（このブロックは要約）。


<!-- CFCTX_UPDATE_ZIP_DEPRECATED_V1 -->
## 追記（2026-01-17）：ZIP運用廃止 / SSOTは _handoff_check

- 今後の引継ぎはZIPを作らない。SSOTはリポジトリ直下 `_handoff_check/` の3ファイル。
- `_handoff_cache/` は過去の証跡・互換用（原則参照しない）。
- 文中の `*.zip` は旧称ラベルとして残る場合がある（実体ZIPは前提にしない）。
- バックアップは `git tag`（作業前タグ）を標準とする（zipバックアップは廃止）。


# 引継ぎプロンプト｜cf-context-framework（2026-01-17）

あなたは **cf-context-framework** の作業継続を支援するAI（Architect/PM）です。  
このリポジトリは **cf-dist の手順書ZIP（ベースライン不変）を唯一の真実**とし、差分を安全に運用するためのフレームワークです。

## 0. 運用ルール（最重要）
- **Single Source of Truth（優先順位）**: Charter → Mode（lite/standard/strict） → Artifacts（Task Lists / Implementation Plan / Walkthrough） → Skills
- 進行は **「次にやること1つ」** だけ提示し、実行結果が貼られてから次へ進む。
- 監査（Auditor）は独立ロール。**AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**

## 1. 現在の状態（ここまで完了）
- GitHub PR: **PR #1（wip/v0.1.5 → main）** を作成し、**マージ済（Merged & Closed）**。
- GitHubのブランチ: **mainのみ**（`wip/v0.1.4` / `wip/v0.1.5` は削除済）。
- main へ pull 済みで working tree clean。
- 追加した主な成果物（Gate D / Audit 追加）:
  - `WORKFLOW/AUDIT.md`
  - `PROMPTS/AUDITOR.md`
  - `ARTIFACTS/AUDIT_REPORT.md`
  - `ARTIFACTS/AUDIT_CHECKLIST.md`
  - `ARTIFACTS/EXCEPTIONS.md`
- 既存ファイルの整合更新（PR差分）:
  - `WORKFLOW/GATES.md` / `WORKFLOW/BRANCHING.md` / `WORKFLOW/MODES_AND_TRIGGERS.md`
  - `ARTIFACTS/TASK_LISTS.md` / `ARTIFACTS/IMPLEMENTATION_PLAN.md` / `ARTIFACTS/WALKTHROUGH.md`
- 追加の運用メモ:
  - `remote.origin.fetch` が特定ブランチに固定されていると `git fetch --prune` が失敗する場合があるため、
    `+refs/heads/*:refs/remotes/origin/*` に戻して解消済。

## 2. 直近の目的
- **next1（Auditor / Gate D）** のテンプレ/プロンプト/運用ドキュメントを main に統合した。
- 次は **next2（3常駐指示ファイル共存）** と **next3（Skills統合）** を進める。

## 3. 未完了・次にやること（この順で）
1) **next2_work.zip** を展開し、以下を設計・配置（Gate C）
   - `CLAUDE.md`（Claude Code）
   - `AGENTS.md`（Codex）
   - `GEMINI.md`（Antigravity）
   - 3ファイルが矛盾なく共存し、上位（Charter/Mode/Artifacts/Skills）参照が統一されていること
2) **next3_work.zip**（Skills統合）の方針を、フレームワーク側で固定し、上位レイヤに従属させて再現性を上げる
3) 追記候補（保留）
   - 文言統一案: 「AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う」をドキュメント側で1行に統一

## 4. 次のAIが最初に確認すべきこと（※“1手だけ”）
**次の1手:** ユーザーに以下を実行してもらい、結果を貼ってもらう。

```bash
cd /home/masahiro/projects/_cfctx/cf-context-framework && git status -sb
```

- 目的: main上で clean か、次作業に向けて状態が揃っているかを確認する。

---

## 参考（ユーザー要望）
- 実行結果を貼った後に、**その後に使ったコマンドの意味（復習用の説明）**も毎回提示する。
- 何か変更した際は「具体的に何を削除・追加・修正したのか」を明示する。
- ヒアドキュメント（`cat <<'EOF'`）を案内する場合は、**全文を一括コピペ可能な形**で提示する。


---

## 追記（2026-01-17）｜本チャットでの追加作業（未マージ）

### 状態の更新（追記）
- 追加で **文言統一（監査運用の1行統一）**を、以下4ファイルに反映した。
  - `WORKFLOW/AUDIT.md`
  - `ARTIFACTS/AUDIT_REPORT.md`
  - `ARTIFACTS/AUDIT_CHECKLIST.md`
  - `PROMPTS/AUDITOR.md`
- 現時点では **コミット/プッシュは未実施**（ステージ済みの可能性あり）。

### 未解決（次回に最初に確定すること）
- **言語ポリシー（層×言語）**を確定する。
  - 基本案: **規範（Charter/Mode/Workflow/Artifacts/Skills）は日本語を正**。
  - 例外案: `PROMPTS/` や各ツール入口（CLAUDE/AGENTS/GEMINI）は、日本語本文＋必要なら英語の短い要約を併記（ただし規範は日本語側のみ）。

### 次のAIが最初に確認すべきこと（※“1手だけ”｜追記版）
**次の1手:**
```bash
cd /home/masahiro/projects/_cfctx/cf-context-framework && git status -sb
```
- 目的: ブランチ名、ステージ状況、差分の有無を確定してから「言語ポリシー確定→次工程」へ進む。


## 追記（2026-01-17）
### 最新参照（v5）
- Single Source of Truth: `cf_task_tracker_v5.md`
- 本文中に `cf_task_tracker_vN.md` / `cf_task_tracker_v4.md` 等の旧参照が残っていても、履歴として保持し、**最新は `cf_task_tracker_v5.md` を参照**する。

## 翻訳レイヤ（抽象→具体の戻り先）

- 迷ったらまず `WORKFLOW/TRANSLATION_LAYER.md` を参照する（憲章/Modeの原則を、Artifactsへ落とす if/then 判断手順）。
- Artifacts側の参照導線：`ARTIFACTS/TASK_LISTS.md` / `ARTIFACTS/WALKTHROUGH.md`

