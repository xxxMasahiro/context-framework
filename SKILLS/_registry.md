# SKILLS レジストリ（Skill一覧）

## 目的
- このリポジトリに存在する Skills（再利用可能な手順）を一覧し、発見性と運用の一貫性を高める。
- Skills の実行手段（Claude Code/Codex/GUI/CLI など）は adapters 側へ分離し、ここでは「Skillの定義（目的/入出力/手順/検証/証跡）」の所在を管理する。

## 使い方（更新ルール）
- 新しいSkillを追加したら、この表に1行追記する（既存行は原則変更しない）。
- 参照の正は SSOT（Charter → Mode → Artifacts → Skills）に従う。

## 一覧

| Skill ID | Skill名 | Path | 対象サービス | 実行手段(adapters) | Inputs | Outputs | 検証/証跡 | 状態 | Notes |
|---|---|---|---|---|---|---|---|---|---|
| (例) SKILL-001 | （例）監査テンプレ生成 | SKILLS/skill-001.md | GitHub | TOOLING/ADAPTERS/* | PR/commit | ARTIFACTS/AUDIT_* | commit hash / diff | Draft | 例 |
