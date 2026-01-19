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

- 新チャット添付は次の3ファイルのみ（整合性対象は前2点）:
  - `_handoff_check/cf_update_runbook.md`
  - `_handoff_check/cf_task_tracker_v5.md`
  - `_handoff_check/cf_handoff_prompt.md`（都度更新・整合性対象外だが運用はこれに準拠）
- 固定SSOTは `cf_update_runbook.md` と `cf_task_tracker_v5.md`
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

## 0. 基本情報（必須）

- 作業日: 2026-01-17（JST）
- 作業者: Masahiro
- 作業リポジトリ: `/home/masahiro/projects/_cfctx/cf-context-framework`
- 追従リポジトリ: `/home/masahiro/projects/cf-context-framework`
- 作業ブランチ: `wip/v0.1.5`（PR#1でmainへマージ後、ローカル/リモートとも削除済）
- 対象ZIP:
  - [x] next1_work.zip（Auditor / Gate D）
  - [x] next2_work.zip（3常駐指示ファイル共存）
  - [ ] next3_work.zip（Skills統合）
- 参照手順書: `cf_update_runbook.md`
- 実行方針（固定）: **Charter → Mode → Artifacts → Skills**
- 監査運用（固定 / 表現統一は後で反映）: **AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**

---

## 1. 運用ルール（この作業の事故防止）

- [ ] 「次にやることは1つだけ（1コマンド/1操作）」を守る
  - 例外（Developerが明示的に「このセッションは複数提示で」と要求した場合のみ）：
    - そのセッションに限り、手順を複数提示してよい（次回は要求がない限り、必ず「次にやること1つ」に戻す）。
    - ただし原則として、複数提示を許容するのは **読み取り系コマンド（確認/表示）** に限る。
    - **書き込み系（編集/削除/コミット等）** が含まれる場合は、事故防止のため「1手」または「最大3手＋中間で結果貼付」を維持する。
- [ ] 変更したら必ず「何を追加・削除・修正したか」を記録する
- [ ] コマンドを実行したら「意味（復習用）」も必ず記録する
- [ ] 迷ったら上位規範（Charter→Mode→Artifacts→Skills）に戻って判断する
- [ ] 重大変更（広範囲修正/設計変更/大量差分）は Crafter/Orchestrator で実装し、人間は指示と検証に徹する

---

## 2. 進捗サマリ（毎ステップ更新）

- 現在のフェーズ: ☑完了（next1: Auditor/Gate D） / ☐次2（3常駐指示ファイル共存） / ☐次3（Skills統合）
- 直近の完了ステップID: `STEP-503`（PR#1 merge）
- 未解決ブロッカー:
  - （なし）
- 次にやる「1手」:
  - next2_work.zip を展開し、3常駐指示ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）の共存方針差分を洗い出す

    - 注: `next2_work.zip` は旧運用ラベルです。**ZIPの作成/展開はしません**。
    - 実作業のSSOTは `/_handoff_check/` の3ファイル（`cf_task_tracker_v5.md` / `cf_update_runbook.md` / `cf_handoff_prompt.md`）です。
    - 差分洗い出しは、ZIPではなくリポジトリ内の `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` を対象に行います。

---

## 3. 実行ログ（証跡として残す）

> ここは「コマンド実行のたびに」追記します。  
> 可能なら、貼り付けた実行結果のスクショ/ログファイルのパスも書いてください。

### LOG-001｜Gate D（Audit）テンプレ/運用ドキュメント追加
- 日時: 2026-01-17
- 実行コマンド:
  - `cd /home/masahiro/projects/_cfctx/cf-context-framework`
  - `mkdir -p WORKFLOW`
  - `cat > WORKFLOW/AUDIT.md <<'EOF' ... EOF`
- コマンドの意味（復習用）:
  - `mkdir -p`：ディレクトリが無ければ作成（あってもOK）
  - `cat > ... <<'EOF'`：ヒアドキュメントで複数行テキストをファイルへ一括書き込み
- 実行結果（貼り付け/要約）:
  - `WORKFLOW/AUDIT.md` を追加
- 出力/証跡（ファイル/URL/PRコメント等）:
  - 追加ファイル: `WORKFLOW/AUDIT.md`
- 次の1手:
  - 追加テンプレ（AUDIT_REPORT / AUDIT_CHECKLIST / EXCEPTIONS / PROMPTS/AUDITOR）を作成

### LOG-002｜追加ファイルをステージング→コミット→push
- 日時: 2026-01-17
- 実行コマンド:
  - `git status -sb`
  - `git add ARTIFACTS/AUDIT_CHECKLIST.md ARTIFACTS/AUDIT_REPORT.md ARTIFACTS/EXCEPTIONS.md PROMPTS/AUDITOR.md WORKFLOW/AUDIT.md`
  - `git commit -m "Add Audit Gate D templates and docs"`
  - `git push -u origin wip/v0.1.5`
- コマンドの意味（復習用）:
  - `git status -sb`：短い形式でブランチ/差分状況を確認
  - `git add`：コミット対象に追加
  - `git commit -m`：変更を履歴化（メッセージ付き）
  - `git push -u origin <branch>`：リモートへ送信し追跡設定
- 実行結果（貼り付け/要約）:
  - commit作成（例: `6a735ec`）、push成功
- 出力/証跡（ファイル/URL/PRコメント等）:
  - PR#1（wip/v0.1.5 → main）
- 次の1手:
  - GitHub上でPR作成→マージ

### LOG-003｜PR作成→マージ→ブランチ削除
- 日時: 2026-01-17
- 実行（UI操作）:
  - GitHubで PR#1 を作成し、`Merge pull request` → `Confirm merge`
  - マージ後、GitHubの `Delete branch` で `wip/v0.1.5` を削除
- 意味（復習用）:
  - PRでレビュー/監査/証跡が揃い、main直コミット禁止ルールを維持したまま統合できる
- 実行結果（貼り付け/要約）:
  - PR#1 は `Merged` 状態
- 出力/証跡:
  - PR画面スクショ / `Files changed: 11`
- 次の1手:
  - ローカルmainへ取り込み、作業ブランチを掃除

### LOG-004｜ローカル main へ取り込み→ローカルブランチ削除
- 日時: 2026-01-17
- 実行コマンド:
  - `git switch main`
  - `git pull`
  - `git branch -D wip/v0.1.4 wip/v0.1.5`
- コマンドの意味（復習用）:
  - `git switch main`：mainへ移動
  - `git pull`：リモートmainの変更を取り込み
  - `git branch -D`：ローカルブランチを強制削除（マージ済前提）
- 実行結果（貼り付け/要約）:
  - mainに反映（Fast-forward）、ローカルは main のみ
- 出力/証跡:
  - `git status` → working tree clean
- 次の1手:
  - リモート追跡ブランチの掃除（fetch/prune）

### LOG-005｜remote.origin.fetch のrefspec修正→fetch --prune
- 日時: 2026-01-17
- 実行コマンド:
  - `git config --get-all remote.origin.fetch`
  - `git config --replace-all remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'`
  - `git fetch --prune`
- コマンドの意味（復習用）:
  - `remote.origin.fetch`：fetch対象ブランチの条件（refspec）。特定ブランチ固定だと、削除済ブランチを追跡し続けることがある
  - `--replace-all`：fetch条件を“全ブランチ追跡”に戻す
  - `fetch --prune`：消えたリモートブランチ追跡（origin/*）を削除
- 実行結果（貼り付け/要約）:
  - `origin/wip/v0.1.4` などの追跡が整理され、`git branch -r` が正常化
- 出力/証跡:
  - ターミナルスクショ（エラー解消後のfetch --prune成功）
- 次の1手:
  - next2_work.zip（3常駐指示ファイル共存）へ着手


---

## 4. Skills 適用ログ（再利用の核）

> Skillを使ったら **必ずここに1件追加**します。  
> 目的は「同じ導入を次回“呼ぶだけ”にする」ための証跡化です。

### SKILL-LOG-001
- Skill:（今回は未適用 / 手動実装）
  - Path: -
  - Version: -
- Mode: standard
- Inputs（今回の入力値）:
  - next1_work.zip（Auditor/Gate D）
- Outputs（生成/変更されたもの）:
  - Files: `WORKFLOW/AUDIT.md`, `PROMPTS/AUDITOR.md`, `ARTIFACTS/AUDIT_REPORT.md`, `ARTIFACTS/AUDIT_CHECKLIST.md`, `ARTIFACTS/EXCEPTIONS.md` ほか
  - ENV/Settings: -
- Checks（検証結果）:
  - PR#1 merged / mainに反映 / working tree clean
- Evidence:
  - PR#1 / ターミナルログ（commit/push/pull/fetch --prune）
- Notes（落とし穴/学び）:
  - `remote.origin.fetch` が特定ブランチ固定だと `fetch --prune` が失敗する場合あり → 全ブランチ追跡へ戻して解消


（以降、SKILL-LOG-002…）

---

## 5. タスク一覧（Gate別）

### Gate 0｜準備・現状固定

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-001 | 作業/追従リポジトリのパス確認 | [x] | `pwd` → `/home/masahiro/projects/_cfctx/cf-context-framework` | - |
| STEP-002 | ブランチ確認（wip/<version>） | [x] | `git branch`（作業時: `wip/v0.1.5` / 現在: `main`） | - |
| STEP-003 | clean確認 | [x] | `git status` → working tree clean | - |
| STEP-004 | リモート確認 | [x] | `git remote -v` | - |
| STEP-005 | 3ZIP展開・内容把握（差分対象の洗い出し） | [x] | 展開先パス＋ファイル一覧 | - |
| STEP-006 | バックアップ（作業前タグ or zip） | [x] | tag名 or バックアップzip | - |

---

### Gate A｜定義・規範の整合（Charter/Mode/Workflow）

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-101 | Gate D（Audit Gate）の位置づけを決定（Modeとの関係も含む） | [x] | `WORKFLOW/AUDIT.md` + PR#1説明 | Mod |
| STEP-102 | 監査の定義を追加（AUDIT.md or 既存へ統合） | [x] | `WORKFLOW/AUDIT.md` / `PROMPTS/AUDITOR.md` | Add/Mod |
| STEP-103 | 3常駐指示ファイル共存方針（COEXIST_3FILES）を格納 | [x] | 追加ファイル / WORKFLOW/TOOLING/COEXIST_3FILES.md | Add |
| STEP-104 | Skills統合の方針（SKILLS_INTEGRATION）を格納 | [x] | 追加ファイル / commit: 6addee1 / WORKFLOW/SKILLS_INTEGRATION.md | Add |
| STEP-106 | Skillsの“呼び出しフレーズ”と“Artifactsへの書き戻し規則”を確定 | [x] | commit: 921dbe5 | Mod候補 |
| STEP-107 | `SKILLS/_registry.md`（Skill一覧）を作るか決める（推奨） | [x] | commit: 5caa45c / SKILLS/_registry.md | Add |
| STEP-108 | SKILLS/skill-001.md（Skillテンプレ）を追加 | [x] | commit: 1f00593 / SKILLS/skill-001.md | Add |
| STEP-105 | 統一文言の導入箇所を確定（※実装は後フェーズでOK） | [x] | 追記場所一覧 | Mod候補 |

---

### Gate B｜Artifacts（成果物テンプレ）更新

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-201 | TASK_LISTS に監査/証跡観点を接続 | [x] | PR#1 Files changed（ARTIFACTS/TASK_LISTS.md） | Mod |
| STEP-202 | IMPLEMENTATION_PLAN に Gate D を接続 | [x] | PR#1 Files changed（ARTIFACTS/IMPLEMENTATION_PLAN.md） | Mod |
| STEP-203 | WALKTHROUGH に Evidence 準備を接続 | [x] | PR#1 Files changed（ARTIFACTS/WALKTHROUGH.md） | Mod |
| STEP-207 | TASK_LISTS に「Apply Skill: ...」の記載ルールを追記 | [x] | diff / 該当セクション | Mod |
| STEP-208 | WALKTHROUGH に「Skill適用の検証ログの残し方」を追記 | [x] | diff / 該当セクション | Mod |
| STEP-204 | AUDIT_REPORT テンプレ追加 | [x] | `ARTIFACTS/AUDIT_REPORT.md` | Add |
| STEP-205 | AUDIT_CHECKLIST テンプレ追加 | [x] | `ARTIFACTS/AUDIT_CHECKLIST.md` | Add |
| STEP-206 | EXCEPTIONS（例外記録）追加（任意だが推奨） | [x] | `ARTIFACTS/EXCEPTIONS.md` | Add |

---

### Gate C｜Agent Adapter（3ファイル）配置・整合

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-301 | Claude Code 用 `CLAUDE.md` を “渡せる形”に整備 | [x] | ファイル内容 | Add/Mod |
| STEP-302 | Codex 用 `AGENTS.md` を “渡せる形”に整備 | [x] | ファイル内容 | Add/Mod |
| STEP-303 | Antigravity 用 `GEMINI.md` を “渡せる形”に整備 | [x] | ファイル内容 | Add/Mod |
| STEP-304 | 3ファイル内の Source-of-Truth 宣言が同一か確認 | [x] | チェック結果 | - |
| STEP-306 | 3ファイルに「Skill優先実行（無ければ作成提案）」があるか確認 | [x] | チェック結果 | - |
| STEP-305 | 参照リンク（Charter/Mode/Artifacts/Skills）整合確認 | [x] | リンク確認ログ | - |

---

### Gate D｜監査（Auditor）実施（指摘のみ）

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-401 | 監査入力（Evidence）を揃える（差分/ログ/テンプレ等） | [x] | ARTIFACTS/AUDIT_REPORT.md / ARTIFACTS/AUDIT_CHECKLIST.md / target bbca353 / commit 6a8ff96 | - |
| STEP-402 | AUDIT_CHECKLIST を記入（PASS/FAIL） | [x] | ARTIFACTS/AUDIT_CHECKLIST.md / target bbca353 / commit 6a8ff96 | - |
| STEP-403 | AUDIT_REPORT を作成（指摘/根拠/要求） | [x] | ARTIFACTS/AUDIT_REPORT.md / target bbca353 / commit 6a8ff96 | - |
| STEP-407 | Skill適用ログ（SKILL-LOG）がEvidenceに揃っているか確認 | [x] | _handoff_check/cf_task_tracker_v5.md: SKILL-LOG-001/002（L170, L188） | Mod |
| STEP-404 | FAIL項目を Crafter/Orchestrator に差し戻し | [x] | N/A（PASSのため差し戻し不要）/ target bbca353 / commit 6a8ff96 | - |
| STEP-405 | 修正後に再監査（必要なら複数回） | [x] | N/A（PASSのため再監査不要）/ target bbca353 / commit 6a8ff96 | - |
| STEP-406 | 最終PASS（Gate D完了） | [x] | ARTIFACTS/AUDIT_REPORT.md / ARTIFACTS/AUDIT_CHECKLIST.md / target bbca353 / commit 6a8ff96 | - |

---

### Gate E | 言語ポリシー（日本語統一）

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---|---|---|
| STEP-450 | 日本語表記ポリシー（用語・表記ゆれ）を確定 | [x] | `CFTX_LANG_POLICY_CANONICAL_V1` | Add |
| STEP-451 | 英語混在ドキュメントを洗い出し（grep等） | [x] | `grep -RIn --include='*.md' -E '[A-Za-z]{3,}' ...` | Add |
| STEP-452 | 対象ドキュメントを日本語へ修正（監査系を優先） | [x] | `git diff` | Mod |
| STEP-453 | 再検出して英語混在が許容範囲内か確認 | [x] | `grep` 結果 | Add |
| STEP-454 | Progress Log/Updates に完了記録（日時・タスクID・証跡） | [x] | `b1c32a2` | Add |

---

### 完了｜コミット・同期・最終確認

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-501 | 変更点一覧（Add/Del/Mod）をまとめる | [x] | セクション「6.変更点サマリ」 | - |
| STEP-502 | コミット（メッセージ規約に従う） | [x] | commit: `6a735ec`（Add Audit Gate D templates and docs）/ merge: `6e4c782` | - |
| STEP-503 | push（作業リポジトリ） | [x] | `git push -u origin wip/v0.1.5`（PR#1作成） | - |
| STEP-504 | pull（追従リポジトリ） | [x] | `git switch main && git pull` | - |
| STEP-505 | 最終整合チェック（GATES/Artifacts/3files/Skills） | [x] | PASSレポート / commit 5f2a393 | - |
| STEP-506 | リリース用メモ作成（任意） | [x] | release notes | - |

---

## 6. 変更点サマリ（最後に確定させる）

### Add（追加）
- `WORKFLOW/AUDIT.md`
- `PROMPTS/AUDITOR.md`
- `ARTIFACTS/AUDIT_REPORT.md`
- `ARTIFACTS/AUDIT_CHECKLIST.md`
- `ARTIFACTS/EXCEPTIONS.md`

### Del（削除）
- （リポジトリ内の大きな削除は無し。既存ファイル内の微小削除はPR差分参照）

### Mod（修正）
- `WORKFLOW/GATES.md`（Gate D 前提のリンク/整合）
- `WORKFLOW/BRANCHING.md`（Mode/Triggers参照、Strictへのエスカレーション例の追記など）
- `WORKFLOW/MODES_AND_TRIGGERS.md`（参照/リンク整備）
- `ARTIFACTS/TASK_LISTS.md` / `ARTIFACTS/IMPLEMENTATION_PLAN.md` / `ARTIFACTS/WALKTHROUGH.md`（Gate D/Evidenceの接続）


---

## 7. 最終監査サマリ（Gate D PASS時に記入）

- 最終判定: ☐PASS / ☐FAIL
- 主要リスク（残るものがあれば）:
  - -
- 主要な修正要求（解決済みなら“解決済み”）:
  - -
- Evidence一覧（リンク/パス）:
  - -

### LOG-006 | タスクトラッカー参照の vN 化（固定参照排除 + 最新版リンク導入）
- 日時: 2026-01-17
- 目的: 手順書やタスクリストが `cf_task_tracker_v?` の数字に依存しないようにする
- 実施:
  - `cf_update_runbook.md` の参照を `cf_task_tracker_vN.md（最新版）` に統一
  - `cf_task_tracker_v4.md` を作成（v3からコピーし、タイトルを v4 に修正）
  - `cf_task_tracker_vN.md -> cf_task_tracker_v4.md` のシンボリックリンクを作成（最新版追従）
- 出力/証跡:
  - `grep -RIn --exclude-dir=.git "cf_task_tracker_v[0-9]" .` がヒットしないことを確認
  - `ls -l cf_task_tracker_vN.md` でリンク先が v4 であることを確認
- 次の1手:
  - 以後の記録は `cf_task_tracker_vN.md`（最新版）に追記し、必要になったら N+1 を作成



---

## 追記（2026-01-17）｜本チャットの追加進捗（文言統一の“実装反映”＋言語ポリシー検討）

### 追記サマリ
- **位置づけ**: `STEP-105`（統一文言の導入箇所）について、従来は「導入箇所の確定（実装は後）」だったが、**整合性維持のため“実装反映まで実施”**。
- **追加の論点**: ドキュメントが日本語/英語で混在しているため、今後の整合性コストを下げる目的で **言語ポリシー（層×言語）を確定してから次へ進める**方針。

### 実施内容（追記のみ／既存本文は不改変）
- `WORKFLOW/BRANCHING.md` / `WORKFLOW/MODES_AND_TRIGGERS.md` を確認し、運用規範（wip/<version>、Gate運用、Mode/Triggers）が文書化されていることを確認。
- `定義:` 行はすでにMarkdownリンク化されていることを確認。
- 監査運用の統一文言（本票の「監査運用（固定）」と同一）を、以下のファイルへ **1行統一**で反映：
  - `WORKFLOW/AUDIT.md`
  - `ARTIFACTS/AUDIT_REPORT.md`
  - `ARTIFACTS/AUDIT_CHECKLIST.md`
  - `PROMPTS/AUDITOR.md`

### 変更点（Add/Del/Mod）
- **Mod**: 上記4ファイルの冒頭説明（Note/Rule/冒頭2行）を、以下の1行へ統一
  - `AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。`

### 証跡（Evidence）
- 検索で統一文言の反映箇所を確認（grep結果）
- `git diff` で差分を確認
- `git add WORKFLOW/AUDIT.md ARTIFACTS/AUDIT_REPORT.md ARTIFACTS/AUDIT_CHECKLIST.md PROMPTS/AUDITOR.md` を実行（※コミット/プッシュは未実施。次回は `git status -sb` で要確認）

### 次にやる「1手」（更新）
- **言語ポリシー（層×言語）を確定してから次工程へ進む**（日本語統一を基本案）


---

## 追記（2026-01-17）このチャットでの引継ぎ（v4 → v5準備）

### 決定
- 入力トラッカー：v4（N=4）を採用
- 出力トラッカー：v5（N+1）を作成して以後の参照SSOTにする

### 実行ログ（Evidence）
- SHA256検証：`cf_handoff_and_tracker.zip: OK`
- ZIP展開確認：入力ZIPに以下3ファイルが存在
  - `cf_handoff_prompt.md`
  - `cf_update_runbook.md`
  - `cf_task_tracker_vN.md`
- 出力準備：v5雛形を作成
  - `cf_handoff_prompt.md`（コピー）
  - `cf_update_runbook.md`（コピー）
  - `cf_task_tracker_v5.md`（vNをコピーしてv5名に変更）
- 参照整合（追記のみで実施）
  - `cf_update_runbook.md` 末尾に「最新参照（v5）」を追記
  - `cf_handoff_prompt.md` 末尾に「最新参照（v5）」を追記
  - 注：本文中の `cf_task_tracker_vN.md` / `cf_task_tracker_v4.md` 等は履歴として残し、最新は `cf_task_tracker_v5.md` を参照する

### 入力規則（本チャットで受領）
- `cf_handoff_input.md` / `cf_handoff_output.md` の最新版を受領し、以後の更新ルールSSOTとして適用

## 更新ログ（Progress Log / Updates）

- 2026-01-17 | UPD-20260117-01 | ZIP運用廃止（SSOT=_handoff_check）へ統一 / 表記ポリシー（日本語統一）を3ファイル先頭に追記 / _handoff_cache をSSOTへ同期
  - 対象: 旧引継ぎ文書（当時の運用）, _handoff_check/cf_handoff_prompt.md, _handoff_check/cf_update_runbook.md, _handoff_check/cf_task_tracker_v5.md
  - 変更種別: 追記のみ（チェックボックス変更なし）
  - 証跡:
    - sha256検証: `cf_handoff_and_tracker.zip: OK`
    - 差分確認: `diff -ruq _handoff_check _handoff_cache/unpacked` -> 差分なし / `diff -ruq _handoff_check _handoff_cache/_handoff_check` -> 差分なし
    - 表記ルール確認: `grep -nE '日本語|表記|英語表記|日本語に統一|日本語表記' _handoff_check/*.md`（該当行ヒット）
    - 追記マーカー:
      - `CFCTX_UPDATE_ZIP_DEPRECATED_V1`
      - `CFCTX_LANG_POLICY_CANONICAL_V1`


- 2026-01-17 | UPD-20260117-02 | 3ファイル共存アダプタ導入をPR#8でmainへ反映し、Gate C（STEP-301〜305）を完了記録
  - 対象: WORKFLOW/TOOLING/COEXIST_3FILES.md / TOOLING/ADAPTERS/*.template.md / CLAUDE.md / AGENTS.md / GEMINI.md / 旧引継ぎ文書（当時の運用） / _handoff_check/cf_task_tracker_v5.md
  - タスクID: STEP-301, STEP-302, STEP-303, STEP-304, STEP-305（Done=[x]）
  - 証跡: PR#8（https://github.com/xxxMasahiro/cf-context-framework/pull/8） / merge: 27459ca / commits: 2154ebe, d77aec7

- 2026-01-17 | UPD-20260117-03 | 3指針ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）差分確認：共存整合を確認 | 証跡: diff -u CLAUDE.md AGENTS.md / diff -u AGENTS.md GEMINI.md（差分は目的・役割・参考テンプレのみ、運用ルール/統一必須文言は一致）

- 2026-01-18 | UPD-20260118-01 | Gate 0: STEP-004 リモート確認を完了（チェック反映 + 証跡追記）
  - 対象: _handoff_check/cf_task_tracker_v5.md
  - タスクID: STEP-004
  - 証跡: `git remote -v`
    ```
    origin  github-masahiro:xxxMasahiro/cf-context-framework (fetch)
    origin  github-masahiro:xxxMasahiro/cf-context-framework (push)
    ```
  - 変更点: STEP-004 の Done を [ ]→[x] / 更新ログに本エントリを追記

- 2026-01-18 | UPD-20260118-02 | Gate 0: STEP-005 展開先とファイル一覧を記録（チェック反映 + 証跡追記）
  - 対象: _handoff_check/cf_task_tracker_v5.md
  - タスクID: STEP-005
  - 証跡: UNPACK_DIR + `ls -la _handoff_check`
    ```
    UNPACK_DIR=/home/masahiro/projects/_cfctx/cf-context-framework/_handoff_check
    total 56
    drwxr-xr-x  2 masahiro masahiro  4096 Jan 17 22:10 .
    drwxr-xr-x 10 masahiro masahiro  4096 Jan 18 05:52 ..
    -rwxr-xr-x  1 masahiro masahiro  6049 Jan 17 17:08 cf_handoff_prompt.md
    -rwxr-xr-x  1 masahiro masahiro 22288 Jan 18 05:31 cf_task_tracker_v5.md
    -rwxr-xr-x  1 masahiro masahiro 13767 Jan 17 17:08 cf_update_runbook.md
    ```
  - 変更点: STEP-005 の Done を [ ]→[x] / 更新ログに本エントリを追記
- 2026-01-18 | UPD-20260118-03 | Gate 0: STEP-006 バックアップ作成・整合性確認（rsync / 件数・容量一致 / 旧引継ぎ文書（当時の運用） sha256一致）
  - 対象: ../cf-context-framework_backup_20260118
  - タスクID: STEP-006
  - 証跡:
    - rsync: rsync -a --delete ./ ../cf-context-framework_backup_20260118
    - 件数/容量: src 115 files / 58M, backup 115 files / 58M
    - 旧引継ぎ文書（当時の運用）: sha256一致 (2cbd549f400ab050fec458488e5121bcd7e4754ffe5bd71fc936cf2ece115a67)
    - repo HEAD: b1c32a2
--- 変更点: STEP-103 の Done を [ ]→[x] / Evidence 追記 / 更新ログに本エントリを追記
- 2026-01-18 | UPD-20260118-04 | Gate A: STEP-103 3ファイル共存方針（COEXIST_3FILES）確認・反映
  - 対象: WORKFLOW/TOOLING/COEXIST_3FILES.md
  - タスクID: STEP-103
  - 証跡: _handoff_check/cf_task_tracker_v5.md（STEP-103 [x], Evidence: WORKFLOW/TOOLING/COEXIST_3FILES.md）
- 2026-01-18 | UPD-20260118-05 | Gate A: STEP-104 Skills統合方針（SKILLS_INTEGRATION）を格納完了 | 証跡: 6addee1 / WORKFLOW/SKILLS_INTEGRATION.md
- 2026-01-18 | UPD-20260118-07 | Gate A: STEP-106 完了。呼び出しフレーズ（SKILL: ...）とArtifacts書き戻し規則を WORKFLOW/SKILLS_INTEGRATION.md に追記。Evidence: 921dbe5

## Progress Log/Updates

- 2026-01-20 | UPD-20260120-01 | 引継ぎ簡略運用へ切替（旧引継ぎ文書不使用） | Done[x]
  - 対象: _handoff_check/cf_update_runbook.md / _handoff_check/cf_task_tracker_v5.md
  - 変更点: 新チャット添付は3ファイルのみ / SSOTはrunbook+tracker / 引継ぎテンプレ統一
  - Evidence: commit 0f70baa
- 2026-01-18 | UPD-20260118-14 | 完了: STEP-306 3ファイルの Skill優先実行/作成提案 記載を確認（結果: 全てNOT FOUND） | Evidence: grep -nE 'Skill優先実行|作成提案' (CLAUDE.md/AGENTS.md/GEMINI.md) => NOT FOUND | Notes: 記載追加は未実施

- 2026-01-18 | UPD-20260118-13 | 完了: STEP-208 WALKTHROUGH に Skill適用の検証ログの残し方を追記 | Evidence: git diff -- ARTIFACTS/WALKTHROUGH.md | Notes: 追記のみ

- 2026-01-18 | UPD-20260118-12 | 完了: STEP-207 TASK_LISTS に Apply Skill 記載ルールを追記 | Evidence: git diff -- ARTIFACTS/TASK_LISTS.md | Notes: 追記のみ

- UPD-20260118-06: STEP-105 完了。統一文言のSSOT導入箇所を WORKFLOW/AUDIT.md:6（# Purpose直下）に確定。Evidence: WORKFLOW/AUDIT.md:6
- 2026-01-18 | UPD-20260118-08 | Gate A: STEP-107 SKILLS/_registry.md（Skill一覧）を追加 | 証跡: 5caa45c / SKILLS/_registry.md
- 2026-01-18 | UPD-20260118-09 | Gate A: STEP-108 SKILLS/skill-001.md（Skillテンプレ）を追加 | 証跡: 1f00593 / SKILLS/skill-001.md
- 2026-01-18 | UPD-20260118-10 | 運用メモ: 変更点列は Add/Del/Mod を使用。No（No-op）は原則使わず、「作らない判断」は Notes（または本Log）へ記録する。
- 2026-01-18 | UPD-20260118-11 | 修正: STEP-107 の変更点表記を Add/No→Add に統一（No-op は Notes/Log で表現）

- 2026-01-19 | UPD-20260119-01 | 翻訳レイヤ（Translation Layer）を追加し、Artifacts から参照できる導線を追記
  - 対象: WORKFLOW/TRANSLATION_LAYER.md / ARTIFACTS/TASK_LISTS.md / ARTIFACTS/WALKTHROUGH.md
  - PR: PR#20（Merged）
  - 証跡: commit 03a2c82（main） / commit c8f8523（wip）
  - 備考: 追記のみ（既存内容の置換なし）
- 2026-01-19 | UPD-20260119-02 | Gate E: STEP-450〜453 を Done[x] に更新（日本語ポリシー） | Evidence: commit 1990219 / push origin main
- 2026-01-19 | UPD-20260119-03 | Gate D: 監査ドキュメント日本語化 | Done[x] | テンプレ構造維持のまま日本語化 | Evidence: commit bbca353 / push origin main
- 2026-01-19 | UPD-20260119-04 | Gate D: bbca353 監査（監査成果物作成） | Done[x] | Evidence: commit 6a8ff96 / target bbca353
- 2026-01-19 | UPD-20260119-05 | Gate D: STEP-407 SKILL-LOG 証跡確認 | Done[x] | Evidence: _handoff_check/cf_task_tracker_v5.md（SKILL-LOG-001/002: L170,L188）
- 2026-01-19 | UPD-20260119-06 | STEP-505 最終整合チェック PASS | Done[x] | Evidence: commit 5f2a393

- 2026-01-20 02:57 +0900 | STEP-506 | CHANGELOG.md の ## Unreleased にリリースメモを追記して完了（Unreleasedの1行置換）。Evidence: git diff -- CHANGELOG.md / tracker STEP-506 が [x]
