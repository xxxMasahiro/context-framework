# WORKFLOW / SKILLS_INTEGRATION

## 1. 目的
- Skills統合の方針を「唯一の正」として固定し、運用のぶれを防ぐ
- ツール非依存の手順を再利用可能にし、再現性と監査性を高める

## 2. 位置づけ（SSOTの優先順位）
- **Charter → Mode → Artifacts → Skills**
- Skillsは上位方針に従属し、上位の定義を上書きしない

## 3. Skillsの定義（何をSkillsと呼ぶか／呼ばないか）
- Skillsと呼ぶもの:
  - 繰り返し実行される手順を、目的・前提・入力・出力・検証まで含めて再利用可能にしたもの
  - 変更内容がArtifactsに書き戻され、証跡が残るもの
- Skillsと呼ばないもの:
  - その場限りの作業メモ
  - 特定ツールの操作だけに依存する手順（共通化されていないもの）
  - 上位方針（Charter/Mode/Artifacts）を再定義する文書

## 4. 統合の原則
- **ツール非依存**: 中核手順は特定ツールに依存しない
- **再利用**: 入力と出力が明確で、他案件でも同じ形で使える
- **再現性**: 手順と検証が再実行可能で、結果の差分が追跡できる
- **粒度**: 1技能=1目的で完結し、Artifactsへ書き戻せる粒度にする

## 5. ツール依存の扱い（adapters分離のルール）
※ここでいう「ツール非依存」とは、対象サービス（例：Supabase/Stripe）への依存は許容しつつ、実行手段（例：Claude Code/Codex/Google Antigravity/GUI/CLI）に依存する手順は adapters に分離する、という意味である。

- Skills（共通）と adapters（ツール固有）を分離する
- **3ファイル（CLAUDE.md / AGENTS.md / GEMINI.md）はSSOTではなく運用アダプタ**として扱う

### 境界基準（箇条書き）
- Skills（共通）に含める:
  - 目的、前提、入力、出力、手順、検証、ロールバック
  - Artifactsへの書き戻し方法（Task Lists / Implementation Plan / Walkthrough への反映）
  - 監査に必要な証跡の種類
- adapters（ツール固有）に含める:
  - ツール固有の操作手順（UI/CLI/拡張機能/プロンプト形式）
  - 実行環境の差分（権限、設定、コマンド実行方法）
  - 出力フォーマットの違い（ログ形式、添付方法）

## 6. 参照関係（関連ファイルの置き場所）
- 3ファイル共存ルール: `WORKFLOW/TOOLING/COEXIST_3FILES.md`
- adaptersの置き場（将来追加前提）: `WORKFLOW/TOOLING/ADAPTERS/`
- Skillsの置き場（推奨）: `/SKILLS/`
- テンプレの置き場（推奨）: `/SKILLS/skill-template/`

## 7. 運用フロー（作成/更新/レビュー）
- 作成:
  - 目的と出力を固定し、手順と検証を最小限で定義する
- 更新:
  - 変更点（追加/削除/修正）を明示し、Artifactsへの影響を記録する
- レビュー:
  - 上位方針との整合（Charter/Mode/Artifacts）
  - ツール非依存性の維持（adaptersへの分離）
  - 再現性（検証手順と証跡の妥当性）

### 7.1 呼び出しフレーズ（固定）
- Skillを適用する指示は、必ず次の1行で開始する（grepしやすくするため）:
  - `SKILL: <Skill名 or SkillID>`
- 続けて、最低限のパラメータを箇条書きで付す（不足は“推測しない”で追記要求する）:
  - `Mode: <lite|standard|strict>`
  - `Target: <対象/範囲/成果物>`
  - `Inputs: <参照すべきArtifacts/Evidence>`
  - `Expected: <期待する出力/Done条件>`
  - `Evidence: <証跡の置き場所/種類>`
- 実行手段（Claude Code/Codex/Google Antigravity/GUI/CLI 等）に依存する手順は、adapters側へ分離し、Skill本文には“原理と検証”のみ残す

### 7.2 Artifactsへの書き戻し規則（固定）
- Skill実行後、結果は必ずArtifactsへ書き戻す（Skillドキュメント単体で完結させない）
- 書き戻し先の優先順位（SSOT優先度を維持）:
  1. `ARTIFACTS/TASK_LISTS.md`：該当タスクの [ ]→[x] と Evidence
  2. `ARTIFACTS/IMPLEMENTATION_PLAN.md`：手順/設計が更新された場合のみ追記
  3. `ARTIFACTS/WALKTHROUGH.md`：実行手順・判断・検証・証跡を追記（再現可能性の担保）
  4. `ARTIFACTS/AUDIT_REPORT.md` / `ARTIFACTS/AUDIT_CHECKLIST.md`：監査観点に影響が出た場合のみ追記
  5. `ARTIFACTS/EXCEPTIONS.md`：例外運用が必要になった場合のみ追記
- Artifactsへ追記する最低要件（テンプレ）:
  - 変更点（Add/Del/Mod）
  - Skill呼び出しフレーズ（`SKILL: ...`）
  - 実行者（Crafter / Orchestrator / CIQA / Auditor）
  - Evidence（commit hash / diff / logs / checksums 等）
  - 実行手段に依存する詳細がある場合は adapters への参照（本文へ埋め込まない）

## 8. 例（2つだけ）
- 良い例（ツール非依存のSkills）:
  - 「外部API連携の追加」：前提/入力/出力/検証まで共通化し、実行方法はadaptersに分離
- 境界例（手順の一部がツール依存）:
  - 「CLIでのデプロイ」：共通の目的と検証はSkillsに残し、CLIコマンドや環境差分はadaptersへ分離

## 9. チェックリスト（最小条件）
- [ ] SSOT優先順位が明記されている
- [ ] Skillsの定義と非対象が区別されている
- [ ] ツール依存の境界基準が箇条書きで示されている
- [ ] 3ファイルがSSOTではなく運用アダプタであることと矛盾しない
- [ ] 参照関係と推奨配置が明記されている
- [ ] 作成/更新/レビューの運用フローがある
- [ ] 例が2つだけ示されている

## 10. Skillsへの導線（抽象→Skill）
- 入口の置き場（推奨）：`LOGS/INDEX.md` → Concrete/Skill へのリンク
- 参照の置き場：`SKILLS/_registry.md`（Skill一覧）
- 必要に応じて tracker からも参照してよい（重複は避け、リンクで誘導）
- 抽象に手順を全部書かず、**リンクで深掘り**する

## 11. Skill昇格条件（STEP-G201確定）
- 同種が2回以上出たら候補化
- 最低条件：tool非依存 / 再現可能 / 証跡あり / 入出力が定義できる
- 昇格時にやること：`SKILLS/_registry.md` 追加、必要ならログ/Artifactsへリンク追加

## 12. 受入テスト（入口→Skillに辿れる）（STEP-G204）
- `LOGS/INDEX.md` から1件 → `SKILLS/_registry.md` → Skill本文へ到達できる
- `SKILL:` 呼び出しフレーズが検索できる（例：`rg -n "SKILL:" SKILLS/ || true`）
- registry からリンク切れが無いこと（最低1件で確認）

