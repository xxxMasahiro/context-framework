# CLAUDE.md テンプレ（運用アダプタ）

## 目的
- Claude Code に **直接渡す運用アダプタ**として使う
- SSOT（唯一の正）は cf-context-framework 側に固定する

## 役割（固定しない）
- このテンプレは Claude 向け入口（読み込み必須）であり、役割は固定しない
- 役割は Developer が初期設定ファイルで割り当てる
- 初期設定（共通参照先）:
  - ../../WORKFLOW/TOOLING/INITIAL_SETTINGS.md
  - ../../.cfctx/agent_role_assignment.example.yaml
- 役割の行動規範は SSOT（Charter → Mode → Artifacts → Skills）に従う

### 役割一覧（一般的な説明）
- Architect: 設計・整合性の前段チェックを担う場合がある
- Crafter: 実装（追加/修正/削除）を担う場合がある
- Orchestrator: タスク分解・横断調整・進行管理を担う場合がある
- CI/QA: 検証・ログ化・再現性の担保を担う場合がある
- Auditor: 監査・証跡・リスク指摘を担う場合がある（実装はしない）

## SSOT参照順（唯一の正）
- Charter → Mode → Artifacts → Skills
- 参照先（実ファイル）:
  - `../../WORKFLOW/MODES_AND_TRIGGERS.md`
  - `../../WORKFLOW/GATES.md`
  - `../../WORKFLOW/AUDIT.md`
  - `../../WORKFLOW/BRANCHING.md`
  - `../../ARTIFACTS/TASK_LISTS.md`
  - `../../ARTIFACTS/IMPLEMENTATION_PLAN.md`
  - `../../ARTIFACTS/WALKTHROUGH.md`
  - `../../ARTIFACTS/AUDIT_REPORT.md`
  - `../../ARTIFACTS/AUDIT_CHECKLIST.md`
  - `../../ARTIFACTS/EXCEPTIONS.md`
  - `../../WORKFLOW/TOOLING/COEXIST_3FILES.md`

## やること
- SSOTを参照し、指示は1手ずつ出す
- 変更点は追加/削除/修正を明示する
- 実行コマンドの意味（復習用）を添える

## やらないこと
- SSOTの再定義や本文の複製
- main への直接反映（PRなし）

## 証跡・出力形式
- 変更ファイル一覧（Addのみが原則）
- 追加/削除/修正の要約（箇条書き）
- `git diff` もしくは同等の差分

## ブランチ運用
- 作業は `wip/<version>` で実施し、PRで `main` へ反映する
- 理由: 事故防止・証跡確保

## チェックリスト
- [ ] SSOT参照順を守っている
- [ ] 参照リンク中心で、重複記述を避けている
- [ ] 変更点の種類（追加/削除/修正）を明示した

## 統一必須文言
**AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。**
