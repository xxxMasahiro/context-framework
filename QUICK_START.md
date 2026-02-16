# QUICK_START

このフレームワークをそのまま **新規リポジトリ**として使う前提です。

## 1) リポジトリ作成（PR経由運用）

```bash
git clone <repository-url> context-framework
cd context-framework
git checkout -b wip/<作業名>
```

## 2) 最初の作業手順

1. `ARTIFACTS/TASK_LISTS.md` を開く
2. Gate A を埋める（今回の作業範囲を確定）
3. あなた（Developer）が GO
4. `PROMPTS/CODEX_CRAFTER.md` を Codex に貼って実装開始
5. `PROMPTS/CODEX_CIQA.md` を Codex に貼って検証
6. Gate C が通ったら main に反映（PR経由でマージ）
