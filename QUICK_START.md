# QUICK_START

このフレームワークをそのまま **新規リポジトリ**として使う前提です。

## 1) リポジトリ作成（PR経由運用）

```bash
mkdir cf-dist-v0.1.4-work
cd cf-dist-v0.1.4-work
# ここにこのZIPを展開
git init
git checkout -b main
git add .
git commit -m "chore: bootstrap context framework (v0.1.4)"
git checkout -b wip/v0.1.4
```

## 2) 最初の作業手順

1. `ARTIFACTS/TASK_LISTS.md` を開く  
2. Gate A を埋める（今回の作業範囲を確定）
3. あなた（Developer）が GO  
4. `PROMPTS/CODEX_CRAFTER.md` を Codex に貼って実装開始  
5. `PROMPTS/CODEX_CIQA.md` を Codex に貼って検証  
6. Gate C が通ったら main に反映（PR経由でマージ）

## 3) 入力ZIP（v0.1.3）について

このZIPに同梱済みです：
- `vendor/inputs/cf-dist_v0.1.3_complete.zip`

## 4) 成果物ZIPを作るとき

最終的な `cf-dist_v0.1.4_complete.zip` の生成手順は、必ず
`ARTIFACTS/WALKTHROUGH.md` に集約していきます（ここが“再現性”の核です）。
