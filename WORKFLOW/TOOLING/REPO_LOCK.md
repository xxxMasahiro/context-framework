# Repo Lock（Repo Fingerprint + Guard）

## 目的
- 作業対象リポジトリの取り違えを防止する。
- パス固定ではなく、Repo Fingerprint と Guard による同一性判定で確認する。

## Repo Fingerprint
- ルート直下の `.repo-id/repo_fingerprint.json` を正とする。
- パスに依存しない識別子（`repo_id`）と、`expected_remotes` の一致で同一性を判定する。
- `expected_remotes` は運用で更新してよい（リモート変更時のみ）。

## Guard（チェックと実行）
- 事前確認: `./tools/cf-guard.sh --check`
- ガード実行: `./tools/cf-guard.sh -- <command...>`
- NG の場合は **中止**し、原因（origin/expected_remotes/SSOTファイル有無）を確認する。

## 運用指針
- 破壊的操作（restore/reset/clean/rm など）は Guard 経由を推奨する（強制ではない）。
- Guard が通らない場合は、リポジトリ取り違えの可能性があるため作業を中止する。
- 詳細運用は `_handoff_check/cf_update_runbook.md` を正とする。
