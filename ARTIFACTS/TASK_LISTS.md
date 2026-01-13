# Task Lists (Working)

> ベースライン手順書：`vendor/.../extracted/artifacts/` を参照（原則不変）

## 0. Goal
- `cf-dist_v0.1.4_complete.zip` を作れる状態にする（3主要アーティファクト内包）

## 1. Scope (このサイクルでやること)
- [ ] 手順書ZIPのベースライン確認（ファイル構造・意図）
- [ ] v0.1.4 完全版に含めるべきファイル/配置を確定
- [ ] 参照関係（README, DOCS_INDEX, _meta）を整合
- [ ] Walkthrough を “一発で再現できる” 形に更新

## 2. Out of scope (やらないこと)
- [ ] コード実装（アプリ開発）
- [ ] GitHub PR運用（今回はやらない）

## 3. Done Definition
- [ ] Gate B の Implementation Plan が“ファイル単位で差分”になっている
- [ ] Gate C の Walkthrough で、手順どおりに `cf-dist_v0.1.4_complete.zip` が生成できる
- [ ] 生成物の中身が 3主要アーティファクトに準拠している
- [ ] 変更点が `CHANGELOG.md` と Walkthrough に残っている

## 4. Risks / Notes
- 手順書（vendor側）を勝手に改変しない
- “どのファイルをどこへ置くか” が最大の事故ポイント（必ずPlanで固定）
