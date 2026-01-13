# WORKFLOW / BRANCHING

## 目的
PRを使わない代わりに、ブランチとコミット規律で “レビュー可能性” を確保します。

## ルール
- main直コミット禁止
- 作業は `wip/v0.1.4`
- Gate A/B/C でコミットを切る
- 破壊的変更は必ず `CHANGELOG.md` に記録

## 推奨：コミットメッセージ例
- `gate(A): ...`
- `gate(B): ...`
- `gate(C): ...`
- `docs: ...`（軽微な文言修正）
- `refactor: ...`（構成整理）
