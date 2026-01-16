# WORKFLOW / GATES

PR無し運用の代わりに **Gateコミット**でレビューと証跡を残します。

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

## main への反映（PR無し）
- Developer GO 後に以下のいずれか
  - Fast-forward merge
  - squash merge（小さくまとめたい場合）

> 重要：main反映後にタグを打つ（例：`v0.1.4-alpha.1`）
