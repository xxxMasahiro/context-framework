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

## Repo Lock（作業開始前の必須チェック）

- 目的: リポジトリ取り違え防止（パス固定ではなく、Repo Fingerprint + Guard で判定する）。
- Repo Fingerprint: `.cfctx/repo_fingerprint.json` を同一性の正とする。
- Guard: `./tools/cf-guard.sh --check` で事前確認し、NGなら中止する。
- 破壊的操作（restore/reset/clean/rm など）は Guard 経由を推奨する。
- 詳細: `WORKFLOW/TOOLING/REPO_LOCK.md`

例:
```
./tools/cf-guard.sh --check
./tools/cf-guard.sh -- git status -sb
```

### バックアップ（STEP-006）作成の判断基準（運用ルール）

原則:
- バックアップは「上書き更新」しない。常に新規作成（証跡固定のため）。
- 標準は `git tag`（作業前タグ）。※zipバックアップは廃止。
- ディレクトリバックアップ（例: `../cf-context-framework_backup_YYYYMMDD[-HHMM]`）は、必要に応じて補助として併用してよい（証跡を残すこと）。

バックアップ作成を必須とするタイミング（いずれか該当で実施）:
- 広範囲の変更に入る前（大量編集/移動/削除、SSOT更新など）
- 事故りやすいGit操作の前（rebase/reset/履歴改変/大きめのマージ 等）
- Gateをまたぐ前後、または作業の大きな区切りの前後
- 「この時点に戻れないと困る」作業を始める前

命名規則（例）:
- git tag: `backup/YYYYMMDD-HHMM`（または `backup/YYYYMMDD`）
- directory: `../cf-context-framework_backup_YYYYMMDD-HHMM`

証跡（Evidence）:
- `cf_task_tracker_v5.md` の STEP-006 の Evidence に「tag名（またはバックアップ先パス）」を記録する
- 完了時は Progress Log/Updates に「日時・タスクID・証跡（tag名/パス）」を追記する


# cf-context-framework アップデート手順書（統合版 + Skills運用統合）
Version: draft-2026-01-16+skills

この手順書は、このチャットで確定した方針と、添付3ZIP（next1/next2/next3）の内容を統合し、**cf-context-framework 全体の整合性（Charter→Mode→Artifacts→Skills）を保ったままアップデートする**ための実行ランブックです。

> 進捗管理・証跡（Evidence）記録は、併設のタスク管理票 `cf_task_tracker_vN.md`（最新版） を使用します。

※最新版の判定: 作業フォルダ内の `cf_task_tracker_v*.md` のうち番号 N が最大のもの。新規作成時はその N+1 で作成します。
---

## 1. 目的とスコープ

### 1.1 目的
- **独立監査（Auditor）**を追加し、既存の Gate A/B/C に自然に接続（推奨：**Gate D**）。
- **3つの常駐指示ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）**を、単なる入口ではなく「各AIエージェントに直接渡せる運用アダプタ」として整備し、cf-context-framework と各エージェントの連携精度を上げる。
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

### 4.2 エージェント別「常駐指示ファイル」対応
| エージェント | 対応ファイル | 想定ロール例 |
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
- ただし「唯一の正」は cf-context-framework 側（Charter/Mode/Artifacts/Skills）。
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

- 1コマンド/1操作ずつ進め、都度ログ/結果（スクショ等）を残す
- 変更が入ったら必ず **追加/削除/修正** を明示
- コマンドを提示する場合、**そのコマンドの意味（復習用）**を必ず添える
- 軽微変更は手作業（開発者がCLI）、複雑変更はCrafter/Orchestrator主導（AIで実装）

### 8.1 例外：PR後の後処理を“まとめて提示”する場合（ガード付き一括手続きテンプレ）
この例外は、Developerが「PRタイトル/本文も提示し、PR/merge/branch削除/同期/prune/statusまで一括で指示して」と**明示要求**した場合のみ有効。

- main保護: **main は削除しない**
- ブランチの決め方:
  - 環境変数 `TOPIC_BRANCH` があればそれを使う
  - なければ「実行開始時のブランチ（start_branch）」を削除候補にする
- 削除条件: topic が main ではなく、**main にマージ済みのときのみ** `git branch -d`

```bash
# guard: Repo Lock（想定リポジトリ以外なら中止）
./tools/cf-guard.sh --check

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

## 9. アップデート手順（Gate運用で統合する）

### Phase 0：準備（作業ブランチ・現状固定）
- ブランチ：`wip/<version>`（例：`wip/v0.1.5`）
- 3ZIP展開・差分対象を洗い出し（Evidenceとして残す）

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
- Single Source of Truth: `cf_task_tracker_v5.md`
- 本文中に `cf_task_tracker_vN.md` / `cf_task_tracker_v4.md` 等の旧参照が残っていても、履歴として保持し、**最新は `cf_task_tracker_v5.md` を参照**する。

## 翻訳レイヤ（抽象→具体の戻り先）

- 迷ったらまず `WORKFLOW/TRANSLATION_LAYER.md` を参照する（憲章/Modeの原則を、Artifactsへ落とす if/then 判断手順）。
- Artifacts側の参照導線：`ARTIFACTS/TASK_LISTS.md` / `ARTIFACTS/WALKTHROUGH.md`
