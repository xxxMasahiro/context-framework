# WORKFLOW / TOOLING / COEXIST_3FILES

## 目的
- `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` の共存ルールを明確化し、運用アダプタとして扱う
- SSOT（唯一の正）を **context-framework 側**に固定し、重複記述を避ける

## SSOT（唯一の正）
- 優先順位: **Charter → Mode → Artifacts → Skills**
- 参照先（実ファイル）:
  - Mode: `../MODES_AND_TRIGGERS.md`
  - Gate運用: `../GATES.md`
  - 監査運用: `../AUDIT.md`
  - ブランチ運用: `../BRANCHING.md`
  - Artifacts: `../../ARTIFACTS/TASK_LISTS.md`, `../../ARTIFACTS/IMPLEMENTATION_PLAN.md`, `../../ARTIFACTS/WALKTHROUGH.md`
  - 監査Artifacts: `../../ARTIFACTS/AUDIT_REPORT.md`, `../../ARTIFACTS/AUDIT_CHECKLIST.md`, `../../ARTIFACTS/EXCEPTIONS.md`

## 3ファイルの位置づけ（運用アダプタ）
- `CLAUDE.md` / `AGENTS.md` / `GEMINI.md` は **SSOTではない**
- 各AIエージェントに **直接渡す運用アダプタ**として使う
- 詳細本文の複製は避け、**参照リンク中心**で運用する

## 役割対応（参考）
| エージェント | 対応ファイル | 参考例（固定しない） |
|---|---|---|
| Claude Code | `CLAUDE.md` | 例: Crafter |
| OpenAI Codex | `AGENTS.md` | 例: Orchestrator / Crafter |
| Google Antigravity / Gemini系 | `GEMINI.md` | 例: Architect / Auditor |

## 役割の割当（初期設定）
- 役割は固定しない。Developer が初期設定ファイルで割り当てる。
- 参照: `WORKFLOW/TOOLING/INITIAL_SETTINGS.md`
- 設定例: `.cfctx/agent_role_assignment.example.yaml`

## 統一必須文言（運用上の固定）
**AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**

## ブランチ運用（main直push禁止）
- 変更は `wip/<version>` で作業し、PR経由で `main` へ反映する
- 理由: 事故防止と証跡（レビュー/監査ログ）確保のため
- 詳細: `../BRANCHING.md`

## テンプレ
- `../../TOOLING/ADAPTERS/CLAUDE.template.md`
- `../../TOOLING/ADAPTERS/AGENTS.template.md`
- `../../TOOLING/ADAPTERS/GEMINI.template.md`

## 記載方針（必須）
- SSOTの本文を書き写さない
- 参照リンク、I/O契約、禁止事項、起動チェックを中心にする
- 変更時は「追加/削除/修正」を明示する
