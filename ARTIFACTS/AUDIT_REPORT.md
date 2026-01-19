# AUDIT_REPORT

## 0. メタ
- Audit Gate: **D (Audit)**
- Decision: **PASS / FAIL**
- 対象: `<repo / branch / commit / version>`
- Mode: `<lite | standard | strict>`
- 日付: `<YYYY-MM-DD>`
- Auditor: `<agent/model name>`
- Scope Summary: `<監査対象の要約（1-3行）>`

> Note: AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。

---

## 1. エグゼクティブサマリ
- Overall: `<1段落>`
- Key Risks (top 3):
  1. `<risk>`
  2. `<risk>`
  3. `<risk>`

---

## 2. 指摘（Top 5）
> 各指摘は **What / Why / Evidence / Recommended minimal fix / Re-audit condition** を含める

### F-01
- What:
- Why:
- Evidence:
- Recommended minimal fix:
- Re-audit condition:

### F-02
- What:
- Why:
- Evidence:
- Recommended minimal fix:
- Re-audit condition:

### F-03
- What:
- Why:
- Evidence:
- Recommended minimal fix:
- Re-audit condition:

### F-04
- What:
- Why:
- Evidence:
- Recommended minimal fix:
- Re-audit condition:

### F-05
- What:
- Why:
- Evidence:
- Recommended minimal fix:
- Re-audit condition:

---

## 3. Evidence Index
- Task Lists: `ARTIFACTS/TASK_LISTS.md`
- Implementation Plan: `ARTIFACTS/IMPLEMENTATION_PLAN.md`
- Walkthrough: `ARTIFACTS/WALKTHROUGH.md`
- Logs: `LOGS/`（例: `LOGS/audit_*.log`, CI/QA logs, diffs）
- Checksums: `meta/CHECKSUMS.sha256`（該当時）

---

## 4. 例外
- 例外が適用された場合は `ARTIFACTS/EXCEPTIONS.md` に記録し、ここから参照する。
  - `<exception-id>`

---

## 5. 最終判断
- **PASS** criteria (example):
  - 必要な Evidence が揃い、一貫している
  - 未解決の重大リスクがない
- **FAIL** criteria (example):
  - Evidence 不足 / Artifacts の不整合
  - 未解決の重大リスク / ルール違反

Decision: **<PASS|FAIL>**
