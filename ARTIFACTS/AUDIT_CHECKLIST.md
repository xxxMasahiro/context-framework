# AUDIT_CHECKLIST

## 0. Meta
- Audit Gate: **D (Audit)**
- Target: `<repo / branch / commit / version>`
- Mode: `<lite | standard | strict>`
- Date: `<YYYY-MM-DD>`
- Auditor: `<agent/model name>`

> Rule: Auditor is independent and **does not implement fixes**.

---

## 1. Checklist Format
Fill each row:
- Status: **Yes / No / NA**
- Evidence: file path / log path / diff / commit
- Notes: short rationale
- Action Item (if No): minimal fix suggestion + re-audit condition

---

## 2. Core Consistency

### 2.1 Single Source of Truth hierarchy
- [ ] Status: ___ | **Charter → Mode → Artifacts → Skills** is respected | Evidence: ___ | Notes: ___
- [ ] Status: ___ | No lower layer overrides higher-layer rules | Evidence: ___ | Notes: ___

### 2.2 Role boundaries
- [ ] Status: ___ | Auditor produces PASS/FAIL and findings only (no implementation) | Evidence: ___ | Notes: ___
- [ ] Status: ___ | Fix owner is Crafter/Orchestrator (explicit) | Evidence: ___ | Notes: ___

---

## 3. Gate Integration (A/B/C + D)

### 3.1 Gate definitions
- [ ] Status: ___ | Gate A/B/C definitions are unchanged or updated consistently | Evidence: `WORKFLOW/GATES.md` | Notes: ___
- [ ] Status: ___ | Gate D (Audit) is defined (inputs/outputs/decision) | Evidence: `WORKFLOW/GATES.md` | Notes: ___

### 3.2 Gate flow alignment
- [ ] Status: ___ | Task Lists reflect Gate A scope decisions | Evidence: `ARTIFACTS/TASK_LISTS.md` | Notes: ___
- [ ] Status: ___ | Implementation Plan reflects Gate B file-level plan | Evidence: `ARTIFACTS/IMPLEMENTATION_PLAN.md` | Notes: ___
- [ ] Status: ___ | Walkthrough contains Gate C evidence (logs/diffs/checksums) | Evidence: `ARTIFACTS/WALKTHROUGH.md` | Notes: ___
- [ ] Status: ___ | Audit consumes Evidence and writes report/checklist (Gate D) | Evidence: `ARTIFACTS/AUDIT_REPORT.md` + this file | Notes: ___

---

## 4. Required Artifacts Presence

### 4.1 Artifacts folder
- [ ] Status: ___ | `ARTIFACTS/AUDIT_REPORT.md` exists | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `ARTIFACTS/AUDIT_CHECKLIST.md` exists | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `ARTIFACTS/EXCEPTIONS.md` exists (or documented as NA) | Evidence: ___ | Notes: ___

### 4.2 Prompts & workflow docs (if adopted)
- [ ] Status: ___ | `PROMPTS/AUDITOR.md` exists (or NA) | Evidence: ___ | Notes: ___
- [ ] Status: ___ | `WORKFLOW/AUDIT.md` exists (or NA) | Evidence: ___ | Notes: ___

---

## 5. Evidence Quality

### 5.1 Evidence completeness
- [ ] Status: ___ | Changes are traceable (diff / file list / summary) | Evidence: ___ | Notes: ___
- [ ] Status: ___ | Logs exist for key checks (CI/QA or manual) | Evidence: `LOGS/` | Notes: ___
- [ ] Status: ___ | Checksums exist when distributing bundles (or NA) | Evidence: `meta/CHECKSUMS.sha256` | Notes: ___

### 5.2 Evidence consistency
- [ ] Status: ___ | Artifacts content matches repo state (no stale references) | Evidence: ___ | Notes: ___
- [ ] Status: ___ | Links/paths in docs resolve correctly | Evidence: ___ | Notes: ___

---

## 6. Skills Integration (if applicable)

- [ ] Status: ___ | Skills do not redefine policy; they implement procedure | Evidence: `SKILLS/` | Notes: ___
- [ ] Status: ___ | Skills reference Artifacts for evidence/outputs | Evidence: `SKILLS/` | Notes: ___
- [ ] Status: ___ | Mode differences are respected (lite/standard/strict) | Evidence: `WORKFLOW/MODES_AND_TRIGGERS.md` | Notes: ___

---

## 7. Tool/Agent Files (CLAUDE / AGENTS / GEMINI)

- [ ] Status: ___ | Each file is adapter-like (not duplicating framework truth) | Evidence: `CLAUDE.md/AGENTS.md/GEMINI.md` | Notes: ___
- [ ] Status: ___ | Each file points back to framework as the single source | Evidence: ___ | Notes: ___

---

## 8. Summary

### 8.1 Final decision readiness
- PASS if all critical items are **Yes** and evidence is sufficient.
- FAIL if any critical item is **No** or evidence is missing.

Critical items (minimum):
- Hierarchy respected
- Gate D defined and connected
- Evidence exists and is consistent
- Auditor independence and fix ownership are clear
