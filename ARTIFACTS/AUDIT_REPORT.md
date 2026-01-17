# AUDIT_REPORT

## 0. Meta
- Audit Gate: **D (Audit)**
- Decision: **PASS / FAIL**
- Target: `<repo / branch / commit / version>`
- Mode: `<lite | standard | strict>`
- Date: `<YYYY-MM-DD>`
- Auditor: `<agent/model name>`
- Scope Summary: `<what was audited in 1-3 lines>`

> Note: AuditorはPRへ監査結果を返す。修正はCrafter/Orchestratorが行う。

---

## 1. Executive Summary
- Overall: `<one paragraph>`
- Key Risks (top 3):
  1. `<risk>`
  2. `<risk>`
  3. `<risk>`

---

## 2. Findings (Top 5)
> Each finding should include: **What / Why / Evidence / Recommended minimal fix / Re-audit condition**

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
- Logs: `LOGS/` (e.g. `LOGS/audit_*.log`, CI/QA logs, diffs)
- Checksums: `meta/CHECKSUMS.sha256` (if applicable)

---

## 4. Exceptions
- If any exception was applied, record it in `ARTIFACTS/EXCEPTIONS.md` and reference it here.
  - `<exception-id>`

---

## 5. Final Decision
- **PASS** criteria (example):
  - Required evidence is present and consistent
  - No unresolved critical risks
- **FAIL** criteria (example):
  - Missing evidence / inconsistent artifacts
  - Unresolved critical risks / rule violations

Decision: **<PASS|FAIL>**
