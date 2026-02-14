# Task Lists（タスクリスト / Antigravity準拠）
> 目的：Antigravityの主要アーティファクト
> **Task Lists / Implementation Plan / Walkthrough** を「標準機能」として取り込み、
> フレームワークを完成できる状態にする（失敗しない開発のための改良）。

## 1. ゴール（1行）
- Antigravity 3点セットを内包したフレームワークを完成させる（= core へ追加＋参照更新＋メタ整合）。

## 2. スコープ
### In scope（やる）
- Core（v0.1.3 → v0.1.4）
  - テンプレ3点追加（Task Lists / Implementation Plan / Walkthrough）
  - 参照（ARTIFACTS, artifacts/README, roles）更新
  - VERSION / CHANGELOG / _meta（BUILD_INFO, MANIFEST, REPO_TREE, CHECKSUMS）更新
- Sample Product（v0.1.1 → v0.1.2）
  - `workframe/core` に同様の取り込み
  - ルートVERSION/CHANGELOG/WORKFRAME_MANIFEST/_meta更新
- Dist を v0.1.4 として再生成

### Out of scope（やらない）
- `cf-business-pack` の内容変更
- `cf-wf-starter` の中身（.keepのみ）変更
- Lite/Standard/Strict の運用定義は `../WORKFLOW/MODES_AND_TRIGGERS.md` を参照

## 3. 制約（安全のためのルール）
- **リネーム/移動は原則しない**（追加＋最小修正）
- "証跡（diff/ログ/チェックサム）" を必ず残す
- 1PR=1目的（Core取り込み / SampleProduct追随 / Dist再生成で分割推奨）

## 4. タスク分割（順序付き）
1. 作業準備：作業ディレクトリ作成、Gitブランチ作成
2. Core更新（v0.1.4化）
   - テンプレ3点追加
   - 参照更新（ARTIFACTS/README/roles）
   - VERSION/CHANGELOG/_meta更新
3. Sample Product更新（v0.1.2化）
   - `workframe/core` を v0.1.4 と整合
   - ルート VERSION/CHANGELOG/WORKFRAME_MANIFEST/_meta更新
4. Dist再生成（v0.1.4）
   - business-pack, starter は旧版をそのまま同梱
5. 検証（必須）
   - 追加ファイルが存在する（core）
   - 参照ドキュメントからリンクされている
   - 役割定義に成果物として載っている
   - `_meta/CHECKSUMS.sha256` が再生成され整合している
   - `VERSION / CHANGELOG / _meta/BUILD_INFO.json / _meta/MANIFEST.yaml` が更新されている

## 5. Doneの定義（合格条件）
- v0.1.4 成果物が生成できる
- 主要コマンドログ（実行履歴）と `sha256sum` の証跡が残っている

## Profile / Triggers
- 定義：`../WORKFLOW/MODES_AND_TRIGGERS.md`
- Profile:
- Triggers: Yes | No
- Reason:

## 6. GO/NO-GO（レビューゲート）
- Gate A：Task Lists（本書）レビュー完了
- Gate B：Implementation Plan レビュー完了（変更点の合意）
- Gate C：Walkthrough の検証手順で "全項目OK" を確認
- Gate D：監査結果（`ARTIFACTS/AUDIT_REPORT.md` / `ARTIFACTS/AUDIT_CHECKLIST.md`）を確認

## 記載ルール（Apply Skill）

- TASK_LISTS 内で Skills（手順モジュール）を使って進めた場合、該当タスクの直下（またはチェック項目の末尾）に **次の1行**を追記する。
  - `Apply Skill: SKILLS/<skill_file>.md`
- Skills を複数使う場合は **1行ずつ列挙**する。
- 表記は **`Apply Skill:` を固定**し、grep で機械検索できるようにする（大文字小文字・コロン含め固定）。
- **No-op の場合は記載しない**（Skills を実行していないため）。
- 例:
  - `Apply Skill: SKILLS/skill-001.md`
- 具体的な書き方は `WORKFLOW/TRANSLATION_LAYER.md` を参照する。
