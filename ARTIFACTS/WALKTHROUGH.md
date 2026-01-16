# Walkthrough（検証 / Antigravity準拠）
> 目的：実装完了後に「何を変えたか」「どう検証するか」をまとめ、Trust Gapを埋める。

## Profile / Triggers
- 定義：`../WORKFLOW/MODES_AND_TRIGGERS.md`
- Profile:
- Triggers: Yes | No
- Reason:

## 1. What changed（変更概要）
- Coreに Antigravity 3点セット（Task Lists / Implementation Plan / Walkthrough）テンプレを標準搭載
- Sample Productの `workframe/core` にも同一テンプレを取り込み、参照・役割・メタを更新
- distを v0.1.4 として再パッケージし、完全版 `cf-dist_v0.1.4_complete.zip` を生成

## 2. Files changed（差分一覧：要約）
### Core（cf-core）
- Add：`artifacts/templates/TASK_LISTS.md`
- Add：`artifacts/templates/IMPLEMENTATION_PLAN.md`
- Add：`artifacts/templates/WALKTHROUGH.md`
- Modify：`docs/reference/ARTIFACTS.md`
- Modify：`artifacts/README.md`
- Modify：`protocols/roles/ORCHESTRATOR.md`
- Modify：`protocols/roles/ARCHITECT.md`
- Modify：`protocols/roles/CI_QA.md`
- Modify：`protocols/roles/CRAFTER.md`（推奨）
- Modify：`VERSION / CHANGELOG.md / _meta/*`

### Sample Product（cf-wf-sample-product）
- Modify：`workframe/core`（上記Core同等）
- Modify：ルート `VERSION / CHANGELOG.md / WORKFRAME_MANIFEST.yaml / _meta/*`

## 3. How to test（検証手順：コマンドは“コマンドだけ”を貼る）
> 入力ZIP：`cf-dist_v0.1.3_complete.zip`  
> 出力ZIP：`cf-dist_v0.1.4_complete.zip`

### 3.1 展開（作業用）
```bash
mkdir -p ~/cf-work/ag3_v014 && cd ~/cf-work/ag3_v014
cp /path/to/cf-dist_v0.1.3_complete.zip .
unzip cf-dist_v0.1.3_complete.zip -d dist
mkdir -p work
unzip dist/cf-core_v0.1.3.zip -d work
unzip dist/cf-wf-sample-product_v0.1.1.zip -d work
```

### 3.2 追加テンプレの配置確認
```bash
ls -la work/cf-core/artifacts/templates | grep -E "TASK_LISTS|IMPLEMENTATION_PLAN|WALKTHROUGH" || true
ls -la work/cf-wf-sample-product_v0.1.1/workframe/core/artifacts/templates | grep -E "TASK_LISTS|IMPLEMENTATION_PLAN|WALKTHROUGH" || true
```

### 3.3 参照（ARTIFACTS.md）確認
```bash
grep -n "TASK_LISTS.md" work/cf-core/docs/reference/ARTIFACTS.md
grep -n "IMPLEMENTATION_PLAN.md" work/cf-core/docs/reference/ARTIFACTS.md
grep -n "WALKTHROUGH.md" work/cf-core/docs/reference/ARTIFACTS.md
```

### 3.4 役割定義（roles）確認
```bash
grep -n "TASK_LISTS.md" work/cf-core/protocols/roles/ORCHESTRATOR.md
grep -n "IMPLEMENTATION_PLAN.md" work/cf-core/protocols/roles/ARCHITECT.md
grep -n "WALKTHROUGH.md" work/cf-core/protocols/roles/CI_QA.md
```

### 3.5 バージョン/メタ更新の確認（例：core）
```bash
cat work/cf-core/VERSION
grep -n "0.1.4" work/cf-core/CHANGELOG.md | head
cat work/cf-core/_meta/BUILD_INFO.json
cat work/cf-core/_meta/MANIFEST.yaml | head -n 20
```

### 3.6 CHECKSUMS 再生成（例：core）
```bash
cd work/cf-core
tmpfile="$(mktemp)"
find . -type f   ! -path "./.git/*"   ! -path "./_meta/CHECKSUMS.sha256"   -print0 | sort -z | xargs -0 sha256sum | sed 's| \./|  |' > "$tmpfile"
mv "$tmpfile" _meta/CHECKSUMS.sha256
cd -
```

### 3.7 zip再生成（完成品の生成）
> ここは最後にまとめて実施する（core → sample-product → dist）。

```bash
# core
cd work
zip -r ../dist/cf-core_v0.1.4.zip cf-core

# sample-product（フォルダ名を v0.1.2 にしてから）
mv cf-wf-sample-product_v0.1.1 cf-wf-sample-product_v0.1.2
zip -r ../dist/cf-wf-sample-product_v0.1.2.zip cf-wf-sample-product_v0.1.2

# dist（封筒）
cd ../dist
cp cf-business-pack_v0.1.0.zip cf-business-pack_v0.1.0.zip
cp cf-wf-starter_v0.1.0.zip cf-wf-starter_v0.1.0.zip
zip -r ../cf-dist_v0.1.4_complete.zip   cf-business-pack_v0.1.0.zip   cf-core_v0.1.4.zip   cf-wf-starter_v0.1.0.zip   cf-wf-sample-product_v0.1.2.zip
cd -
```

## 4. Evidence（証跡）
- `sha256sum cf-dist_v0.1.4_complete.zip` の値
- 各コンポーネントzipの `sha256sum`
- `git diff`（または差分ログ）
- 必要ならスクショ/録画（更新内容の確認が早くなる）

## 5. Known issues / Notes
- `cf-wf-starter` はプレースホルダのみのため、今回の取り込み対象外（同梱は継続）
- `WORKFRAME_MANIFEST.yaml` の `vendored.core_zip.sha256` は **新しいcore zip** のshaを入れること（更新漏れ注意）
