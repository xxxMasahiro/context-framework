# Walkthrough (Working)

> ここは **Gate C** の核です。最終的に「この通りにやれば再現できる」状態にします。

## 0. Prerequisites
- OS: Ubuntu推奨（sha256sumがあること）
- Tools: git, zip/unzip

## 1. Prepare workdir
```bash
# 作業ディレクトリ（例）
mkdir -p work
```

## 2. Unpack baseline (v0.1.3)
- 入力：`vendor/inputs/cf-dist_v0.1.3_complete.zip`（このZIPに同梱）
- (手順TBD)

## 3. Apply v0.1.4 changes
- (手順TBD)

## 4. Regenerate metadata
### CHECKSUMS
- `support/scripts/regen_checksums.sh`（必要なら vendor から利用）
- 実行ログを `LOGS/` に保存

### REPO_TREE
- (必要なら) tree生成

## 5. Build the final zip
- `cf-dist_v0.1.4_complete.zip` を生成
- zip中身をリストして確認

## 6. Verification checklist
- [ ] 3主要アーティファクトが含まれている
- [ ] README/DOCS_INDEXが参照できる
- [ ] CHECKSUMSが整合している（必要なら）

## 7. Logs
- `LOGS/` に貼り付けorファイル保存（コマンドと出力）
