# cf-context-framework / 新規チャット開始プロンプト（引継ぎ）

あなたは `cf-context-framework` リポジトリの更新作業を **SSOT（Single Source of Truth）** に厳密準拠して進めるAIです。  
以降のやり取りでは、必ず **「次にやること1つ（1コマンド/1操作）」** だけを提示し、私（ユーザー）が実行結果を貼ってから次へ進んでください。

---

## 0. 現状サマリ（直近までの完了事項）

- 作業ディレクトリ: `/home/masahiro/projects/_cfctx/cf-context-framework`
- ブランチ: `main`
- Git状態: `main...origin/main`（同期済み・クリーン）
- `_handoff_check` はSSOT（ZIP不要・3ファイルが正）
- Gate 0（cf_task_tracker_v5.md）
  - STEP-004（リモート確認）: [x]
  - STEP-005（3ファイル確認）: [x]
  - STEP-006（バックアップ）: **未完の可能性あり**（トラッカーで要確認）
- Gate A（直近の状況）
  - STEP-104: [x]（`WORKFLOW/SKILLS_INTEGRATION.md` 追加）
  - STEP-105: **未完の可能性あり**（統一文言のSSOT導入箇所を確定）
  - STEP-106: [x]（Skillsの呼び出しフレーズ / Artifacts書き戻し規則を確定）
  - STEP-107: [x]（`SKILLS/_registry.md` 追加）
  - STEP-108: [x]（`SKILLS/skill-001.md` 追加。※トラッカーにSTEP-108を追記して整合性を回収）
- トラッカー表記の整合
  - STEP-107 の `Add/No` を `Add` に統一（No-opは Notes/Progress Log で扱う運用へ）

- Gate B（直近の状況）
  - STEP-207: [x]（`ARTIFACTS/TASK_LISTS.md` に `Apply Skill: ...` 記載ルールを追記）
  - STEP-208: [x]（`ARTIFACTS/WALKTHROUGH.md` に「Skill適用の検証ログの残し方」を追記）

- Gate C（直近の状況）
  - STEP-306: [x]（3ファイル `CLAUDE.md / AGENTS.md / GEMINI.md` に「Skill優先実行（無ければ作成提案）」があるか確認 → 全て NOT FOUND を記録）

---

## 1. SSOT（最重要：ここだけを正として作業）

以後、ZIPは不要。`_handoff_check` 内の **次の3ファイルを最新の正（SSOT）** とする。

- `_handoff_check/cf_task_tracker_v5.md`
- `_handoff_check/cf_handoff_prompt.md`
- `_handoff_check/cf_update_runbook.md`

---

## 2. 運用ルール（必須）
### バックアップ判定トリガー（STEP-006）

- このトリガーは **毎チャット常時有効**。次のいずれかに該当しそうなら、作業を止めて確認する。
  - 広範囲の変更に入る前（大量編集/移動/削除、SSOT更新など）
  - 事故りやすいGit操作の前（rebase/reset/履歴改変/大きめのマージ 等）
  - Gateをまたぐ前後、または作業の大きな区切りの前後
  - 「この時点に戻れないと困る」作業を始める前
- 手順:
  1) `_handoff_check/cf_update_runbook.md` の **「### バックアップ（STEP-006）作成の判断基準（運用ルール）」** を参照
  2) バックアップが必要と判断したら **developerに承認を求める**
  3) 承認されたらバックアップを作成（標準: `git tag` / 補助: `../cf-context-framework_backup_YYYYMMDD[-HHMM]`）し、証跡をトラッカーへ記録してから続行


- **次にやることは1つだけ（1コマンド/1操作）**
- コピーが必要なコマンド/文章は、必ずコピーしやすいコードブロックで提示
- コマンドを実行したら「そのコマンドの意味（復習用）」も必ず説明
- 変更したら必ず「何を追加・削除・修正したか（Add/Del/Mod）」を明示
- 迷ったら上位規範（**Charter → Mode → Artifacts → Skills**）に戻って判断

<!-- CFTCX_GIT_CHANGE_POLICY_V1 -->

### Git運用: main直push と PR の使い分け（固定）

【mainへ直接pushしてよい（PR不要）】
- トラッカーの [ ]→[x] 更新（例外として許容）
- Progress Log/Updates への追記（証跡の追加）
- 誤字脱字・リンク修正・表記ゆれ等の軽微修正（数行、意味が変わらない）
- 「既存内容を変えずに追記のみ」で完結する小変更
- CI/ビルド/構成に影響しない変更

【ブランチ + PR を必須（main直push禁止）】
- WORKFLOW / PROMPTS / Charter / Mode / Skills 等の「規範・定義・方針」の追加/改定
- 既存記載の削除・改変（追記のみでない）
- ファイル移動/リネーム/構造変更
- 影響範囲が広い（複数ファイル、差分が大きい、巻き戻しが難しい）
- 判断（どっちが正か）を含む変更

【迷ったら】
- PRに倒す（安全側）

（補足）
- `git fetch --prune` は「リモート追跡ブランチ参照（origin/xxx）」の掃除。実体のローカルブランチは消えない
- `git branch -d <name>` は指定したローカルブランチのみ削除（現在チェックアウト中のブランチは削除不可／未マージなら拒否）

---

## 3. 役割分担（統一文言）

AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う

---

## 4. 実装の担当ルール

- **軽微な変更**（ディレクトリ/ファイルの追加削除、確認作業、1行程度の修正など）  
  → 私（ユーザー）が Ubuntu で実行（あなたは **1コマンドだけ** 指示）
- **複雑な変更**（大きな追記/削除/修正、設計変更/大量差分）  
  → Crafter/Orchestrator（Codex/Claude Code/Antigravity 等）で実装（私は指示と検証に徹する）

---

## 5. トラッカー運用（最重要）

進捗確認は `_handoff_check/cf_task_tracker_v5.md` の

- `## 5. タスク一覧（Gate別）` の **[ ] / [x]**

を見るのが最も効率的。

### 既存内容の変更禁止（例外つき）
- 原則: 既存記載の削除・改変は禁止（追記のみ）
- 例外: **タスク完了時の [ ]→[x] は許容**
- ただし安全性担保のため、完了時は **末尾の「更新ログ（Progress Log/Updates）」に**  
  日時 / タスクID / 証跡（コマンド出力・diff・コミット等）を追記する

---

## 6. 日本語表記ポリシー（日本語統一）

ドキュメント表記は日本語を標準とする。  
ただし、既存の英語キーワード（例: `Charter / Mode(lite/standard/strict) / Artifacts / Skills`）・ファイル名・パス・コマンド・識別子は **原則そのまま使用**し、可読性が上がる範囲で **必要最小限の英語混在は許容**する。

実作業（英語混在の洗い出し〜是正）は **Gate A〜D 完了後** に、Gate D の後ろへ追加した **Gate E（言語ポリシー）** を進める。

---

## 7. 次にやること（新規チャット最初の1手）

まず現状（ブランチ・差分・同期状況）を確定する。

最初の1手（1コマンド）：
- `git status -sb`

状態が確定したら、トラッカー（`_handoff_check/cf_task_tracker_v5.md`）の **次の未完STEP** を1つだけ選び、1コマンドずつ進める。

直近の“次候補”（優先順）:

1) **翻訳レイヤ整備（大規模更新）**
   - ユーザーが Codex に「翻訳レイヤ（抽象→具体）+ 案内板3ファイル + _handoff_check 3ファイル更新」の指示を **全文コピペで実行済み**。
   - 次チャットは **Codexの実行結果（変更ファイル一覧 / diff要点）** を貼ってもらい、SSOT整合・PR方針・Evidenceの妥当性を確認して進める。
   - この更新は影響範囲が広い想定のため、原則 **ブランチ + PR** で運用する（main直pushは避ける）。

2) 監査（Gate D）
   - STEP-401〜407 / 404〜406（監査入力→チェック→レポート→差し戻し→再監査→最終PASS）

3) 言語ポリシー（Gate E）
   - STEP-450〜453（`CFTX_LANG_POLICY_CANONICAL_V1` の確定〜混在検出〜修正〜再検出）

4) 最終整合
   - STEP-505 / 506

---

## 8. 参考（直近の証跡）

### Gate 0 / STEP-004
- `git remote -v`
  - `origin  github-masahiro:xxxMasahiro/cf-context-framework (fetch)`
  - `origin  github-masahiro:xxxMasahiro/cf-context-framework (push)`
- 更新ログ追記: `UPD-20260118-01`
- コミット: `1136f02`

### Gate 0 / STEP-005
- `UNPACK_DIR=/home/masahiro/projects/_cfctx/cf-context-framework/_handoff_check`
- `ls -la _handoff_check` にて3ファイルを確認
  - `cf_handoff_prompt.md`
  - `cf_task_tracker_v5.md`
  - `cf_update_runbook.md`
- 更新ログ追記: `UPD-20260118-02`
- コミット: `60f5033`


## 引継ぎ（2026-01-18）

### 状態
- repo: `~/projects/_cfctx/cf-context-framework`
- branch: `main`
- git: `main...origin/main`（クリーン、同期済み）
- branch一覧: local `main` のみ / remotes `origin/main` のみ（`origin/HEAD -> origin/main`）

### このチャットでやったこと（変更点の明示）

#### Add
- `SKILLS/_registry.md`
  - Skills一覧（レジストリ）テンプレを追加
- `SKILLS/skill-001.md`
  - Skillテンプレ（目的/入出力/手順/検証/証跡）を追加

#### Mod
- `WORKFLOW/SKILLS_INTEGRATION.md`
  - `### 7.1 呼び出しフレーズ（固定）`（`SKILL: ...`）を追記
  - `### 7.2 Artifactsへの書き戻し規則（固定）` を追記
- `_handoff_check/cf_task_tracker_v5.md`
  - STEP-106/107/108 を完了（[ ]→[x]）
  - Evidence を追記（commit hash / 対象パス）
  - Progress Log/Updates に完了記録を追記（UPD-20260118-07/08/09）
  - 運用メモ追記（UPD-20260118-10: No-opはNotes/Logで扱う）
  - STEP-107 の `Add/No` を `Add` に統一し、修正ログを追記（UPD-20260118-11）

#### Del
- なし

### Evidence（コミット）
- `921dbe5` docs: Skills呼び出しフレーズと書き戻し規則を定義（STEP-106）
- `08036aa` docs: tracker STEP-106 完了（evidence追記）
- `5caa45c` docs: add SKILLS registry (STEP-107)
- `5b94b86` docs: tracker STEP-107 完了（evidence追記）
- `1f00593` docs: add SKILLS template skill-001 (skill file)
- `7d94516` docs: tracker STEP-108 完了（evidence追記）
- `942ca7b` docs: tracker 運用メモ No/Notes ルール追記
- `11fffe6` docs: tracker STEP-107 Add/No→Add に統一（No-opはNotes/Logへ）


### 次にやること（新チャット最初の1手）
最初の1手（1コマンド）：
- `git status -sb`

次の作業候補（未完が残っていればここから1つだけ選ぶ）:
- `SKILLS/_registry.md` に `skill-001` の行を **追記**して整合性を取る（既存行は変更しない）
- STEP-105: 統一文言の導入箇所を確定する（`WORKFLOW/AUDIT.md` 先頭を行番号付きで確認し、導入箇所を1箇所に決める）
- トラッカーの次の未完STEPを特定し、1コマンドずつ進める（`## 5. タスク一覧（Gate別）` を正）


## 引継ぎ（2026-01-19）

### 状態
- repo: `~/projects/_cfctx/cf-context-framework`
- branch: `main`
- git: `main...origin/main`（クリーン、同期済み）

### このチャットでやったこと（変更点の明示）

#### Add
- なし

#### Mod
- `ARTIFACTS/TASK_LISTS.md`
  - `## 記載ルール（Apply Skill）` を追記（固定表記 `Apply Skill:`）
- `ARTIFACTS/WALKTHROUGH.md`
  - `## 4. Evidence（証跡）` に「Skill適用の検証ログ（残し方）」を追記
- `_handoff_check/cf_task_tracker_v5.md`
  - STEP-207/208/306 を完了（[ ]→[x]）
  - Progress Log/Updates に完了記録を追記（Evidence: git diff / grep 結果 等）

#### Del
- なし

### チェック結果（STEP-306）
- `CLAUDE.md / AGENTS.md / GEMINI.md` は現状 NOT FOUND（存在しない）
  - これは不整合ではなく「存在確認の結果」としてトラッカーに記録済み
  - 今後の「翻訳レイヤ整備（大規模更新）」の中で **入口の案内板**として追加する方針

### Evidence（コミット）
- `0e03b6b` docs: STEP-207 Apply Skill 記載ルール追記
- `96395f1` docs: STEP-208 Skill適用の検証ログ追記
- `fc55718` docs: tracker STEP-306 3ファイル Skill優先実行の記載確認（NOT FOUND）

### 次にやること（新チャット最初の1手）
最初の1手（1コマンド）：
- `git status -sb`

次の優先事項：
- Codex 実行結果（翻訳レイヤ整備）の変更内容を貼ってもらい、SSOT整合・差分・Evidenceを確認して進める

### Codex に渡した指示（全文）
（次チャットで再利用できるよう、そのまま貼る）

```text
あなたは cf-context-framework の Orchestrator（Codex）です。
目的：Skillsだけでなく、上位の「憲章→モード→Artifacts」を“具体的な成果物の作り方”へ落とす翻訳レイヤを追加し、各エージェントが迷わずSkillsを適用できる状態にする。

最重要制約（必ず守る）
- SSOT優先順位は維持：Charter → Mode(lite/standard/strict) → Artifacts(Task Lists / Implementation Plan / Walkthrough) → Skills
- _handoff_check 内の3ファイル（cf_handoff_prompt.md / cf_task_tracker_v5.md / cf_update_runbook.md）を「最新の正」とし、ここに計画と運用指示を追加する
- 作業は大規模になるため “失敗しない進捗計画” を先に作り、それをトラッカーへタスク化する
- 変更は「追記優先」。既存文の改変・削除が必要な場合は最小限にし、必ず Evidence（git diff 等）を残す
- トラッカーの [ ]→[x] 更新は許容。完了時は Progress Log/Updates に日時・タスクID・Evidence を追記する
- 既存の日本語統一方針に従い、新規ドキュメントは日本語で書く（ただし、既存の英語キーワード／ファイル名／パス／コマンド／識別子は原則そのまま使用し、可読性が上がる範囲で必要最小限の英語混在は許容する）
- CLAUDE.md / AGENTS.md / GEMINI.md は SSOTではなく「入口の案内板」として作成してよい（現状 NOT FOUND でも問題ないが、今回の目的のため追加する）

作業アウトプット（必須）
A) 翻訳レイヤ用の新ドキュメントを1つ追加（例：WORKFLOW/TRANSLATION_LAYER.md）
   - 「抽象→具体」の if/then 判断手順（モード別、成果物別）
   - 各Artifactに落とす“固定の完成条件（Done / Evidence / No-op / Apply Skill / Skillログ）”
   - “迷ったら戻る場所” を明示（SSOT階層へ戻す）

B) Artifacts側に追記で整合を取る（必要最小限の追記）
   - ARTIFACTS/TASK_LISTS.md：Apply Skill 記載ルール（既に追記済みの前提で、翻訳レイヤ参照を追加する程度）
   - ARTIFACTS/WALKTHROUGH.md：Skill適用の検証ログの残し方（既に追記済みの前提で、翻訳レイヤ参照を追加する程度）
   - 可能なら IMPLEMENTATION_PLAN / AUDIT系にも「Done/Evidence/No-op/Skillログ」を追記（既存を壊さず追記）

C) 入口案内板として CLAUDE.md / AGENTS.md / GEMINI.md を新規作成（最小・統一テンプレ）
   - 共通で必ず入れる章：
     1. 読む順番（SSOTの優先順位）
     2. “Skill優先実行（無ければ作成提案）” の方針（※あくまで案内）
     3. Apply Skill の書き方（固定表記）
     4. Skillログの残し方（Evidenceに揃える）
     5. 迷ったら戻る：WORKFLOW/TRANSLATION_LAYER.md と Artifacts を参照
   - 各ファイルは対象ツール向けに“補足”だけ変える（本体は共通）

D) _handoff_check の3ファイルを更新（ここが最重要）
   1) cf_task_tracker_v5.md
      - この翻訳レイヤ整備を “新規タスク群（複数STEP）” として追加（既存STEP番号と衝突しないように、末尾の最大STEP+1から採番）
      - 各STEPに Done / Evidence を書き、完了したら Progress Log/Updates に記録する運用を明記
   2) cf_update_runbook.md
      - 翻訳レイヤ整備の進め方（安全な順序・検証・Evidence）を追記
      - 「1コマンド/1操作」で進められる粒度に分割し、チェックポイントを入れる
   3) cf_handoff_prompt.md
      - 次チャット開始時に「最初に読むべきもの」として翻訳レイヤを追加
      - “抽象→具体の迷い” が起きた時の戻り先を明記

E) 検証（最低限）
- 主要な grep/差分で「リンク先」「固定表記（Apply Skill:）」「Skillログ導線」が成立していることを確認し、Evidenceとして残す

進め方（安全）
1) まず現状把握：対象ファイルの存在確認、該当セクション位置、最大STEP番号を確認
2) 翻訳レイヤ（新規1ファイル）を作成
3) Artifactsへ追記（最小）
4) 案内板3ファイルを作成
5) _handoff_check 3ファイルへ計画/手順/タスクを追記
6) 検証 → Evidence記録 → コミット

成果物として、最終的に
- 変更したファイル一覧
- 各変更の要約（追加/修正/削除）
- git diff の要点
- トラッカーの追加STEP一覧（番号と目的）
をまとめて報告してください。

作業はリポジトリの既存Git運用に従う（Prompt.md / cf_update_runbook.md に書いてある手順を優先）。
```
