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
- Dist を v0.1.4 として再パッケージ

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

## 3. How to test（検証手順：コマンドは"コマンドだけ"を貼る）

### 3.1 追加テンプレの配置確認
```bash
ls -la artifacts/templates | grep -E "TASK_LISTS|IMPLEMENTATION_PLAN|WALKTHROUGH" || true
```

### 3.2 参照（ARTIFACTS.md）確認
```bash
grep -n "TASK_LISTS.md" docs/reference/ARTIFACTS.md
grep -n "IMPLEMENTATION_PLAN.md" docs/reference/ARTIFACTS.md
grep -n "WALKTHROUGH.md" docs/reference/ARTIFACTS.md
```

### 3.3 役割定義（roles）確認
```bash
grep -n "TASK_LISTS.md" protocols/roles/ORCHESTRATOR.md
grep -n "IMPLEMENTATION_PLAN.md" protocols/roles/ARCHITECT.md
grep -n "WALKTHROUGH.md" protocols/roles/CI_QA.md
```

### 3.4 バージョン/メタ更新の確認（例：core）
```bash
cat VERSION
grep -n "0.1.4" CHANGELOG.md | head
cat _meta/BUILD_INFO.json
cat _meta/MANIFEST.yaml | head -n 20
```

### 3.5 CHECKSUMS 再生成（例：core）
```bash
tmpfile="$(mktemp)"
find . -type f   ! -path "./.git/*"   ! -path "./_meta/CHECKSUMS.sha256"   -print0 | sort -z | xargs -0 sha256sum | sed 's| \./|  |' > "$tmpfile"
mv "$tmpfile" _meta/CHECKSUMS.sha256
```

## 4. Evidence（証跡）
- 成果物の `sha256sum` の値
- `git diff`（または差分ログ）
- 必要ならスクショ/録画（更新内容の確認が早くなる）
- Gate D の参照先: `ARTIFACTS/AUDIT_REPORT.md` / `ARTIFACTS/AUDIT_CHECKLIST.md`

- Skill適用の検証ログ（残し方）
  - Walkthrough の該当手順の直後に、Skill名と「実行ログ/検証ログ」を残す（後から再現できる粒度）。
  - `Apply Skill: SKILLS/<skill_file>.md`
  - 実行ログ（例）: `git status -sb` / `git diff` / `git diff -- <file>` / `git log -1 --oneline`
  - 検証ログ（例）: 期待どおりの差分・出力が取れたこと（No-op の場合は理由と確認観点のみを残す）

## 5. Known issues / Notes
- `cf-wf-starter` はプレースホルダのみのため、今回の取り込み対象外（同梱は継続）
- 具体的な書き方は `WORKFLOW/TRANSLATION_LAYER.md` を参照する。
