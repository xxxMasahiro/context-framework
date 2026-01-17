新チャット開始：添付の Prompt.md に従って開始してください。最初に「次にやること1つ」だけ指示してください。

## 重要: 現行SSOT（_handoff_check / ZIP不要）
- **SSOTはリポジトリ直下 `_handoff_check/` の3ファイル**（`cf_handoff_prompt.md` / `cf_task_tracker_v5.md` / `cf_update_runbook.md`）。**ZIP運用は廃止**。
- この `Prompt.md` 内で `ZIP` / `SHA` 等が出ても、**「## 旧運用（廃止/Deprecated）」配下は参照しない**。
- 指示は常に **「次にやること1つ（1コマンド/1操作）」**だけ。実行結果を貼ったら次へ。
- 実行結果の後に、使ったコマンドの意味（復習）も毎回セットで提示。
- 変更したら「何を追加/削除/修正したか」を明示。
- コピペが必要な文は必ず **コードブロック（コピーブロック）**で提示。
- ドキュメント表記は日本語に統一。
- トラッカーは `[ ]→[x]` を例外的に許容（完了時）。同時に末尾の Progress Log/Updates へ記録を追記。

<!-- CFCTX_UPDATE_ZIP_DEPRECATED_V1 -->
## 運用ルール更新（2026-01-17）：ZIP廃止 / SSOTは _handoff_check

- ZIP（例: `cf_handoff_and_tracker.zip`）の作成・検証・展開は行わない。
- 作業対象（SSOT）はリポジトリ直下 `_handoff_check/` の3ファイル：
  - `cf_handoff_prompt.md`（入力/今回の指示）
  - `cf_update_runbook.md`（手順）
  - `cf_task_tracker_vN.md`（トラッカー）
- `_handoff_cache/` は過去の証跡・互換用。原則参照しない（必要時のみ監査/検証用）。
- 文中の `*.zip`（例: `next2_work.zip` 等）は「旧称ラベル」として残る場合があるが、実体ZIPは前提にしない。

## 最初に実行する1コマンド（必須）
```bash
cd /home/masahiro/projects/_cfctx/cf-context-framework && git status -sb
```
- 目的: ブランチ名・差分・作業状態を確定する（迷いを防ぐ）。

# Prompt.md（次チャット開始用：引継ぎ実行 / 現行運用）

> この Prompt.md は **新しいチャットで最初にAIへ渡す指示**です。
> ZIP運用は廃止済み。**SSOTは常に `_handoff_check/` の3ファイル**です。
> 添付は Prompt.md のみで十分に開始できるよう、手順と運用ルールをこのファイルに統合します。

---

## 0. ゴール（最重要）
- `_handoff_check/` の **3ファイルを漏れなく読む**
- **Single Source of Truth は常に `_handoff_check/`**
- 3ファイル間の参照を整合させ、**追記ベース**で更新する
- **ZIPの作成/検証/展開は行わない（廃止）**

---

## 1. SSOT（必須）
- `cf_handoff_prompt.md`（入力/今回の指示）
- `cf_update_runbook.md`（手順）
- `cf_task_tracker_vN.md`（トラッカー）

> これら以外は補助資料。**判断は常にSSOTに寄せる**。

---

## 2. 絶対ルール（運用）
1. **最初の返信で全体像を短く説明**してから、ユーザーに「次にやること1つ」だけ指示する。
2. ユーザーへの指示は **常に1つだけ**（1コマンド/1操作）。結果が貼られたら次へ進む。
3. 実行結果が貼られたら、**その後に使ったコマンドの意味（復習用）**を必ず添える。
4. 変更が入ったら、**何を追加/削除/修正したか**を箇条書きで明示する。
5. **既存の記載は削除・改変しない（追記のみ）**。削除・改変が必要な場合は **廃止/Deprecated を明記して残す**。
6. **ファイル名は変更しない**（Prompt.md / 3ファイルの命名を維持）。
7. ヒアドキュメント（`cat <<'EOF'`）を案内する場合は、**全文を一括コピペできる形**で提示する。

---

## 3. 新チャットでの作業フロー（順番固定）
### Step 0：最初の返信（必須の型）
- 全体像を短く説明（SSOT確認 → 参照整合 → 追記更新 → 変更点提示）
- その後、**次にやること1つ**を指示（原則 Step 1 のコマンド）

### Step 1：作業状態の確認（必須）
ユーザーに次の1手を依頼：
- `cd /home/masahiro/projects/_cfctx/cf-context-framework && git status -sb`

> 結果が貼られたら、**コマンドの意味（復習用）**を添える。

### Step 2：SSOT 3ファイルの読込（必須）
- `cf_handoff_prompt.md`
- `cf_update_runbook.md`
- `cf_task_tracker_vN.md`（番号は最大値を採用）

### Step 3：参照整合（必須）
- 3ファイル内のトラッカー参照が `cf_task_tracker_v{N}.md` で一致しているか確認
- 不一致があれば **追記ブロック**で最新参照を宣言して整合を取る

### Step 4：更新（追記のみ）
- `cf_update_runbook.md` の手順に従って追記
- `cf_task_tracker_v{N+1}.md` を作成（必ず +1）し、参照を追記で更新
- 変更点（追加/削除/修正）を明示する

### Step 5：報告
- 何を追加/削除/修正したかを箇条書きで提示
- 次の1手を1つだけ指示

---

## 4. 「ZIPが最新か不明」問題への結論
SSOTは常に `_handoff_check/` の3ファイル。ZIPは廃止。
万一 ZIP が提示された場合は **参考資料として扱い**、必要に応じて diff/hash で差異を確認し、**最終的に SSOT へ寄せて追記更新**する。

---

## 旧運用（廃止/Deprecated：履歴保持）
> ⚠️ **ここから下は旧ZIP運用の履歴保管です。実行/参照しない。**
> 現行運用: **SSOT = `_handoff_check/` の3ファイル**（ZIP不要）に従う。
> **復旧・更新・引継ぎは `_handoff_check/` を直接参照して行う。ZIPの作成/展開は禁止。**
> ---
> 以下は **旧ZIP運用の手順**。参照しない（必要な場合のみ履歴確認用）。

# Prompt.md（次チャット開始用：引継ぎ実行）

> この Prompt.md は **新しいチャットで最初にAIへ渡す指示**です。  
> 添付された引継ぎZIPを展開・全読込し、**入力定義（cf_handoff_input.md）**と**出力定義（cf_handoff_output.md）**に矛盾なく準拠した状態で、次回へ引き継げる成果物（ZIP）を生成してください。

---

## 0. ゴール（最重要）
- 添付ZIP（`cf_handoff_and_tracker.zip`）を展開し、**中の全ファイルを漏れなく読む**
- **Single Source of Truth は常にトラッカー（`cf_task_tracker_vN.md`）**
- `cf_handoff_input.md`（入力定義）と `cf_handoff_output.md`（出力定義）に従い、
  - 3ファイル間の参照を整合させ
  - **追記のみ**で更新し
  - 次回へ渡すZIPを生成する

---

## 1. このチャットに添付されている前提のファイル
### 1.1 規則ドキュメント（必須）
- `cf_handoff_input.md`：**入力（前回→今回）の定義**（受領物・SSOT・v確定手順）
- `cf_handoff_output.md`：**出力（今回→次回）の定義**（生成物・テンプレ・追記ルール）

### 1.2 成果物ZIP（必須）
- `cf_handoff_and_tracker.zip`
- `cf_handoff_and_tracker.zip.sha256`（ZIPの外に置かれていること）

> 不足があれば「不足ファイル名」を明記し、**添付依頼だけ**して止まってください。

---

## 2. 絶対ルール（運用）
1. **最初の返信で「これから行う作業（全体像）」を短く説明してから**、ユーザーに「次にやること（1つ）」を指示する。  
2. ユーザーへの指示は **常に1つだけ**（1コマンド/1操作）。実行結果を貼ってもらってから次へ進む。  
3. ユーザーが実行結果を貼ったら、**その後に使ったコマンドの意味（復習用）**も毎回セットで提示する。  
4. 変更が入ったら、**何を追加/削除/修正したか**を必ず箇条書きで明示する。  
5. **既存の記載は削除・改変しない（追記のみ）**。削除・改変が必要な場合は **developer の明示的許可があるときだけ**。  
6. **ファイル名／ZIP名は原則変更しない**（既に `cf_handoff_and_tracker.zip` 運用なら同名維持）。

---

## 3. あなた（AI）が実施する作業フロー（順番固定）
### Step 0：最初の返信（必須の型）
- まず以下の全体像を短く説明：
  1) 添付ファイル確認 → 2) SHA256検証 → 3) ZIP展開＆全読込 → 4) v番号確定（トラッカー基準）  
  → 5) 参照整合（3ファイル） → 6) 追記で更新 → 7) ZIP出力
- その後、**次にやること1つ**（原則 Step 1 のSHA検証）を指示する。

### Step 1：SHA256検証（必須）
ユーザーに次の1手を依頼：
- `sha256sum -c cf_handoff_and_tracker.zip.sha256`

> OK/NG を判定し、NGなら原因切り分け以外に進まない。

### Step 2：ZIP展開 → 同梱物一覧（必須）
ZIPを展開し、**中身のファイル一覧**を提示して確認する。  
期待する同梱物は `cf_handoff_input.md` の「入力アーティファクト（3つ）」定義に従う：
- `cf_handoff_prompt.md`
- `cf_update_runbook.md`
- `cf_task_tracker_v?.md`

> 混入や欠落があれば、その事実を明確に報告する（勝手に削除はしない）。

### Step 3：トラッカー基準で v番号を確定（必須）
`cf_handoff_input.md` の規定に従い、次の優先順位で **N を確定**する：
1) ファイル名：`cf_task_tracker_v{N}.md`  
2) 先頭見出し（タイトル）  
3) 本文の明示

確定後、**以後の参照はすべてこの v（N）に揃える**。

### Step 4：3ファイルの参照整合（必須）
- `cf_update_runbook.md` 内のトラッカー参照が `cf_task_tracker_v{N}.md` になっているか
- `cf_handoff_prompt.md` 内のトラッカー参照が `cf_task_tracker_v{N}.md` になっているか

> 不一致があれば **トラッカー（SSOT）に合わせて**整合させる。  
> ただし、**既存本文の置換ではなく追記ブロック**（例：`## 追記（YYYY-MM-DD）`）で「最新参照」を宣言して整合を取る。

### Step 5：出力（次回へ渡す）を生成（必須）
`cf_handoff_output.md` の定義に従い、次を作る：
- `cf_task_tracker_v{N+1}.md`（必ず +1）
- `cf_update_runbook.md`（参照を `v{N+1}` に統一：追記で）
- `cf_handoff_prompt.md`（参照を `v{N+1}` に統一：追記で）
- 3ファイルを同梱したZIP（**既に `cf_handoff_and_tracker.zip` 運用なら同名で出力**）
- 変更点一覧（追加/削除/修正）

---

## 4. 成功条件（チェックリスト）
- [ ] ZIPのSHA256検証がOK
- [ ] ZIP内の3ファイルを全読込した
- [ ] トラッカーから v=N を確定した（SSOT遵守）
- [ ] 3ファイルの参照が v=N（入力側）で一致している（不一致は追記で整合）
- [ ] v{N+1} の新トラッカーを作成し、参照を追記で更新した
- [ ] 出力ZIPに「更新後の3ファイルのみ」を同梱した
- [ ] 変更点（追加/削除/修正）を明示した

---

## トラッカー更新ルール（例外 + 安全）

AとBの両方を使う（明確さと安全のため）。

### A) チェックボックス更新（例外として許可）
- タスク完了時に `[ ]` を `[x]` に変更してよい。
- このチェック変更は **「追記のみ」原則の明示的例外**として扱う。

### B) 進捗ログ / 更新（常に必須）
- Aに関係なく、トラッカー末尾の「Progress Log / Updates」へ完了記録を追記する。
- 各レコードは必須: 日時、タスクID（またはタスク行）、証跡（PRリンク/コマンド出力/スクショ参照）。

---

## 表記ルール（日本語統一）

- 原則：ドキュメント（md）は日本語表記で統一する。
- 例外：コマンド、コード、固有名詞、引用等で英語が必要な場合のみ最小限で併記可。
- 既に英語表記になっているドキュメント（特に監査/Audit関連）は、トラッカーに「日本語化・表現整合」の修正タスクとして必ず記録し、後で修正する。

---

## 更新履歴（最新追記）
- 追加: 新チャット開始用の1行指示、最初の1コマンド、SSOT（_handoff_check）基準の現行フロー
- 修正: ZIP廃止/SSOT統一の運用ルールを本文へ統合し、日本語表記で整理
- 廃止: ZIP前提の旧手順を「旧運用（廃止/Deprecated）」として明記

---

# 最新状況の追記（2026-01-17）: 3ファイル共存アダプタ導入

## 目的
- `CLAUDE.md / AGENTS.md / GEMINI.md` を **SSOTではなく「各AIエージェントへ直接渡す運用アダプタ」**として共存させる。
- SSOT（唯一の正）は **cf-context-framework側（Charter→Mode→Artifacts→Skills）** に固定し、重複記述を避けて参照リンク中心で運用する。

## SSOT（唯一の正）
- 優先順位: **Charter → Mode → Artifacts → Skills**
- 規範ドキュメントは原則 **日本語が正**（必要最小限のみ英語併記可）。
- ZIP運用は廃止（以後はリポジトリ直下 `_handoff_check/` の3ファイルを正とする）。

## 役割対応（運用アダプタ3ファイル）
- Claude Code: `CLAUDE.md`（Crafter: 実装）
- OpenAI Codex: `AGENTS.md`（Crafter/Orchestrator: CLI運用含む）
- Google Antigravity / Gemini系: `GEMINI.md`（Orchestrator: 統制/整理）

## main直push禁止（運用ルール）
- 目的: 事故防止・証跡確保（レビュー/監査ログ前提）
- **作業は wip/* ブランチ**で行い、PRで `main` に反映する。
- 注: GitHubのRulesetsではなく、ローカルの `.git/hooks/pre-push` により `main` からのpushがブロックされる構成。

## 統一文言（運用上の固定）
- **AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う**

## 現状（このチャット時点）
- 作業ブランチ: `wip/agent-adapters`
- 追加済み（Addのみで既存変更なし）:
  - `WORKFLOW/TOOLING/COEXIST_3FILES.md`
  - `TOOLING/ADAPTERS/CLAUDE.template.md`
  - `TOOLING/ADAPTERS/AGENTS.template.md`
  - `TOOLING/ADAPTERS/GEMINI.template.md`
  - `CLAUDE.md`
  - `AGENTS.md`
  - `GEMINI.md`
- すでにコミット済み（例: `docs: add COEXIST_3FILES and agent adapter templates`）

## 次にやること（新チャットで続行）
- `wip/agent-adapters` を push → PR作成 → レビュー → merge → ブランチ削除
- `main` を pull して同期
- `cf_task_tracker_v5.md` の該当タスクを [x] にし、末尾の Progress Log / Updates に日時・タスクID・証跡（PR/コミット等）を追記

