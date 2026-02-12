#!/usr/bin/env bash
# gate_b.sh — Gate B: Implementation Plan Agreement (実装計画合意)
# Verifies: ARTIFACTS/IMPLEMENTATION_PLAN.md, file-level diff plan

verify_gate_b() {
  local pass=0 fail=0 total=3

  echo "=== Gate B: Implementation Plan Agreement (実装計画合意) ==="
  init_evidence "gateB"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check IMPLEMENTATION_PLAN.md exists and has content"

  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate B req①: Feature Summary ==="
    if [[ -f "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" ]]; then
      echo "ARTIFACTS/IMPLEMENTATION_PLAN.md: EXISTS"
      record_ref "ARTIFACTS/IMPLEMENTATION_PLAN.md"
      echo ""
      echo "--- Excerpt (first 50 lines) ---"
      head -50 "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" 2>/dev/null || true
    else
      echo "ARTIFACTS/IMPLEMENTATION_PLAN.md: NOT FOUND"
    fi
    echo ""
    echo "--- GATES.md Gate B section ---"
    grep -B 2 -A 15 -i "gate.b\|実装計画" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || echo "(not found)"
  } > "$req1_out"

  if check_file_exists "ARTIFACTS/IMPLEMENTATION_PLAN.md" "Implementation Plan artifact"; then
    write_judgement "PASS" "ARTIFACTS/IMPLEMENTATION_PLAN.md exists; implementation plan documented" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "ARTIFACTS/IMPLEMENTATION_PLAN.md not found" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Cross-reference Gate B definition in GATES.md and runbook"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate B req②: Coherence Check ==="
    echo ""
    echo "--- GATES.md Gate B definition ---"
    grep -B 2 -A 15 -i "gate.b\|##.*B[.:]" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || echo "(not found)"
    echo ""
    echo "--- Runbook Gate B references ---"
    grep -n -i "gate.b\|実装計画" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
    echo ""
    # Check Add/Del/Mod mentions
    echo "--- IMPLEMENTATION_PLAN.md Add/Del/Mod check ---"
    grep -i "add\|del\|mod\|追加\|削除\|変更" "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" 2>/dev/null | head -20 || echo "(none)"
  } > "$req2_out"

  check_file_exists "WORKFLOW/GATES.md" >/dev/null 2>&1 || true
  if repo_grep "gate.b\|Gate B\|実装計画" "WORKFLOW/GATES.md" 2>/dev/null; then
    write_judgement "PASS" "GATES.md defines Gate B; IMPLEMENTATION_PLAN.md is deliverable" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "GATES.md missing or does not reference Gate B — coherence unverifiable" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional check — file structure validation"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate B req③: Functional Check ==="
    local cp=0 ct=0

    ((ct++))
    if [[ -f "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" ]]; then
      echo "CHECK: IMPLEMENTATION_PLAN.md exists — PASS"; ((cp++))
    else
      echo "CHECK: IMPLEMENTATION_PLAN.md exists — FAIL"
    fi

    ((ct++))
    if [[ -s "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" ]]; then
      echo "CHECK: IMPLEMENTATION_PLAN.md is non-empty — PASS"; ((cp++))
    else
      echo "CHECK: IMPLEMENTATION_PLAN.md is non-empty — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/GATES.md" ]]; then
      echo "CHECK: WORKFLOW/GATES.md exists — PASS"; ((cp++))
    else
      echo "CHECK: WORKFLOW/GATES.md exists — FAIL"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if [[ -f "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" ]] && [[ -s "${MAIN_REPO}/ARTIFACTS/IMPLEMENTATION_PLAN.md" ]]; then
    write_judgement "PASS" "IMPLEMENTATION_PLAN.md exists, non-empty; Gate B deliverable present" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "IMPLEMENTATION_PLAN.md missing or empty" "req③"
    ((fail++))
  fi

  gate_summary "Gate B" "$pass" "$fail" "$total"
}
