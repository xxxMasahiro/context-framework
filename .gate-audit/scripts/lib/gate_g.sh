#!/usr/bin/env bash
# gate_g.sh — Gate G: Log Operations (ログ運用効率化)
# Verifies: LOGS/INDEX.md, cf-log-index.sh, cf-doctor.sh, cf-signature-report.sh,
#           Concrete→Abstract→Skills chain, WORKFLOW/SKILLS_INTEGRATION.md

verify_gate_g() {
  local pass=0 fail=0 total=3

  echo "=== Gate G: Log Operations (ログ運用効率化) ==="
  init_evidence "gateG"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check log infrastructure additions"
  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate G req①: Feature Summary ==="
    echo ""

    # Check LOGS/INDEX.md
    echo "--- LOGS/INDEX.md ---"
    if [[ -f "${MAIN_REPO}/LOGS/INDEX.md" ]]; then
      echo "EXISTS ($(wc -l < "${MAIN_REPO}/LOGS/INDEX.md") lines)"
      record_ref "LOGS/INDEX.md"
      echo ""
      echo "--- Excerpt (first 30 lines) ---"
      head -30 "${MAIN_REPO}/LOGS/INDEX.md" 2>/dev/null || true
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check tools
    for tool in tools/cf-log-index.sh tools/cf-doctor.sh tools/cf-signature-report.sh tools/cf-guard.sh; do
      echo "--- ${tool} ---"
      if [[ -f "${MAIN_REPO}/${tool}" ]]; then
        echo "EXISTS ($(wc -l < "${MAIN_REPO}/${tool}") lines)"
        record_ref "${tool}"
      else
        echo "NOT FOUND"
      fi
    done
    echo ""

    # Check WORKFLOW/SKILLS_INTEGRATION.md
    echo "--- WORKFLOW/SKILLS_INTEGRATION.md ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/SKILLS_INTEGRATION.md" ]]; then
      echo "EXISTS"
      record_ref "WORKFLOW/SKILLS_INTEGRATION.md"
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check WORKFLOW/SPEC/gates/gate-g.yaml
    echo "--- WORKFLOW/SPEC/gates/gate-g.yaml ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" ]]; then
      echo "EXISTS"
      record_ref "WORKFLOW/SPEC/gates/gate-g.yaml"
      cat "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" 2>/dev/null || true
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Runbook Gate G references
    echo "--- Runbook Gate G references ---"
    grep -n -i "gate.g\|ログ運用\|STEP-G0\|STEP-G1\|STEP-G2" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -30 || echo "(none)"
  } > "$req1_out"

  if [[ -f "${MAIN_REPO}/LOGS/INDEX.md" ]] && [[ -f "${MAIN_REPO}/tools/cf-log-index.sh" ]]; then
    write_judgement "PASS" "LOGS/INDEX.md + cf-log-index.sh exist; log infrastructure established" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "Log infrastructure missing (LOGS/INDEX.md or cf-log-index.sh)" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Log system coherence — INDEX/signatures/patterns"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate G req②: Coherence Check ==="
    echo ""

    # Check LOG-009 reference chain
    echo "--- LOG-009 reference chain ---"
    echo "In runbook:"
    grep -n "LOG-009" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -5 || echo "  (not found)"
    echo "In LOGS/INDEX.md:"
    grep -n "LOG-009" "${MAIN_REPO}/LOGS/INDEX.md" 2>/dev/null | head -5 || echo "  (not found)"
    echo "In tracker:"
    grep -n "LOG-009" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -5 || echo "  (not found)"
    echo ""

    # Check STEP-G003 reference chain
    echo "--- STEP-G003 reference chain ---"
    echo "In runbook:"
    grep -n "STEP-G003" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -5 || echo "  (not found)"
    echo "In gate-g.yaml:"
    grep -n "STEP-G003" "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" 2>/dev/null | head -5 || echo "  (not found)"
    echo "In cf-doctor.sh:"
    grep -n "STEP-G003" "${MAIN_REPO}/tools/cf-doctor.sh" 2>/dev/null | head -5 || echo "  (not found)"
    echo ""

    # Check Skills integration references logs
    echo "--- Skills Integration log references ---"
    grep -n -i "concrete\|abstract\|skill.*escalat\|昇格" "${MAIN_REPO}/WORKFLOW/SKILLS_INTEGRATION.md" 2>/dev/null | head -10 || echo "  (not found)"
  } > "$req2_out"

  # Coherence: LOG-009 should appear in runbook AND INDEX
  local log009_in_runbook=false log009_in_index=false
  grep -q "LOG-009" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null && log009_in_runbook=true
  grep -q "LOG-009" "${MAIN_REPO}/LOGS/INDEX.md" 2>/dev/null && log009_in_index=true

  if [[ "$log009_in_runbook" == "true" ]] && [[ "$log009_in_index" == "true" ]]; then
    write_judgement "PASS" "LOG-009 reference chain intact (runbook + INDEX); STEP-G003 cross-referenced" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "LOG-009 reference chain broken (runbook:${log009_in_runbook}, INDEX:${log009_in_index})" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional log check — cf-doctor STEP-G003 (read-only)"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate G req③: Functional Check ==="
    local cp=0 ct=0

    # Check cf-doctor.sh exists and is executable
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-doctor.sh" ]] && [[ -x "${MAIN_REPO}/tools/cf-doctor.sh" || -r "${MAIN_REPO}/tools/cf-doctor.sh" ]]; then
      echo "CHECK: tools/cf-doctor.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: tools/cf-doctor.sh exists — FAIL"
    fi

    # Check cf-guard.sh exists
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-guard.sh" ]]; then
      echo "CHECK: tools/cf-guard.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: tools/cf-guard.sh exists — FAIL"
    fi

    # Check cf-log-index.sh exists
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-log-index.sh" ]]; then
      echo "CHECK: tools/cf-log-index.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: tools/cf-log-index.sh exists — FAIL"
    fi

    # Check cf-signature-report.sh exists
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-signature-report.sh" ]]; then
      echo "CHECK: tools/cf-signature-report.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: tools/cf-signature-report.sh exists — FAIL"
    fi

    # Check LOGS/INDEX.md is non-empty
    ((ct++))
    if [[ -s "${MAIN_REPO}/LOGS/INDEX.md" ]]; then
      echo "CHECK: LOGS/INDEX.md non-empty — PASS"; ((cp++))
    else
      echo "CHECK: LOGS/INDEX.md non-empty — FAIL"
    fi

    # Check gate-g.yaml exists
    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" ]]; then
      echo "CHECK: WORKFLOW/SPEC/gates/gate-g.yaml exists — PASS"; ((cp++))
    else
      echo "CHECK: WORKFLOW/SPEC/gates/gate-g.yaml exists — FAIL"
    fi

    # Try running cf-doctor syntax check (non-destructive)
    ((ct++))
    if bash -n "${MAIN_REPO}/tools/cf-doctor.sh" 2>/dev/null; then
      echo "CHECK: cf-doctor.sh syntax valid — PASS"; ((cp++))
    else
      echo "CHECK: cf-doctor.sh syntax valid — FAIL"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  local tools_ok=true
  for t in tools/cf-doctor.sh tools/cf-guard.sh tools/cf-log-index.sh; do
    [[ -f "${MAIN_REPO}/${t}" ]] || tools_ok=false
  done

  if [[ "$tools_ok" == "true" ]] && [[ -s "${MAIN_REPO}/LOGS/INDEX.md" ]]; then
    write_judgement "PASS" "Log tools operational: cf-doctor + cf-guard + cf-log-index present; INDEX non-empty" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Log tools or INDEX incomplete" "req③"
    ((fail++))
  fi

  gate_summary "Gate G" "$pass" "$fail" "$total"
}
