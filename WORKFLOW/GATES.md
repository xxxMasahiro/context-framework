# WORKFLOW / GATES

PR経由の運用で **Gateコミット**によるレビューと証跡を残します。

## ブランチ規約
- `main`：常に安定。GOの無い変更は入れない
- `wip/v0.1.4`：作業ブランチ（通常はここだけ使う）

## Gate A / B / C

### Gate A：Task Lists 合意
- 目的：作業範囲（スコープ）とDoneを固定
- 成果物：`ARTIFACTS/TASK_LISTS.md` が埋まっている
  - Profile/Triggers を記入（定義：`./MODES_AND_TRIGGERS.md`）
- コミット例：`gate(A): scope + done definition`

### Gate B：Implementation Plan 合意
- 目的：ファイル単位の差分計画を固定
- 成果物：`ARTIFACTS/IMPLEMENTATION_PLAN.md` が埋まっている
  - Profile/Triggers を確認（定義：`./MODES_AND_TRIGGERS.md`）
- コミット例：`gate(B): implementation plan locked`

### Gate C：Walkthrough 完走
- 目的：再現性のある検証＋証跡を残す
- 成果物：
  - `ARTIFACTS/WALKTHROUGH.md` が更新されている
  - `LOGS/` に実行ログが置かれている
  - Profile/Triggers と証跡が整合（定義：`./MODES_AND_TRIGGERS.md`）
- コミット例：`gate(C): walkthrough passed (logs attached)`

### Gate D：Audit 完了
- 目的：第三者視点でEvidenceの整合性を監査する
- 成果物：
  - `ARTIFACTS/AUDIT_REPORT.md` が更新されている
  - `ARTIFACTS/AUDIT_CHECKLIST.md` が更新されている
  - 監査運用の定義は `./AUDIT.md`
- コミット例：`gate(D): audit passed`

## app/ 変更時の Gate 適用境界（REQ-CF-I11）

変更が `app/**` のみの場合、以下の Gate 免除が適用されます:

| Gate | L1/L2 を含む変更 | app/ のみの変更 |
|------|-----------------|----------------|
| Gate A (Task Lists) | 必須 | **省略可** |
| Gate B (Impl Plan) | 必須 | **省略可** |
| Gate C (Walkthrough) | 必須 | **部分的**（CI/CQ 証跡で代替可） |
| Gate D (Audit) | 必須 | **省略可** |

**判定方法**: `git diff --name-only` で変更ファイル一覧を取得し、全ファイルが `app/` 配下であるかを判定する。L1/L2 を含む変更は既存どおり Gate A-D 必須。

## main への反映（PR経由）
- Developer GO 後に PR を作成し、レビュー＋CI/CQ PASS を経てマージする

> 重要：main反映後にタグを打つ（例：`v0.1.4-alpha.1`）
