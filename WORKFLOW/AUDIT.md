# WORKFLOW: Audit (Gate D)

## Purpose
Gate D (Audit) は、Gate A/B/C で揃えた成果物と Evidence を第三者視点で点検し、**PASS/FAIL** と最小修正案を返すための運用です。

- AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。

---

## When to run
- Gate A/B/C が完了し、`ARTIFACTS/*` と Evidence（LOGS/diff/checksum など）が揃った後に実行します。
- Mode との関係（目安）:
  - **lite**: 任意（重要変更のみ推奨）
  - **standard**: 推奨（重大変更は必須）
  - **strict**: 必須

---

## Inputs (Evidence)
最低限、以下を参照します（単一の正＝フレームワーク側の定義に従う）:

- `ARTIFACTS/TASK_LISTS.md`
- `ARTIFACTS/IMPLEMENTATION_PLAN.md`
- `ARTIFACTS/WALKTHROUGH.md`
- `LOGS/`（CI/QAログ、監査ログ、差分要約など）
- `meta/CHECKSUMS.sha256`（配布バンドルがある場合）
- `ARTIFACTS/EXCEPTIONS.md`（例外がある場合）

---

## Outputs (Audit Artifacts)
Auditor は以下を作成/更新します:

- `ARTIFACTS/AUDIT_REPORT.md`
- `ARTIFACTS/AUDIT_CHECKLIST.md`
- （例外が必要な場合）`ARTIFACTS/EXCEPTIONS.md` を追記

---

## Decision rule (PASS / FAIL)
- **PASS**: 必要な Evidence が揃い、重大な矛盾・未解決リスクがない
- **FAIL**: Evidence 不足 / 重大な矛盾 / 重大リスク未解決 / ルール違反がある

FAIL の場合は、必ず以下を返します:
- 最小修正案（Recommended minimal fix）
- 再監査の条件（Re-audit condition）

---

## Procedure
1. 対象を確定（repo/branch/commit/version と Mode）
2. Gate A/B/C 成果物の整合を確認（スコープ/計画/実行ログ）
3. Evidence 品質を確認（LOGS / diff / checksums など）
4. リスクと指摘を整理（Top 3 risks / Top 5 findings）
5. `AUDIT_REPORT.md` と `AUDIT_CHECKLIST.md` を更新
6. **PASS/FAIL** を宣言し、次アクション（最小修正・再監査条件）を明記

---

## Notes
- 例外運用をする場合は `ARTIFACTS/EXCEPTIONS.md` に **理由・リスク・軽減策・期限（または解除条件）** を必ず記録します。
- 監査の参照先（Evidence）や Gate 定義は、上位ドキュメント（Charter/Mode/Artifacts）を優先します。

