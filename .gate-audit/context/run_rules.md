# Temporary Verification Kit - 運用ルール（run_rules）

このキットは Gate A〜I の横断検証を **安全（read-only中心）**に進め、証跡（Evidence）を残すためのもの。

## 1. 1手ずつ進める（最重要）
- 次にやることは常に「1つだけ」（1コマンド/1操作）。
- 実行者が結果を貼ってから次へ進む。
- 複数行が必要な場合でも「1回でコピペして実行できる1ブロック」にまとめる（= 1操作）。

## 2. 検索コマンドは必ず 0 終了
- `rg` / `grep` 等の「見つからなくてもOK」検索は **必ず `|| true`** を付ける。

## 3. 出力フォーマット
- 出力は常に **「根拠 / 判定 / 変更提案」** を守る。
- 判定は PASS/FAIL を明確に。

## 4. コピーブロック必須
- コピーが必要なコマンドや文面は、必ずコードブロックで提示する。

## 5. 既定は repo 外生成（安全側）
- 既定：`$GATE_AUDIT_ROOT/.gate-audit/`（repo外）
- `GATE_AUDIT_ROOT` 未設定は **FAIL**（中断）。
- repo 直下生成は **明示オプトイン時のみ**。

## 6. ロックダウン解除は二段階
- ロック状態：`LOCKED.flag` が存在する
- 解除：`LOCKED.flag` + 固定フレーズ **UNLOCK-VERIFY-KIT** が揃った場合のみ

## 7. handoff 出力の統一
- `->handoff` は原則 `scripts/generate_handoff.sh` を使用する。
- 出力源は `handoff/latest.md` に統一する（必要なら `latest.txt` も併設）。
