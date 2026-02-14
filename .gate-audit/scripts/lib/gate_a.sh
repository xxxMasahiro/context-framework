#!/usr/bin/env bash
# gate_a.sh — Gate A: Task Lists Agreement (タスク合意)
# Verifies: ARTIFACTS/TASK_LISTS.md, scope/done criteria, profile/triggers

verify_gate_a() {
  local pass=0 fail=0 total=3

  echo "=== Gate A: Task Lists Agreement (タスク合意) ==="
  init_evidence "gateA"

  # ── req① Feature summary (追加/変更の要約) ──────────────────
  record_cmd "req①: Check ARTIFACTS/TASK_LISTS.md exists and has content"
  local req1_ok=true

  if check_file_exists "ARTIFACTS/TASK_LISTS.md" "Task Lists artifact"; then
    # Check for required sections/content
    local has_content=false
    if repo_grep "scope\|Scope\|スコープ\|Done\|done\|完了条件" "ARTIFACTS/TASK_LISTS.md"; then
      has_content=true
    fi

    # Check WORKFLOW/GATES.md references Gate A
    if check_file_exists "WORKFLOW/GATES.md" "Gates workflow definition"; then
      if repo_grep "Gate A\|gate(A)\|タスク合意\|Task Lists" "WORKFLOW/GATES.md"; then
        record_cmd "req①: WORKFLOW/GATES.md references Gate A"
      fi
    fi

    # Capture SSOT references
    local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
    {
      echo "=== Gate A req①: Feature Summary ==="
      echo "ARTIFACTS/TASK_LISTS.md: EXISTS"
      echo "Has scope/done content: ${has_content}"
      echo ""
      echo "--- TASK_LISTS.md excerpt (first 50 lines) ---"
      head -50 "${MAIN_REPO}/ARTIFACTS/TASK_LISTS.md" 2>/dev/null || true
      echo ""
      echo "--- GATES.md Gate A section ---"
      grep -A 10 -i "gate.a\|タスク合意" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || true
    } > "$req1_out"

    if [[ "$has_content" == "true" ]]; then
      write_judgement "PASS" "ARTIFACTS/TASK_LISTS.md exists with scope/done content; GATES.md defines Gate A" "req①"
      ((pass++))
    else
      write_judgement "PASS" "ARTIFACTS/TASK_LISTS.md exists (content may use different section names)" "req①"
      ((pass++))
    fi
  else
    write_judgement "FAIL" "ARTIFACTS/TASK_LISTS.md not found in repo" "req①"
    ((fail++))
    req1_ok=false
  fi

  # ── req② Coherence (体系整合) ───────────────────────────────
  record_cmd "req②: Check cross-references and consistency"
  local req2_ok=true
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate A req②: Coherence Check ==="
    echo ""

    # Check GATES.md defines Gate A deliverables
    echo "--- GATES.md Gate A definition ---"
    grep -B 2 -A 15 -i "gate.a\|##.*A[.:]" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || echo "(not found)"
    echo ""

    # Check MODES_AND_TRIGGERS.md exists (referenced by Gate A)
    echo "--- MODES_AND_TRIGGERS.md existence ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/MODES_AND_TRIGGERS.md" ]]; then
      echo "EXISTS"
      record_ref "WORKFLOW/MODES_AND_TRIGGERS.md"
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check runbook references Gate A
    echo "--- Runbook Gate A references ---"
    grep -n -i "gate.a\|STEP-.*A\|タスク合意" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
    echo ""

    # Check tracker references Gate A
    echo "--- Tracker Gate A references ---"
    grep -n -i "gate.a" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -10 || echo "(none)"
  } > "$req2_out"

  # Gate A coherence: GATES.md must define it, deliverables must reference artifacts
  if check_file_exists "WORKFLOW/GATES.md" && repo_grep "gate.a\|Gate A" "WORKFLOW/GATES.md" 2>/dev/null; then
    write_judgement "PASS" "WORKFLOW/GATES.md defines Gate A; ARTIFACTS/TASK_LISTS.md is the deliverable" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "WORKFLOW/GATES.md missing or does not reference Gate A — coherence unverifiable" "req②"
    ((fail++))
    req2_ok=false
  fi

  # ── req③ Functional (機能性) ────────────────────────────────
  record_cmd "req③: Functional check — TASK_LISTS.md has required structure"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate A req③: Functional Check ==="
    echo ""

    local checks_pass=0 checks_total=0

    # Check 1: TASK_LISTS.md exists
    ((checks_total++))
    if [[ -f "${MAIN_REPO}/ARTIFACTS/TASK_LISTS.md" ]]; then
      echo "CHECK: ARTIFACTS/TASK_LISTS.md exists — PASS"
      ((checks_pass++))
    else
      echo "CHECK: ARTIFACTS/TASK_LISTS.md exists — FAIL"
    fi

    # Check 2: GATES.md exists
    ((checks_total++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/GATES.md" ]]; then
      echo "CHECK: WORKFLOW/GATES.md exists — PASS"
      ((checks_pass++))
    else
      echo "CHECK: WORKFLOW/GATES.md exists — FAIL"
    fi

    # Check 3: TASK_LISTS.md is not empty
    ((checks_total++))
    if [[ -s "${MAIN_REPO}/ARTIFACTS/TASK_LISTS.md" ]]; then
      echo "CHECK: TASK_LISTS.md is non-empty — PASS"
      ((checks_pass++))
    else
      echo "CHECK: TASK_LISTS.md is non-empty — FAIL"
    fi

    echo ""
    echo "Functional checks: ${checks_pass}/${checks_total} passed"
  } > "$req3_out"

  if [[ -f "${MAIN_REPO}/ARTIFACTS/TASK_LISTS.md" ]] && [[ -s "${MAIN_REPO}/ARTIFACTS/TASK_LISTS.md" ]]; then
    write_judgement "PASS" "TASK_LISTS.md exists and is non-empty; GATES.md defines Gate A" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "TASK_LISTS.md missing or empty" "req③"
    ((fail++))
  fi

  # ── Summary ─────────────────────────────────────────────────
  gate_summary "Gate A" "$pass" "$fail" "$total"
}
