<!-- GATE_AUDIT_LANG_POLICY_V1 -->
## 表記ポリシー（日本語統一 / SSOT）

- 新しいチャットへ引き継ぐ場合は、**_handoff_check の3ファイル（update_runbook.md / task_tracker.md / handoff_prompt.md）を必ず添付**する（新運用の固定）。
- 添付できない場合は `handoff_prompt.md` の「SSOT 3ファイルを添付できない場合の代替手順」に従う。
- 規範文書（Charter/Mode/Workflow/Artifacts/Skills）は **日本語本文が正（SSOT）**。
- `PROMPTS/` や各ツール入口（`CLAUDE.md` / `AGENTS.md` / `GEMINI.md`）は、**日本語本文＋必要最小限の英語要約を併記可**（規範は日本語側）。
- 固有名詞（パス/コマンド/ファイル名/GitHub用語）は **英語表記のまま固定**（無理に日本語化しない）。
- 詳細は `_handoff_check/update_runbook.md` の「言語ポリシー」記載を正とする（このブロックは要約）。


## 引継ぎ簡略運用（旧引継ぎ文書不使用）

- 新チャット添付は次の3ファイルのみ（整合性対象は3ファイル）:
  - `_handoff_check/update_runbook.md`
  - `_handoff_check/task_tracker.md`
  - `_handoff_check/handoff_prompt.md`（都度更新の運用メモだが、SSOTパックに含める）
- SSOTは _handoff_check の3ファイル（**運用規範の最上位は runbook**／trackerは進捗／handoff_promptは便宜）
- 注記: rules/ssot_manifest.yaml の `ssot` は「3ファイル集合（bundle）」の意味であり、SSOT最上位の意味ではない。
- 引継ぎプロンプト（テンプレ・表記固定）:
  > 前回のチャットからの引継ぎを行います。まずは、添付した3つのファイル（handoff_prompt.md / update_runbook.md / task_tracker.md）をすべて読み込んで確認し、整合性の取れた適切な引継ぎ構成を構築してください。update_runbook.md と task_tracker.md に完全準拠し、handoff_prompt.md を参照してこれまでの経緯と次の指示（次にやること1つ）を提示してください。

- SSOTはリポジトリ直下 `_handoff_check/` の3ファイル。
- `_handoff_cache/` は過去の証跡・互換用（原則参照しない）。
- バックアップは `git tag`（作業前タグ）を標準とする。

## Repo Lock（作業開始前の必須チェック）

- 目的: リポジトリ取り違え防止（パス固定ではなく、Repo Fingerprint + Guard で判定する）。
- Repo Fingerprint: `.repo-id/repo_fingerprint.json` を同一性の正とする。
- Guard: `./tools/guard.sh --check` で事前確認し、NGなら中止する。
- 破壊的操作（restore/reset/clean/rm など）は Guard 経由を推奨する。
- 詳細: `WORKFLOW/TOOLING/REPO_LOCK.md`

例:
```
./tools/guard.sh --check
./tools/guard.sh -- git status -sb
```

## 初期設定（役割割当）

- 役割は Developer が初期設定ファイルで割り当てる（3ファイルは入口であり固定しない）。
- 参照: `WORKFLOW/TOOLING/INITIAL_SETTINGS.md`
- 設定例: `.repo-id/agent_role_assignment.example.yaml`
- 実運用ファイル（例: `.repo-id/agent_role_assignment.yaml`）はローカル専用のため Git 管理しない（`.gitignore` 推奨）。

### バックアップ（STEP-006）作成の判断基準（運用ルール）

原則:
- バックアップは「上書き更新」しない。常に新規作成（証跡固定のため）。
- 標準は `git tag`（作業前タグ）。
- ディレクトリバックアップ（例: `../context-framework_backup_YYYYMMDD[-HHMM]`）は、必要に応じて補助として併用してよい（証跡を残すこと）。

バックアップ作成を必須とするタイミング（いずれか該当で実施）:
- 広範囲の変更に入る前（大量編集/移動/削除、SSOT更新など）
- 事故りやすいGit操作の前（rebase/reset/履歴改変/大きめのマージ 等）
- Gateをまたぐ前後、または作業の大きな区切りの前後
- 「この時点に戻れないと困る」作業を始める前

命名規則（例）:
- git tag: `backup/YYYYMMDD-HHMM`（または `backup/YYYYMMDD`）
- directory: `../context-framework_backup_YYYYMMDD-HHMM`

証跡（Evidence）:
- `task_tracker.md` の STEP-006 の Evidence に「tag名（またはバックアップ先パス）」を記録する
- 完了時は Progress Log/Updates に「日時・タスクID・証跡（tag名/パス）」を追記する


# context-framework アップデート手順書（統合版 + Skills運用統合）
Version: draft-2026-01-16+skills

この手順書は、このチャットで確定した方針と、_handoff_check の3ファイルの内容を統合し、**context-framework 全体の整合性（Charter→Mode→Artifacts→Skills）を保ったままアップデートする**ための実行ランブックです。

> 進捗管理・証跡（Evidence）記録は、併設のタスク管理票 `task_tracker.md`（最新版） を使用します。

- ログ索引（`LOGS/INDEX.md`）は生成物。trackerの LOG/UPD/SKILL-LOG を更新したPRでは `tools/log-index.sh` を再実行し、同一PRで更新する。
※最新版: `_handoff_check/task_tracker.md`（バージョン番号はファイル名から除去、本文ヘッダで管理）。
---

## 1. 目的とスコープ

### 1.1 目的
- **独立監査（Auditor）**を追加し、既存の Gate A/B/C に自然に接続（推奨：**Gate D**）。
- **3つの常駐指示ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）**を、単なる入口ではなく「各AIエージェントに直接渡せる運用アダプタ」として整備し、context-framework と各エージェントの連携精度を上げる。
- **Skills（ツール非依存の再利用可能ワークフローモジュール）**の統合方針をフレームワーク側で固定し、上位レイヤに従属させて再現性を上げる。

### 1.2 絶対に崩さない優先順位（Single Source of Truth）
**Charter → Mode（lite/standard/strict） → Artifacts（Task Lists / Implementation Plan / Walkthrough） → Skills**

---

## 2. 最重要の統一文言（※“全アップデート手順書”作成時に反映する方針で保留中）

> **AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**

- 「Auditorが図やフローに登場する」ことと「実装しない（指摘のみ）」は矛盾しません。
- Auditorは **判断（PASS/FAIL）と根拠（Evidence）と指摘（Action Items）**を返し、修正は実装担当（Crafter/Orchestrator）が行います。

---

## 3. 現状（このチャットまでに入っている前段アップデート）

- `WORKFLOW/MODES_AND_TRIGGERS.md`（Lite/Standard/Strict と Triggers）
- `WORKFLOW/GATES.md`（Gate A/B/C：Profile/Triggers を成果物へ接続）
- `WORKFLOW/BRANCHING.md`（`wip/<version>` 表記で一般化、Modes/Triggersの導線）
- `ARTIFACTS/{TASK_LISTS,IMPLEMENTATION_PLAN,WALKTHROUGH}.md`（Profile/Triggersの記入導線）

以降のアップデートは、上記の体系を壊さずに **追加＋最小修正**で入れます。

---

## 4. 役割分担（ロール）と AI エージェント割当

### 4.1 ロール（責務）
- **Architect**：設計・止め役・整合性の前段チェック
- **Crafter**：実装（ファイル追加/修正/削除）
- **Orchestrator**：タスク分解・横断整合・進行管理
- **CI/QA**：Walkthrough 実行・ログ化・Gate C 判定
- **Auditor**：整合性・証跡・リスク監査・Gate D 判定（実装はしない）
- **衝突時の意思決定**：SSOT（_handoff_check）は運用の入口だが、Charter→Mode→Artifacts→Skillsに従う。衝突時はSSOTを勝手に上書きせず、Architectが選択肢（Yes/Noまたは複数案）と影響/リスク/差分を提示し、DeveloperがGo/No-Goで承認する。承認後に実装し、trackerに証跡を残す。

### 4.2 エージェント別「常駐指示ファイル」対応
| エージェント | 対応ファイル | 参考例（固定しない） |
|---|---|---|
| Claude Code | `CLAUDE.md` | Crafter（実装） |
| OpenAI Codex | `AGENTS.md` | Crafter/Orchestrator（CLI運用も含む） |
| Google Antigravity / Gemini系 | `GEMINI.md` | Orchestrator（統制/整理） |

---

## 5. リポジトリに入れる変更（追加・修正の一覧）

### 5.1 追加（Add）
**監査（Auditor）導入**
- `ARTIFACTS/AUDIT_REPORT.md`
- `ARTIFACTS/AUDIT_CHECKLIST.md`
- `ARTIFACTS/EXCEPTIONS.md`（任意だが推奨）
- `PROMPTS/AUDITOR.md`
- `WORKFLOW/AUDIT.md`（任意）

**3ファイル共存（アダプタ化）**
- `WORKFLOW/TOOLING/COEXIST_3FILES.md`
- （任意）`TOOLING/ADAPTERS/{CLAUDE,AGENTS,GEMINI}.template.md`

**Skills統合（方針固定）**
- `WORKFLOW/SKILLS_INTEGRATION.md`（必須：統合方針の“唯一の正”）
- `SKILLS/README.md`（推奨：Skills入口）
- `SKILLS/skill-template/SKILL.md`（推奨：雛形）
- （任意）`SKILLS/_registry.md`（推奨：Skill一覧と用途・バージョン）

**図（Modesのインフォグラフィック）**
- `docs/diagrams/modes_lite.png`
- `docs/diagrams/modes_standard.png`
- `docs/diagrams/modes_strict.png`

### 5.2 修正（Modify）
- `WORKFLOW/GATES.md`：**Gate D（Audit Gate）** を追加
- `WORKFLOW/MODES_AND_TRIGGERS.md`：Strict（推奨）に **Gate D必須**として接続
- `ARTIFACTS/TASK_LISTS.md`：Done条件/GO-NO-GOに Gate D（監査成果物が揃う）を接続
- `ARTIFACTS/IMPLEMENTATION_PLAN.md`：工程に Gate D を追加（Gate Cの後）
- `ARTIFACTS/WALKTHROUGH.md`：Evidence（LOGS/diff/checksums）の定義を明記し、Gate Dに導線
- （存在する場合）`README.md` / `PROMPTS/*`：ロール一覧、進行にAuditorを追加

---

## 6. 推奨ポリシー（迷いどころを固定する）

### 6.1 Gate D（監査）をどのModeで必須にするか
**推奨：Strict必須、Standard推奨（任意）、Lite任意**
- Lite：速度優先。監査は“重要変更のときだけ”実施。
- Standard：品質と速度のバランス。監査は“推奨”として運用（重大変更なら必須へエスカレーション）。
- Strict：監査・証跡を最重視。**Gate D必須**。

### 6.2 3ファイル（CLAUDE/AGENTS/GEMINI）の役割
- 3ファイルは **エージェントに直接渡せる**内容にしてよい。
- ただし「唯一の正」は context-framework 側（Charter/Mode/Artifacts/Skills）。
- 3ファイルには **リンク・I/O契約・禁止事項・起動チェック**を中心に置き、詳細本文の複製は避ける。

---

## 7. Skills 運用統合（この手順書の追加コア）

> Skillsを「会話の代替」ではなく、**繰り返し導入手続きを再現可能にする“手順モジュール（Playbook）”**として固定し、上位レイヤ（Charter/Mode/Artifacts）に従属させます。

### 7.1 Skillsが解決する課題（Supabase/Stripeの例）
- 長い導入手順（UI/CLI/API混在）を毎回説明し直すコスト
- 権限・環境変数・既存状態の違いによる抜け漏れ
- Secrets / Billing / Webhook / 権限などの“落とし穴”の再発

Skillsはこれを「毎回説明」ではなく、**Skillを呼ぶ＝手順一式を読み込ませる**へ置き換えます。

### 7.2 位置づけ（整合性の固定）
- Skillsは **方針を決めない**（Charter/Modeが決める）
- Skillsは **Artifactsの形を勝手に変えない**（Artifactsが正）
- Skillsは「どう実行するか」を提供し、**何を/どの厳密さで**は上位が決める

### 7.3 ツール非依存を保つ構造（Core / Adapters 分離）
- **Core（ツール非依存）**：目的、前提、入出力、ステップ、検証、ロールバック
- **Adapters（ツール依存）**：Claude Code / Codex / Antigravity など“実行方法”の差分だけ

推奨構造：
```text
SKILLS/
  <skill-name>/
    SKILL.md
    adapters/
      claude_code.md
      codex.md
      antigravity.md
```

### 7.4 Skillの最小テンプレ（SKILL.md）
`SKILLS/skill-template/SKILL.md` は、最低限以下を持ちます。

- Purpose
- Scope / Non-goals
- Preconditions
- Inputs（Mode含む）
- Outputs（Artifactsへの追記/証跡を含む）
- Procedure（Tool-agnostic）
- Checks（成功条件）
- Security（Secrets禁止、billing/destructiveは明示要求）
- Rollback
- Optional Adapters

### 7.5 Skillの呼び出し（運用フレーズ）
- `Apply Skill: SKILLS/<skill-name>`

3ファイル（CLAUDE/AGENTS/GEMINI）には共通で次を入れます：
- 「作業時はまず該当Skillを探索し、あればそのSkillを優先して実行する」
- 「Skillが無い場合のみ新規作成提案」

### 7.6 SkillsとGate/Artifactsの接続（ここで“再現性”が出る）
Skillsは単体で完結させず、必ずArtifactsへ“書き戻し”ます。

- **Task Lists**：Skill適用タスク（入力収集→適用→検証→証跡）をタスク化
- **Implementation Plan**：ファイル単位の変更（Add/Mod）と、どのSkillを適用するかを明記
- **Walkthrough**：Skillが要求する検証手順（Webhook疎通、ENV確認、CLI結果など）をログ化

監査（Gate D）では、Skill適用のEvidence（ログ/差分/チェック結果）が揃っているかを見ます。

---

## 8. 実行プロトコル（運用ルール）

- 検索（見つからなくてもOK）系の `rg`/`grep` などは必ず `|| true` を付けて 0 終了にする

- 1コマンド/1操作ずつ進め、都度ログ/結果（スクショ等）を残す
- 変更が入ったら必ず **追加/削除/修正** を明示
- コマンドを提示する場合、**そのコマンドの意味（復習用）**を必ず添える
- 出力（根拠/判定/変更提案）は**重要点のみ短く**（冗長な実行ログ/出力の転載は不要。必要なら要点のみ）
- 復習コマンド（`git status -sb` / `git fetch --prune origin` / `HEAD==origin/main` / `git log -1`）は**毎回短く**添える
- 新規タスクの入口は Gate H（Phase 1）に統一する（Gate G は完了扱い）
- 軽微変更は手作業（開発者がCLI）、複雑変更はCrafter/Orchestrator主導（AIで実装）

### I5: 運用統合（timing / failure / evidence / smoke）
- 実行タイミング:
  - 作業開始前: `./tools/guard.sh --check`
  - 主要作業前（またはPR前）: `./tools/doctor.sh step STEP-G003`
  - 失敗時: 原因と根拠を示して中止 → 次の1手を1コマンドで提示
- 失敗時の運用:
  - FAIL時は安全停止（中止）→ next_action を1つだけ提示（再実行前提）
- Evidence:
  - 規範は runbook、実行結果/証跡は tracker の Progress Log/Updates に残す
- 最小スモーク（導線）:
  - `./tools/doctor.sh step STEP-G003`
  - 必要に応じて `./tools/ci-validate.sh`（smoke含む）

### パッチ（unified diff）事故防止ルール（必須）

- **原則**：チャットからコピペした diff は崩れやすい。適用前に `git apply --check` を必須とする。
- **推奨**：差分はローカルで生成する（例：変更後ファイル `.new` を作り、`diff -u` で `/tmp/*.patch` を生成）。
- **受領パッチを使う場合**：`cat <<'PATCH'` でファイル化 → `git apply --recount --check` まで通ったものだけ採用する。
- `corrupt patch` / `fragment without header` / `does not apply` が出たら **修復に粘らず**、ローカル生成（`.new`→`diff -u`）へ切り替える。

### 8.1 例外：PR後の後処理を“まとめて提示”する場合（ガード付き一括手続きテンプレ）

#### コピペ枠：ガード付き一括最終確認（main同期）

- ユーザーが一括処理を希望した場合にのみ使用（基本は「次にやること1つ」）。
- **必ず先頭でGuard（誤リポジトリ防止＋Repo Lock）**を実行し、NGなら中止。
- 最後に `HEAD == origin/main` を確認して同期ズレを潰す。

```bash
set -euo pipefail

REPO="/home/masahiro/projects/context-framework"
cd "$REPO"

# Guard（安全確認：想定リポジトリ以外なら中止）
test "$(git rev-parse --show-toplevel)" = "$REPO"
./tools/guard.sh --check

# 同期/クリーン確認（push後の最終整合）
git status -sb
git fetch --prune origin
test "$(git rev-parse HEAD)" = "$(git rev-parse origin/main)"
git status -sb
git log -1 --oneline --decorate
```
この例外は、Developerが「PRタイトル/本文も提示し、PR/merge/branch削除/同期/prune/statusまで一括で指示して」と**明示要求**した場合のみ有効。

- main保護: **main は削除しない**
- ブランチの決め方:
  - 環境変数 `TOPIC_BRANCH` があればそれを使う
  - なければ「実行開始時のブランチ（start_branch）」を削除候補にする
- 削除条件: topic が main ではなく、**main にマージ済みのときのみ** `git branch -d`

```bash
# guard: Repo Lock（想定リポジトリ以外なら中止）
./tools/guard.sh --check

# branch capture
start_branch="$(git rev-parse --abbrev-ref HEAD)"
topic_branch="${TOPIC_BRANCH:-$start_branch}"

# sync main
git switch main
git fetch --prune origin
git pull --ff-only origin main

# delete local topic branch if merged (never delete main)
if [ "$topic_branch" != "main" ]; then
  if git branch --merged main | sed 's/^\\* //' | grep -qx "$topic_branch"; then
    git branch -d "$topic_branch"
  else
    echo "WARN: $topic_branch is not merged; skip delete"
  fi
else
  echo "WARN: topic_branch is main; skip delete"
fi

# cleanup and final status
git fetch --prune origin
git status -sb
```

注意:
- このテンプレは**全文を一括コピペ可能**な形で提示する。
- 実行結果を貼って次に進む（1手運用の原則は維持）。
---

## 8.2 運用フロー契約（SSOT→doctor→GO/NO-GO→Skills）

- **SSOT優先順位**: runbook（最上位） > tracker（進捗） > handoff_prompt（便宜）
- **doctor出力契約**:
  - 必須: PASS/FAIL / failures（不足理由） / evidence（file:line+短い抜粋） / next_action（**1コマンドのみ**）
  - Read-only厳守（ファイル変更はしない）。Python等は**必須にしない**（あれば補助可）。
- **GO/NO-GO契約（Architect/Auditor）**:
  - 参照根拠: runbook・LOGS・生成物（evidence）を優先
  - NO-GO時: 欠落/不整合と必要な次の1手（1コマンド）を明示して差し戻す
- **Skills昇格/更新契約**:
  - 昇格条件の正は `WORKFLOW/SKILLS_INTEGRATION.md`（最小条件に準拠）
  - 更新時は **リンク/証跡（PR/commit/LOG/UPD）** を残す（runbook/trackerに記録）

## 9. アップデート手順（Gate運用で統合する）

### Phase 0：準備（作業ブランチ・現状固定）
- ブランチ：`wip/<version>`（例：`wip/v0.1.5`）
- 差分対象を洗い出し（Evidenceとして残す）

### Phase 1：Gate A（スコープ固定）
- 追加/修正するファイルを「やる/やらない」単位で確定
- Skills関連はこの時点で「入れる方針」と「最初に作るSkill候補（例：supabase/stripe）」を記録

### Phase 2：Gate B（差分計画固定）
- ファイル単位で Add/Modify を確定（パスまで確定）
- Skillsは「どのSkillを適用するか」「SkillがArtifactsへ何を書き戻すか」まで計画へ反映

### Phase 3：実装（Crafter）
- 監査テンプレ、3ファイル、Skills統合方針、Skills雛形を追加
- Gate/Artifactsへ導線を追加（最小修正で）

### Phase 4：検証（CI/QA）— Gate C
- Walkthroughに従って検証し、ログを `LOGS/` に保存
- Skills適用による検証結果（CLI結果/疎通/設定値）もEvidenceとして残す

### Phase 5：監査（Auditor）— Gate D
- `AUDIT_REPORT` / `AUDIT_CHECKLIST` / `LOGS/audit_*.log` を揃える
- PASS/FAILを明示し、FAILなら最小修正パッケージで差し戻す（実装はしない）

### Phase 6：反映判断（Human）
- GO/STOPを判断し、必要なら main へ反映またはリリース作業へ

---

## 10. 受入チェック（Doneの判定）

- [ ] `WORKFLOW/GATES.md` に Gate D が追加され、既存A/B/Cが壊れていない
- [ ] `WORKFLOW/MODES_AND_TRIGGERS.md` と Gate D の関係が明記されている（推奨：Strict必須）
- [ ] `ARTIFACTS/*` が Gate D に導線を持ち、Evidence定義が揃っている
- [ ] `AUDIT_REPORT` / `AUDIT_CHECKLIST` が存在し、監査が単体で実行できる
- [ ] 3ファイル共存（アダプタ化）方針が1か所に固定され、テンプレがある
- [ ] `WORKFLOW/SKILLS_INTEGRATION.md` が「従属関係」と「ツール非依存（adapters分離）」を満たす
- [ ] `SKILLS/skill-template/SKILL.md` があり、新規Skill作成が再現可能


---

## 追記（2026-01-17）｜統一文言の“保留”扱いを解消（実ファイルへ反映済）

本書 2章の統一文言は「保留中」としていたが、整合性維持のため **実ファイルへ反映**した。
- 対象ファイル（Mod）:
  - `WORKFLOW/AUDIT.md`
  - `ARTIFACTS/AUDIT_REPORT.md`
  - `ARTIFACTS/AUDIT_CHECKLIST.md`
  - `PROMPTS/AUDITOR.md`
- 統一文言:
  - `AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。`

## 追記（2026-01-17）｜言語ポリシー（層×言語）を先に確定してから進める

ドキュメントの日本語/英語混在により、表現整合性の確認コストが増える懸念があるため、**next2/next3 着手前に言語ポリシーを確定**する。
- 基本方針（案）:
  - **規範（Charter/Mode/Workflow/Artifacts/Skills）は日本語を正**（Single Source of Truth）。
  - `PROMPTS/` や各ツール入口は、日本語本文を正としつつ、必要なら英語要約を短く併記（規範の複製は禁止）。
  - 固有名詞（パス/コマンド/ファイル名/Git用語）は英語表記のまま固定。


## 追記（2026-01-17）
### 最新参照（v5）
- Single Source of Truth: `update_runbook.md`（運用規範）
- 進捗の最新参照: `task_tracker.md`
- 本文中に `task_tracker.md` / `cf_task_tracker_v4.md` 等の旧参照が残っていても、履歴として保持し、**最新の進捗は `task_tracker.md` を参照**する。

## 翻訳レイヤ（抽象→具体の戻り先）

- 迷ったらまず `WORKFLOW/TRANSLATION_LAYER.md` を参照する（憲章/Modeの原則を、Artifactsへ落とす if/then 判断手順）。
- Artifacts側の参照導線：`ARTIFACTS/TASK_LISTS.md` / `ARTIFACTS/WALKTHROUGH.md`

---

## 付録：tracker退避（テンプレ/アーカイブ）

## 付録：Gate H アーカイブ（完了済みチェックリスト）
- 注記: これは履歴/退避。現行の次にやる1手は tracker の進捗サマリが正。
- 次にやる1手: Gate I / I1（Gate I 入口定義: 目的/Done条件/最初の1手をSSOTに最小追記）
### Gate I: 入口定義（I1）とSSOTスリム化（I0）
- 補足（番号整理）: Gate I の入口定義は I1 から開始（旧 I2→I1、旧 I1→I0）
- 定義:
  - Gate I / I1: 入口定義（目的 / Done条件 / 最初の1手をSSOTへ最小追記）
  - Gate I / I0: SSOTスリム化（旧 I1: Gate H 完了チェックリスト退避 + SSOTスリム化）
- 意図: Gate Hの入口定義は維持しつつ、次フェーズ(Gate I)の入口定義を固める

## Gate H（新規タスクの入口）
### Phase 1（未着手タスク）
- （新規タスクをここへ追記：1行1タスク、Evidenceは必要に応じて）
- [x] H1: 昇格/分類ルール（STEP-G006）確定再確認
- [x] H2: workspace_tracker 非SSOT扱い確定再確認
- [x] H3: Phase 0 — `bin/ctx-run`（SSOT束注入）＋ `rules/ssot_manifest.yaml`（最小）
- [x] H4: Phase 1 — ルール設計（`routes.yaml` / `policy.json` / `ssot_manifest.yaml`）
- [x] H5: Phase 1 — Controller骨格（分類JSON→検証→束生成→生成→検証→ログ）
- [x] H6: Phase 1 — 危険操作ゲート（Go/NoGo）＋危険フラグ/禁止語の検知
- [x] H7: Phase 1 — 2段階出力の定型（次の1手1つ/復習用/変更点/根拠）
- [x] H8: Phase 1 — テスト（不一致は停止 / high riskはGo/NoGo / JSON破損は再生成or停止）
- [x] H9: Phase 1 — Gate C 検証組込み（`validate_agent_adapters()`：STEP-304/305/306）
- [x] H10: Phase 2 — Docs MCP（読み取り専用）導入手順の整備（任意）
- [x] H11: Phase 2 — 用途別ツールMCP（STDIO）設計（`get_ssot_bundle`/`diff_summary`等）
- [x] H12: Phase 3 — 運用成熟（CIでスキーマ/ルール検証、ログ整備）
<!-- CFCTX_TRACKER_ARCHIVE_V5_SLIM_20260126 -->
### 付録A: task_tracker.md（スリム化前の内容）
（履歴保全のため、旧セクションを runbook へ移設）

## 0. 基本情報（必須）

- 作業日: 2026-01-17（JST）
- 作業者: Masahiro
- 作業リポジトリ: `/home/masahiro/projects/context-framework`
- 追従リポジトリ: `/home/masahiro/projects/context-framework`（※統合済み、単一リポジトリ運用）
- 作業ブランチ: `wip/v0.1.5`（PR#1でmainへマージ後、ローカル/リモートとも削除済）
- 対象:
  - [x] next1_work（Auditor / Gate D）
  - [x] next2_work（3常駐指示ファイル共存）
  - [x] next3_work（Skills統合）
- 参照手順書: `update_runbook.md`
- 実行方針（固定）: **Charter → Mode → Artifacts → Skills**
- 監査運用（固定 / 表現統一は後で反映）: **AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**

---

## 1. 運用ルール（この作業の事故防止）

> ※ここは **常設ルール（憲法）**。チェックボックスで「完了」を表現しない。
> 各セッションでの実行確認（Repo Lock実行・1手運用・変更点明示・復習ログなど）は、下部の **Progress Log/Updates** に日付＋Evidenceとして残す。


- 「次にやることは1つだけ（1コマンド/1操作）」を守る
  - 例外（Developerが明示的に「このセッションは複数提示で」と要求した場合のみ）：
    - そのセッションに限り、手順を複数提示してよい（次回は要求がない限り、必ず「次にやること1つ」に戻す）。
    - ただし原則として、複数提示を許容するのは **読み取り系コマンド（確認/表示）** に限る。
    - **書き込み系（編集/削除/コミット等）** が含まれる場合は、事故防止のため「1手」または「最大3手＋中間で結果貼付」を維持する。
  - 例外（Developerが「PRタイトル/本文も提示し、PR/merge/branch削除/同期/prune/statusまで一括で指示して」と明示要求した場合のみ）：
    - PR後の後処理（PR/merge/branch削除/ローカル同期/prune/status）を**ガード付きテンプレ**でまとめて提示してよい（詳細は runbook 8.1）。
    - ブランチ削除は **mainを絶対消さない**／**マージ済みのみ削除**／**指定がなければ開始時ブランチを対象**。
    - `git pull --ff-only` / `git fetch --prune` / `git status -sb` を含める。
    - コマンドの意味（復習用）と矛盾しないよう、説明は runbook 8.1 に集約して添える。
- 作業開始前に Repo Lock を確認する（`./tools/guard.sh --check`）。NGなら中止し、原因を確認する（詳細は runbook の Repo Lock）。
- 変更したら必ず「何を追加・削除・修正したか」を記録する
- コマンドを実行したら「意味（復習用）」も必ず記録する
- 迷ったら上位規範（Charter→Mode→Artifacts→Skills）に戻って判断する
- 重大変更（広範囲修正/設計変更/大量差分）は Crafter/Orchestrator で実装し、人間は指示と検証に徹する

---

## 2. 進捗サマリ（毎ステップ更新）

- 現在のフェーズ: ☑完了（next1: Auditor/Gate D） / ☐次2（3常駐指示ファイル共存） / ☐次3（Skills統合）
- 直近の完了ステップID: `STEP-503`（PR#1 merge）
- 未解決ブロッカー:
  - （なし）
- 次にやる「1手」:
  - 次の指示待ち（追加タスクがあれば Gate F に追記）

    - 実作業のSSOTは `/_handoff_check/` の3ファイル（`task_tracker.md` / `update_runbook.md` / `handoff_prompt.md`）です。
    - 差分洗い出しは、リポジトリ内の `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` を対象に行います。

---

## 3. 実行ログ（証跡として残す）

> ここは「コマンド実行のたびに」追記します。  
> **各LOGの冒頭に Guard（安全確認）ブロックを必ず入れ、Repo Lock: OK の証跡を残す**こと。  
> 可能なら、貼り付けた実行結果のスクショ/ログファイルのパスも書いてください。

### ガード付き一括処理テンプレ（例外）
Developerが**一括処理を明示要求**した場合のみ利用可（詳細は runbook 8.1）。
必ず **Guard を先頭に置く**。書き込み系を含める場合は runbook 8.1 を参照。

```bash
set -euo pipefail

# guard: Repo Lock（想定リポジトリ以外なら中止）
cd /home/masahiro/projects/context-framework
test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"
./tools/guard.sh --check
git remote get-url origin
git status -sb

# ここから下に実処理（読み取り系中心）
# 書き込み系を含める場合は runbook 8.1 の手順に従う
```

### LOG-001｜Gate D（Audit）テンプレ/運用ドキュメント追加
- 日時: 2026-01-17
- Guard（安全確認）:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `git remote get-url origin`
  - `git status -sb`
- 実行コマンド:
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
- Guard（安全確認）:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `git remote get-url origin`
  - `git status -sb`
- 実行コマンド:
  - `git add ARTIFACTS/AUDIT_CHECKLIST.md ARTIFACTS/AUDIT_REPORT.md ARTIFACTS/EXCEPTIONS.md PROMPTS/AUDITOR.md WORKFLOW/AUDIT.md`
  - `git commit -m "Add Audit Gate D templates and docs"`
  - `git push -u origin wip/v0.1.5`
- コマンドの意味（復習用）:
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
- Guard（安全確認）:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `git remote get-url origin`
  - `git status -sb`
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
- Guard（安全確認）:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `git remote get-url origin`
  - `git status -sb`
- 実行コマンド:
  - `git switch main`
  - `git fetch --prune origin`
  - `git pull --ff-only origin main`
  - `git branch --merged main`（確認）
  - `git branch -d wip/v0.1.4 wip/v0.1.5`
- コマンドの意味（復習用）:
  - `git switch main`：mainへ移動
  - `git fetch --prune`：削除済みリモート追跡を整理
  - `git pull --ff-only`：Fast-forwardのみ許可して同期
  - `git branch -d`：マージ済みブランチのみ削除（mainは削除しない）
- 実行結果（貼り付け/要約）:
  - mainに反映（Fast-forward）、ローカルは main のみ
- 出力/証跡:
  - `git status` → working tree clean
- 次の1手:
  - リモート追跡ブランチの掃除（fetch/prune）

### LOG-005｜remote.origin.fetch のrefspec修正→fetch --prune
- 日時: 2026-01-17
- Guard（安全確認）:
  - `cd /home/masahiro/projects/context-framework`
  - `test "$(git rev-parse --show-toplevel)" = "/home/masahiro/projects/context-framework"`
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `git remote get-url origin`
  - `git status -sb`
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
  - next2_work（3常駐指示ファイル共存）へ着手
  - ※必要時のみ。常用しない（判断は runbook 8.1 と Repo Lock に従う）


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
  - next1_work（Auditor/Gate D）
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
| STEP-001 | 作業/追従リポジトリのパス確認 | [x] | `pwd` → `/home/masahiro/projects/context-framework` | - |
| STEP-002 | ブランチ確認（wip/<version>） | [x] | `git branch`（作業時: `wip/v0.1.5` / 現在: `main`） | - |
| STEP-003 | clean確認 | [x] | `git status` → working tree clean | - |
| STEP-004 | リモート確認 | [x] | `git remote -v` | - |
| STEP-005 | 差分対象の洗い出し・内容把握 | [x] | 展開先パス＋ファイル一覧 | - |
| STEP-006 | バックアップ（作業前タグ） | [x] | tag名 or バックアップ | - |

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
| STEP-407 | Skill適用ログ（SKILL-LOG）がEvidenceに揃っているか確認 | [x] | _handoff_check/task_tracker.md: SKILL-LOG-001/002（L170, L188） | Mod |
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

### Gate F｜初期設定/役割割当（Developer設定に従う）

| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-507 | 初期設定ファイルの設計と置き場を追加（例: .repo-id/agent_role_assignment.example.yaml） | [x] | `.repo-id/agent_role_assignment.example.yaml` / `WORKFLOW/TOOLING/INITIAL_SETTINGS.md` / PR#28（merge: 18edacb / commit: 463b277） | Add |
| STEP-508 | 3ファイルの「役割固定」撤廃と役割一覧の共通化 | [x] | `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / PR#28（merge: 18edacb / commit: 463b277） | Mod |
| STEP-509 | templates（TOOLING/ADAPTERS）を初期設定参照へ整合 | [x] | `TOOLING/ADAPTERS/CLAUDE.template.md` / `TOOLING/ADAPTERS/AGENTS.template.md` / `TOOLING/ADAPTERS/GEMINI.template.md` / PR#28（merge: 18edacb / commit: 463b277） | Mod |
| STEP-510 | COEXIST_3FILES に初期設定ファイル導線を追記 | [x] | `WORKFLOW/TOOLING/COEXIST_3FILES.md` / PR#28（merge: 18edacb / commit: 463b277） | Mod |
| STEP-511 | runbook/handoff に初期設定ファイル導入を追記 | [x] | `_handoff_check/update_runbook.md` / `_handoff_check/handoff_prompt.md` / PR#28（merge: 18edacb / commit: 463b277） | Mod |
| STEP-512 | 整合チェック（3ファイル参照一致/Repo Lock非混同） | [x] | `rg -n "INITIAL_SETTINGS.md" CLAUDE.md AGENTS.md GEMINI.md` / `rg -n "Repo Lock" _handoff_check/update_runbook.md` / PR#28（merge: 18edacb / commit: 463b277） | Mod |

---

### Gate G｜ログ運用95%効率化（Concrete/Abstract連携）

#### Gate G Done定義
- 抽象（カテゴリ）→具体ID→解決策 の導線が成立している
- 抽象側が肥大化しないルールがある（カテゴリ増殖抑制）
- 生成物運用なら再生成手順が明確で同一PR更新ができる
- 成功パターンがSkillへ昇格できる（入口がある）
- 証跡（commit/PR/ログ）が tracker に残っている

#### Phase 1（検索導線の成立：最小導入）
| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-G001 | 現状棚卸し（具体ログの正/抽象索引の正）をSSOTに沿って確認 | [x] | LOG-007 / LOGS/INDEX.md | Mod |
| STEP-G002 | 具体ログの最小テンプレ合意（ID/状態/カテゴリ/症状/原因/対処/証跡） | [x] | LOG-008 / LOGS/INDEX.md | Mod |
| STEP-G003 | 抽象ログ（索引）仕様合意（カテゴリ→パターン→具体ID、ID検索を正） | [x] | LOG-009 / LOGS/INDEX.md | Mod |
| STEP-G004 | 運用ルール追記が必要か判定（同一PRで索引更新、生成物の扱い等） | [x] | _handoff_check/update_runbook.md:L80 | Mod |
| STEP-G005 | 受入テスト（失敗→抽象→具体→解決策へ辿れる）を最小シナリオで検証 | [x] |  LOG-007 / LOGS/INDEX.md / _handoff_check/update_runbook.md:8.1  |  Mod  |
| STEP-G006 | 定義固定（Concrete→Abstract→Skills：成功/失敗/同種判定/昇格/例外） | [x] | WORKFLOW/SKILLS_INTEGRATION.md | Mod |
| STEP-G007 | Signature集計（>=2/>=3）候補検出ツール追加（refs付き） | [x] | tools/signature-report.sh | Add |

##### STEP-G005 受入テスト（最小シナリオ）チェック項目
- 対象シナリオ（過去事例）: patch/unified diff 適用失敗（例: `No valid patches` / `does not apply` / `corrupt patch`）
- 実行: 失敗事例のConcreteを起点に、Abstract（カテゴリ/パターン）→ Concrete → 解決策（runbook/変更）まで辿る
- 期待: 成功(SUCCESS)=狙った状態に到達し、検証コマンドで再現確認できる／失敗(FAIL)=狙った状態に未到達、または同じ失敗が再現する
- 記録: Concreteに **Category / Signature（同種判定キー） / Evidence** を残す（Abstractは索引＋パターン＋参照先に限定）

##### STEP-G006 定義固定（Concrete→Abstract→Skills の最小ルール）
- 成功/失敗（必要ならPartial/Unknown）定義：Concreteは「1回の試行＝1エントリ」
- Signature仕様（Concreteに置く）：項目（例: error_code / message要約 / component）、短い固定文字列、例: `patch-apply/no-valid-patches` / `patch-apply/does-not-apply`
- 同種2回目ルール：Signatureの件数>=2で Abstract に「入口のみ」作成（手順は書かず refs: [Concrete#...] と件数だけ）
- Skills昇格（3回目）最小条件：3回成功 + 再現性（前提/手順/検証コマンド固定）+ 受入テスト + 安全弁（read-only確認/dry-run/ロールバック導線等）
- 例外：重大事故/高頻度は1回目でも Abstract に入口のみ（手順は書かず Concrete 参照）
- （2026-01-27 調査で確定再確認）昇格/分類ルールは本 STEP-G006 を正とする
- （再確認）抽象ログは「索引＋パターン＋参照先」のみ（手順全文は書かない）
- 証跡: `handoff_prompt.md` の「調査証跡」小節を参照

##### STEP-G007 Signature集計ツール（候補検出）
- 目的: ConcreteのSignature出現回数を集計し、Abstract(>=2)/Skills(>=3)の候補を提示（検出のみ）
- 実行例:
  ./tools/guard.sh -- tools/signature-report.sh --min 2
  ./tools/guard.sh -- tools/signature-report.sh --min 3 --scope LOGS
- 出力: "count | signature | refs(file:line...)" の形式

#### Phase 2（カテゴリ/パターン育成：肥大化抑制）
| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-G101 | 固定カテゴリ案を作成（最小セット＋OTHER有無の検討） | [x] |  Gate G Phase2: 固定カテゴリ案（git/tooling/docs/workflow/log-index + OTHER）  |  Mod  |
| STEP-G102 | パターン分類案を定義（例：接続/権限/マイグレーション等） | [x] |  Gate G Phase2: パターン分類案（reference-miss/generation-gap/permission-block/connectivity-issue/procedure-mismatch/state-divergence）  |  Mod  |
| STEP-G103 | 新カテゴリ追加ルール（同種2回目から/Go-NoGo）の必要性を判定 | [x] | Gate G Phase2: 新カテゴリ追加ルール（Go/No-Go） | Mod |
| STEP-G104 | 受入テスト（同種2回→パターンにまとまる）を検証 | [x] | procedure-mismatch（unified diff事故） / runbook:パッチ事故防止（637b0db） | Mod |

##### 固定カテゴリ案（STEP-G101）
- **git**: git操作（branch/merge/rebase/reset/fetch等）に関する失敗・手順
- **tooling**: tools/ 配下スクリプトや自動化・CI補助に関する失敗・手順
- **docs**: ドキュメント更新・表記揺れ・SSOT整合に関する失敗・手順
- **workflow**: Gate/Mode/Artifacts/運用ルール等のプロセス設計に関する失敗・手順
- **log-index**: LOGS/INDEX の生成・参照導線・索引運用に関する失敗・手順
- **OTHER（推奨）**: 初出の単発のみで一旦受け止める避雷針。**同種が2回目に出た時点で**既存カテゴリへ移管 or 新カテゴリ検討（STEP-G103の判断材料）

##### パターン分類案（STEP-G102）
- **reference-miss**: 参照先/リンク/ファイル指定の曖昧や不足（パス・リンク切れ等を含む）。境界：単一の手順問題は含めない。
- **generation-gap**: 生成・再生成・同期の手順漏れ/順序違い（INDEX再生成を含む）。境界：単なる参照ミスは含めない。
- **permission-block**: 権限/保護/保留/停止による実行停止（protected branch案を含む）。境界：単なる接続障害は含めない。
- **connectivity-issue**: 接続/通信/到達性の失敗（fetch/push/remote 到達など）。境界：権限問題は permission-block へ。
- **procedure-mismatch**: 手順/運用ルール/手順の取り違え（runbook記載の手順に寄せる）。境界：生成漏れは generation-gap へ。
- **state-divergence**: 期待状態と実状態のズレ（main同期ズレ/ロック不一致/整合性ズレ）。境界：単発の参照ミスは含めない。



#### 新カテゴリ追加ルール（STEP-G103）
- 初回は OTHER で受け止め、**同種2回目**で初めて新カテゴリ候補を検討する。
- 既存カテゴリへの移管を優先し、**パターンで吸収できる場合はカテゴリ追加しない**。
- 新カテゴリは「固定カテゴリ/パターンで説明不能」な場合のみ採用する。
- 追加時は短いトークン名 + 1行定義を必須とし、カテゴリ増殖を抑える。
- 判断の記録は tracker に残し、INDEX には置かない（INDEX は Generated）。

#### Phase 3（Skill昇格＋監査ループ）
| ID | タスク | Done | 証跡（Evidence） | 変更点（Add/Del/Mod） |
|---|---|---:|---|---|
| STEP-G201 | Skill昇格条件（同種2回以上で候補化等）を確定 | [x] | WORKFLOW/SKILLS_INTEGRATION.md / commit 97535ef | Mod |
| STEP-G202 | Skillsへの導線（抽象→Skill）設計（入口の置き場を決める） | [x] | WORKFLOW/SKILLS_INTEGRATION.md / commit 97535ef | Mod |
| STEP-G203 | Auditor監査観点（再現性/証跡/安全）と指摘→修正→再検証の流れをタスク化 | [x] | WORKFLOW/AUDIT.md（既存） | - |
| STEP-G204 | 受入テスト（入口→Skillに辿れる）を検証 | [x] | WORKFLOW/SKILLS_INTEGRATION.md / commit 97535ef | Mod |

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
  - `update_runbook.md` の参照を `task_tracker.md（最新版）` に統一
  - `cf_task_tracker_v4.md` を作成（v3からコピーし、タイトルを v4 に修正）
  - `task_tracker.md -> cf_task_tracker_v4.md` のシンボリックリンクを作成（最新版追従）
- 出力/証跡:
  - `grep -RIn --exclude-dir=.git "cf_task_tracker_v[0-9]" .` がヒットしないことを確認
  - `ls -l task_tracker.md` でリンク先が v4 であることを確認
- 次の1手:
  - 以後の記録は `task_tracker.md`（最新版）に追記し、必要になったら N+1 を作成



### LOG-007｜Gate G（STEP-G001）現状棚卸し：Concrete/Abstract/検索導線/証跡の確定
- 日時: 2026-01-23
- Guard（安全確認）:
  - `./tools/guard.sh --check`（Repo Lock: OK）
  - `./tools/guard.sh -- git status -sb`（## main...origin/main）
- 実行コマンド:
  - `./tools/guard.sh -- sed -n 1,160p LOGS/INDEX.md`
  - `./tools/guard.sh -- rg -n "STEP-G001" _handoff_check/task_tracker.md`
  - `./tools/guard.sh -- sed -n 350,410p _handoff_check/task_tracker.md`
  - `./tools/guard.sh -- rg -n "## 3\. 実行ログ" _handoff_check/task_tracker.md`
  - `./tools/guard.sh -- sed -n 80,140p _handoff_check/task_tracker.md`
  - `./tools/guard.sh -- rg -n "8\.1" _handoff_check/update_runbook.md`
  - `./tools/guard.sh -- sed -n 245,310p _handoff_check/update_runbook.md`
- コマンドの意味（復習用）:
  - `sed -n a,bp`：対象ファイルの指定範囲だけ表示（参照専用）
  - `rg -n`：行番号つき検索（位置特定→抜粋表示に使う）
- 実行結果（確定事項）:
  - Concrete（具体ログ）の正: tracker（`_handoff_check/task_tracker.md`）の「## 3. 実行ログ」に LOG を追記（各LOG冒頭に Guard 必須）
  - Abstract（抽象索引）の正: `LOGS/INDEX.md`（Generated／手編集禁止／再生成=`./tools/log-index.sh`／Source=tracker）
  - 検索導線: `LOGS/INDEX.md` の `Ref: rg -n "ID" _handoff_check/task_tracker.md` で ID（UPD/LOG/SKILL-LOG）→Concreteへ到達
  - 証跡: Guard（Repo Lock: OK）＋コマンド＋意味（復習）＋結果要約＋（可能ならスクショ/ログパス）
- 次の1手:
  - STEP-G001 を [x] 更新し、同一PRで `./tools/log-index.sh` を再実行して `LOGS/INDEX.md` を更新



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
- SHA256検証：入力ファイル整合 OK
- 展開確認：入力に以下3ファイルが存在
  - `handoff_prompt.md`
  - `update_runbook.md`
  - `task_tracker.md`
- 出力準備：v5雛形を作成
  - `handoff_prompt.md`（コピー）
  - `update_runbook.md`（コピー）
  - `task_tracker.md`（vNをコピーしてv5名に変更）
- 参照整合（追記のみで実施）
  - `update_runbook.md` 末尾に「最新参照（v5）」を追記
  - `handoff_prompt.md` 末尾に「最新参照（v5）」を追記
  - 注：本文中の `task_tracker.md` / `cf_task_tracker_v4.md` 等は履歴として残し、最新は `task_tracker.md` を参照する

### 入力規則（本チャットで受領）
- `cf_handoff_input.md` / `cf_handoff_output.md` の最新版を受領し、以後の更新ルールSSOTとして適用

## 更新ログ（Progress Log / Updates）

- 2026-01-17 | UPD-20260117-01 | SSOT=_handoff_check へ統一 / 表記ポリシー（日本語統一）を3ファイル先頭に追記 / _handoff_cache をSSOTへ同期
  - 対象: 旧引継ぎ文書（当時の運用）, _handoff_check/handoff_prompt.md, _handoff_check/update_runbook.md, _handoff_check/task_tracker.md
  - 変更種別: 追記のみ（チェックボックス変更なし）
  - 証跡:
    - sha256検証: 入力ファイル整合 OK
    - 差分確認: `diff -ruq _handoff_check _handoff_cache/unpacked` -> 差分なし / `diff -ruq _handoff_check _handoff_cache/_handoff_check` -> 差分なし
    - 表記ルール確認: `grep -nE '日本語|表記|英語表記|日本語に統一|日本語表記' _handoff_check/*.md`（該当行ヒット）
    - 追記マーカー:
      - `GATE_AUDIT_SSOT_POLICY_V1`
      - `GATE_AUDIT_LANG_POLICY_V1`


- 2026-01-17 | UPD-20260117-02 | 3ファイル共存アダプタ導入をPR#8でmainへ反映し、Gate C（STEP-301〜305）を完了記録
  - 対象: WORKFLOW/TOOLING/COEXIST_3FILES.md / TOOLING/ADAPTERS/*.template.md / CLAUDE.md / AGENTS.md / GEMINI.md / 旧引継ぎ文書（当時の運用） / _handoff_check/task_tracker.md
  - タスクID: STEP-301, STEP-302, STEP-303, STEP-304, STEP-305（Done=[x]）
  - 証跡: PR#8（https://github.com/xxxMasahiro/cf-context-framework/pull/8） / merge: 27459ca / commits: 2154ebe, d77aec7

- 2026-01-17 | UPD-20260117-03 | 3指針ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）差分確認：共存整合を確認 | 証跡: diff -u CLAUDE.md AGENTS.md / diff -u AGENTS.md GEMINI.md（差分は目的・役割・参考テンプレのみ、運用ルール/統一必須文言は一致）

- 2026-01-18 | UPD-20260118-01 | Gate 0: STEP-004 リモート確認を完了（チェック反映 + 証跡追記）
  - 対象: _handoff_check/task_tracker.md
  - タスクID: STEP-004
  - 証跡: `git remote -v`
    ```
    origin  github-masahiro:xxxMasahiro/cf-context-framework (fetch)  ← 当時名称（2026-01-18 時点の歴史的記録）
    origin  github-masahiro:xxxMasahiro/cf-context-framework (push)   ← 当時名称（2026-01-18 時点の歴史的記録）
    ```
  - 変更点: STEP-004 の Done を [ ]→[x] / 更新ログに本エントリを追記

- 2026-01-18 | UPD-20260118-02 | Gate 0: STEP-005 展開先とファイル一覧を記録（チェック反映 + 証跡追記）
  - 対象: _handoff_check/task_tracker.md
  - タスクID: STEP-005
  - 証跡: UNPACK_DIR + `ls -la _handoff_check`
    ```
    UNPACK_DIR=/home/masahiro/projects/context-framework/_handoff_check
    total 56
    drwxr-xr-x  2 masahiro masahiro  4096 Jan 17 22:10 .
    drwxr-xr-x 10 masahiro masahiro  4096 Jan 18 05:52 ..
    -rwxr-xr-x  1 masahiro masahiro  6049 Jan 17 17:08 handoff_prompt.md
    -rwxr-xr-x  1 masahiro masahiro 22288 Jan 18 05:31 task_tracker.md
    -rwxr-xr-x  1 masahiro masahiro 13767 Jan 17 17:08 update_runbook.md
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
  - 証跡: _handoff_check/task_tracker.md（STEP-103 [x], Evidence: WORKFLOW/TOOLING/COEXIST_3FILES.md）
- 2026-01-18 | UPD-20260118-05 | Gate A: STEP-104 Skills統合方針（SKILLS_INTEGRATION）を格納完了 | 証跡: 6addee1 / WORKFLOW/SKILLS_INTEGRATION.md
- 2026-01-18 | UPD-20260118-07 | Gate A: STEP-106 完了。呼び出しフレーズ（SKILL: ...）とArtifacts書き戻し規則を WORKFLOW/SKILLS_INTEGRATION.md に追記。Evidence: 921dbe5

## Progress Log/Updates
- 2026-01-25T23:57:27+09:00 | UPD-20260125-05 | Gate G: STEP-G007 Signature集計ツール（候補検出）をDone更新 | Done[x] | Evidence: PR #59 / merge 795d53f / topic bc0a5c7
  - 対象: _handoff_check/task_tracker.md(L390-L418) / tools/signature-report.sh(L1-L95)

- 2026-01-25T22:23:20+09:00 | UPD-20260125-04 | Gate G: STEP-G006 定義固定（Concrete→Abstract→Skills）をDone更新 | Done[x] | Evidence: PR #57 / merge 6305b49 / topic 1a1f3eb
  - 対象: _handoff_check/task_tracker.md(L389-L403) / WORKFLOW/SKILLS_INTEGRATION.md(L115-L120)
- 2026-01-25T17:52:33+09:00 | UPD-20260125-03 | Gate G: STEP-G005 受入テスト（チェック項目）を定義として追記 | Done[x] | Evidence: PR #54 / merge f14ec13 / topic 69aad10 / _handoff_check/task_tracker.md:L390-L395
- 2026-01-25T14:05:42+0900 | UPD-20260125-02 | Gate G: STEP-G201〜G204 をDone更新（Skills導線/昇格条件/受入テスト/監査観点） | Evidence: WORKFLOW/SKILLS_INTEGRATION.md / WORKFLOW/AUDIT.md / commit 97535ef
- 2026-01-25T11:27:33+09:00 | UPD-20260125-01 | Gate G: STEP-G104 受入テスト（同種2回→パターン吸収）PASS → Done[x] | Evidence: procedure-mismatch / _handoff_check/update_runbook.md（パッチ事故防止） / HEAD=637b0db
- 2026-01-24T19:10:00+09:00 | UPD-20260124-07 | Gate G: STEP-G103 新カテゴリ追加ルール（Go/No-Go）必要と判定 →Done[x] | Evidence: Repo Lock OK / SSOT参照 / 判定=必要

- 2026-01-24T18:41:29+09:00 | UPD-20260124-06 | Gate G: STEP-G102 パターン分類案（最小セット）を追記 → Done[x] | Done[x]
  - Evidence: Gate G Phase2: パターン分類案（reference-miss/generation-gap/permission-block/connectivity-issue/procedure-mismatch/state-divergence）
- 2026-01-24T18:20:11+09:00 | UPD-20260124-05 | Gate G: STEP-G101 固定カテゴリ案（最小セット＋OTHER）を追記 → Done[x] | Done[x]
  - Evidence: Gate G Phase2: 固定カテゴリ案（git/tooling/docs/workflow/log-index + OTHER）
- 2026-01-24T17:01:43+09:00 | UPD-20260124-04 | Gate G: STEP-G005 受入テスト（失敗→抽象→具体→解決策）PASS → Done[x] | Done[x]
  - Evidence: LOG-007 / LOGS/INDEX.md / _handoff_check/update_runbook.md:8.1
- 2026-01-24T12:45:00+09:00 | UPD-20260124-03 | Tools: ブランチ掃除スクリプト追加（安全版/強い版） | Done[x]
  - Evidence: PR #47（merge: f6d5c7c）
- 2026-01-24T12:17:00+09:00 | UPD-20260124-02 | Gate G: STEP-G004 判定（追記不要：runbook に既記載）→ Done[x] | Done[x]
  - Evidence: _handoff_check/update_runbook.md:L80 / STEP-G004 [x]（L387）
- 2026-01-24 | UPD-20260124-01 | Gate G: STEP-G003 抽象ログ（索引）仕様合意 | Done[x] | Evidence: LOG-009（L689）/ STEP-G003 [x]（L386）
- 2026-01-23T12:49:00+09:00 | UPD-20260123-02 | Gate G: STEP-G002 具体ログ最小テンプレ合意 → Done[x] | Done[x]
  - Evidence: LOG-008（L663）/ STEP-G002 [x]（L385）
- 2026-01-23T07:13:35+09:00 | UPD-20260123-01 | Gate G: STEP-G001 現状棚卸しを Done 更新（Concrete/Abstract/検索導線/証跡確定） | Done[x]
  - Evidence: LOG-007（L454）/ STEP-G001 [x]（L384）
- 2026-01-22T20:48:32+09:00 | UPD-20260122-05 | Gate G（ログ運用95%効率化）のタスク設計を追加 | Done[x]
  - 対象: _handoff_check/task_tracker.md / LOGS/INDEX.md
  - Evidence: commit 9f3e5a7
- 2026-01-22T16:39:13+09:00 | UPD-20260122-04 | ログ索引生成ツール導入（tools追加＋LOGS/INDEX.md生成＋runbook注記） | Done[x]
  - 対象: tools/log-index.sh / LOGS/INDEX.md / _handoff_check/update_runbook.md / _handoff_check/task_tracker.md
  - Evidence: commit d404554
- 2026-01-22T15:07:03+09:00 | UPD-20260122-03 | WORKFLOW/MODES_AND_TRIGGERS.md に runbook 4.1 参照を1行追記（衝突時の意思決定の導線） | Done[x]
  - 対象: WORKFLOW/MODES_AND_TRIGGERS.md / _handoff_check/task_tracker.md
  - Evidence: commit f87c622
- 2026-01-22T11:37:00+09:00 | UPD-20260122-02 | runbook 4.1 に「衝突時の意思決定」1行追記 | Done[x]
  - 対象: _handoff_check/update_runbook.md / _handoff_check/task_tracker.md
  - Evidence: commit 554ed36
- 2026-01-22T11:37:00+09:00 | UPD-20260122-01 | PR #31: .gitignore にローカル初期設定ファイル除外を反映 / SSOT 3ファイルへ反映 | Done[x]
  - 対象: _handoff_check/handoff_prompt.md / _handoff_check/update_runbook.md / _handoff_check/task_tracker.md
  - Evidence: PR #31（merge: ee5c074 / commit: 8f06dcc）/ Repo Lock: OK / main==origin/main / working tree clean
- 2026-01-21T18:11:10+09:00 | UPD-20260121-04 | Gate B: next3_work (Skills統合) をDone更新 (PR #30) | Done[x]
  - 対象: _handoff_check/task_tracker.md
  - Evidence: PR #30 (merge: ef0791c / commit: f99300f)
- 2026-01-21T15:27:47+09:00 | UPD-20260121-03 | Gate F: SSOT 3ファイル表記の統一と証跡更新（STEP-507〜512） | Done[x]
  - 対象: _handoff_check/handoff_prompt.md / _handoff_check/update_runbook.md / _handoff_check/task_tracker.md
  - Evidence: PR#28（merge: 18edacb / commit: 463b277）
- 2026-01-21 | UPD-20260121-02 | Gate F: 役割固定の撤廃と初期設定導入（STEP-507〜512） | Done[x]
  - 対象: `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` / `TOOLING/ADAPTERS/*.template.md` / `.repo-id/agent_role_assignment.example.yaml` / `WORKFLOW/TOOLING/INITIAL_SETTINGS.md` / `WORKFLOW/TOOLING/COEXIST_3FILES.md` / `_handoff_check/update_runbook.md` / `_handoff_check/handoff_prompt.md`
  - Evidence: `rg -n "INITIAL_SETTINGS.md" CLAUDE.md AGENTS.md GEMINI.md` / `rg -n "Repo Lock" _handoff_check/update_runbook.md`
- 2026-01-21 | UPD-20260121-01 | Repo Lock 導入（fingerprint/guard/runbook/handoff prompt） | Done[x]
  - 対象: `.repo-id/repo_fingerprint.json` / `tools/guard.sh` / `WORKFLOW/TOOLING/REPO_LOCK.md` / `_handoff_check/update_runbook.md` / `_handoff_check/handoff_prompt.md`
  - Evidence: `./tools/guard.sh --check`
- 2026-01-20 | UPD-20260120-01 | 引継ぎ簡略運用へ切替（旧引継ぎ文書不使用） | Done[x]
  - 対象: _handoff_check/update_runbook.md / _handoff_check/task_tracker.md
- 変更点: 新チャット添付は3ファイルのみ / SSOT最上位はrunbook・trackerは進捗 / 引継ぎテンプレ統一
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
- 2026-01-19 | UPD-20260119-05 | Gate D: STEP-407 SKILL-LOG 証跡確認 | Done[x] | Evidence: _handoff_check/task_tracker.md（SKILL-LOG-001/002: L170,L188）
- 2026-01-19 | UPD-20260119-06 | STEP-505 最終整合チェック PASS | Done[x] | Evidence: commit 5f2a393

- 2026-01-20 02:57 +0900 | STEP-506 | CHANGELOG.md の ## Unreleased にリリースメモを追記して完了（Unreleasedの1行置換）。Evidence: git diff -- CHANGELOG.md / tracker STEP-506 が [x]

- 2026-01-20 | UPD-20260120-PR25 | PR#25 merged: PR後の後処理を「ガード付きで一括提示してよい」例外を追加 | Done [x]
  - 対象: `_handoff_check/task_tracker.md` / `_handoff_check/update_runbook.md`
  - Evidence: PR #25 (merged) / commit eb6fc91 / merge 8d888ab

### LOG-008｜Gate G（STEP-G002）具体ログの最小テンプレ合意

- 日時: 2026-01-23（JST）
- 目的: 具体ログ（LOG-XXX）の最小要素を統一し、抽象索引（LOGS/INDEX.md）から辿れるようにする

- 合意した最小テンプレ（Concrete）
  - ID: LOG-XXX（連番・一意）
  - 状態: WIP | Done | Blocked
  - カテゴリ: 短いトークン（例: git / tooling / docs / workflow / log-index / gate-g）
  - 症状: 観測事実（何が起きたか）
  - 原因: 根因 or 仮説（不明なら不明と明記）
  - 対処: 実施内容（コマンド/変更点/判断）
  - 証跡: PR/commit/ファイルパス/行番号/ログID（再現・追跡できる形）
  - 検索導線: Ref: rg -n "LOG-XXX" _handoff_check/task_tracker.md

- 実行コマンド（抜粋）
  - ./tools/guard.sh --check
  - ./tools/guard.sh -- git status -sb
  - ./tools/guard.sh -- git switch -c wip/gate-g-stepg002
  - python3（STEP-G002 行の [ ]→[x] 更新）

- 実行結果（確定事項）
  - STEP-G002: [x]
  - Evidence: LOG-008 / LOGS/INDEX.md
  - 変更区分: Mod（表行更新） / Add（本LOG-008節）

### LOG-009｜Gate G（STEP-G003）抽象ログ（索引）仕様合意

- 対象: LOGS/INDEX.md（Generated）
- 仕様（合意）:
  - 抽象索引は「カテゴリ → パターン → 具体ID」の導線を提供する
    - カテゴリ: UPD / LOG / SKILL-LOG
    - パターン: ID接頭辞+採番規則（例: LOG-### / SKILL-LOG-### / UPD-YYYYMMDD-##）
    - 具体ID: 規範（根拠）は runbook（_handoff_check/update_runbook.md）、記録は tracker（進捗）。INDEX は tracker へリンクする
  - 「ID検索を正」:
    - まず runbook（LOG-009規定）を確認し、ID検索は tracker を `rg -n "<ID>" _handoff_check/task_tracker.md` で検索して到達する（INDEXは補助ナビ）
  - 生成物運用:
    - tracker の LOG/UPD/SKILL-LOG を更新したPRでは `tools/log-index.sh` を再実行し、同一PRで LOGS/INDEX.md を更新する
- Evidence:
  - _handoff_check/update_runbook.md（LOGS/INDEX.md は生成物 / 同一PR更新の規定）
  - LOGS/INDEX.md（Generated）
- 変更区分: Mod（STEP-G003 表行更新） / Add（本LOG-009節） / Mod（LOGS/INDEX.md 再生成）

---

## 9. Docs MCP（読み取り専用）導入手順（Phase 2 / H10）

### 目的
- 仕様/ドキュメント参照の精度向上（読み取り専用）。
- **必須依存にしない**（MCPなしでもPhase 1が成立する前提）。

### 前提（安全）
- 読み取り専用（外部API代理呼び出しなし）。
- 最小権限・allowlist前提・ネットワークは最小化。

### 手順（例）
```bash
codex mcp add openaiDeveloperDocs --url https://developers.openai.com/mcp
codex mcp list
```

### config.toml 例（任意）
```toml
[mcp_servers.openaiDeveloperDocs]
url = "https://developers.openai.com/mcp"
```

### 運用上の注意
- 参照用途のみ（書き込みや外部送信の自動化はしない）。
- ツールの利用はログ/根拠に残す（参照元を明示）。

---

## 10. 用途別ツールMCP（STDIO）設計（Phase 2 / H11）

### 目的
- LLM側の**参照/要約/差分抽出**を補助する（Controllerが最終判断）。
- **必須依存にしない**（MCP無しでもPhase 1が成立する前提）。

### 前提（安全）
- 読み取り専用・任意実行禁止。
- パスは allowlist のみ、出力サイズ/タイムアウトを制限。
- ネットワークは既定OFF（必要時のみ明示的に許可）。

### ツール一覧（最小）
1) `get_ssot_bundle(profile)`
   - in: `{ "profile": "ssot_only|ssot_charter|full" }`
   - out: `{ "bundle": "...", "sources": ["path#Lx-Ly", ...] }`
2) `diff_summary(base, head)`
   - in: `{ "base": "commit|path", "head": "commit|path" }`
   - out: `{ "files": ["..."], "summary": "...", "risk_flags": ["..."] }`
3) `validate_agent_adapters()`
   - out: `{ "ok": true|false, "checks": {...}, "details": {...} }`
（任意）`read_file_excerpt(path, range)`：allowlist内のみ／サイズ制限必須

### エラー方針
- 失敗時は **安全停止**（exit code ≠ 0 / stderr に理由）。
- 失敗理由と根拠（どの入力/どの制限）を返す。

### ログ方針
- tool名・引数・結果要約・参照ファイル・ハッシュを記録。
- LLM側の利用記録は根拠に残す（Controllerが判断）。

### 互換性/拡張
- ツール追加は「用途固定・読み取り中心」だけ。
- 出力スキーマは後方互換を維持（既存キーは保持）。

---

## 11. CI/ログ整備（Phase 3 / H12）

### 目的
- ルール/スキーマ/スモークを **毎回CIで検証** し、結果ログを回収する。

### 実行（ローカル/CI共通）
- `./tools/ci-validate.sh`（rules/manifest/routes/policy の整合 + smoke）

### CI（GitHub Actions）
- `.github/workflows/ci-validate.yml` を実行し、`LOGS/ci/*.log` を artifact 回収。

### 運用上の注意
- 生成ログは SSOT へは混ぜない（LOGS/ 配下に残す）。
