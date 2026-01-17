<!-- CFCTX_UPDATE_ZIP_DEPRECATED_V1 -->
## 運用ルール更新（2026-01-17）：ZIP廃止 / SSOTは _handoff_check

- ZIP（例: `cf_handoff_and_tracker.zip`）の作成・検証・展開は行わない。
- 作業対象（SSOT）はリポジトリ直下 `_handoff_check/` の3ファイル：
  - `cf_handoff_prompt.md`（入力/今回の指示）
  - `cf_update_runbook.md`（手順）
  - `cf_task_tracker_vN.md`（トラッカー）
- `_handoff_cache/` は過去の証跡・互換用。原則参照しない（必要時のみ監査/検証用）。
- 文中の `*.zip`（例: `next2_work.zip` 等）は「旧称ラベル」として残る場合があるが、実体ZIPは前提にしない。


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

## Tracker progress update policy (Exception + Safety)

We use both A and B for clarity and safety.

### A) Checkbox update (EXCEPTION is allowed)
- When a task is completed, it is allowed to change `[ ]` to `[x]` on the corresponding task line.
- This checkbox change is treated as an explicit exception to the “no modification / append-only” rule.

### B) Progress Log / Updates (ALWAYS required)
- Regardless of A, ALWAYS append a completion record to the end of the tracker file under a "Progress Log / Updates" section.
- Each record MUST include: date/time, task ID (or exact task line), and evidence (PR link / command output / screenshot reference).


---

## 表記ルール（日本語統一）

- 原則：ドキュメント（md）は日本語表記で統一する。
- 例外：コマンド、コード、固有名詞、引用等で英語が必要な場合のみ最小限で併記可。
- 既に英語表記になっているドキュメント（特に監査/Audit関連）は、トラッカーに「日本語化・表現整合」の修正タスクとして必ず記録し、後で修正する。

