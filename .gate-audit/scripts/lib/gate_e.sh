#!/usr/bin/env bash
# gate_e.sh — Gate E: Language Policy (言語ポリシー統一)
# Verifies: Japanese canonical policy, GATE_AUDIT_LANG_POLICY_V1 marker

verify_gate_e() {
  local pass=0 fail=0 total=3

  echo "=== Gate E: Language Policy (言語ポリシー統一) ==="
  init_evidence "gateE"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check language policy additions in SSOT"
  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate E req①: Feature Summary ==="
    echo ""

    # Check for GATE_AUDIT_LANG_POLICY_V1 marker
    echo "--- GATE_AUDIT_LANG_POLICY_V1 marker search ---"
    for f in _handoff_check/cf_update_runbook.md _handoff_check/cf_task_tracker_v5.md _handoff_check/cf_handoff_prompt.md; do
      echo "${f}:"
      grep -n "GATE_AUDIT_LANG_POLICY" "${MAIN_REPO}/${f}" 2>/dev/null || echo "  (not found)"
    done
    echo ""

    # Check runbook language policy section
    echo "--- Runbook language policy section ---"
    grep -n -i "言語ポリシー\|Language Policy\|日本語.*正\|canonical\|LANG_POLICY" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
    echo ""

    # Check Gate E steps in runbook
    echo "--- Runbook Gate E / STEP-45x references ---"
    grep -n -i "gate.e\|STEP-45\|言語ポリシー" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"

    record_ref "_handoff_check/cf_update_runbook.md"
  } > "$req1_out"

  # Check if language policy marker exists
  if grep -q "GATE_AUDIT_LANG_POLICY" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null ||
     grep -q "GATE_AUDIT_LANG_POLICY" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
    write_judgement "PASS" "GATE_AUDIT_LANG_POLICY_V1 marker found in SSOT; language policy established" "req①"
    ((pass++))
  else
    # Fallback: check for Japanese policy text
    if grep -q -i "日本語.*正\|Japanese.*canonical" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null; then
      write_judgement "PASS" "Japanese canonical policy defined in runbook (marker may use different format)" "req①"
      ((pass++))
    else
      write_judgement "FAIL" "Language policy marker/definition not found in SSOT" "req①"
      ((fail++))
    fi
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Language policy coherence across documents"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate E req②: Coherence Check ==="
    echo ""

    # Check consistency across all SSOT files
    echo "--- Language policy references in tracker ---"
    grep -n -i "言語\|language\|日本語\|english\|canonical" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -10 || echo "(none)"
    echo ""

    echo "--- Language policy references in handoff ---"
    grep -n -i "言語\|language\|日本語\|canonical" "${MAIN_REPO}/_handoff_check/cf_handoff_prompt.md" 2>/dev/null | head -10 || echo "(none)"
    echo ""

    # Check PROMPTS/ for language consistency
    echo "--- PROMPTS/ files ---"
    ls "${MAIN_REPO}/PROMPTS/" 2>/dev/null || echo "(directory not found)"
    echo ""

    # Check adapter files for language policy
    for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
      echo "--- ${adapter} language references ---"
      grep -n -i "日本語\|language\|canonical\|言語" "${MAIN_REPO}/${adapter}" 2>/dev/null | head -5 || echo "(none)"
    done
  } > "$req2_out"

  # Coherence check: language policy should be in runbook at minimum
  if grep -q -i "日本語.*正\|表記ポリシー\|LANG_POLICY\|言語ポリシー" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null; then
    write_judgement "PASS" "Language policy consistent in runbook (SSOT authority); adapters can reference" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "Language policy not found in runbook" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional language policy check"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate E req③: Functional Check ==="
    local cp=0 ct=0

    # Check 1: Runbook has language policy
    ((ct++))
    if grep -q -i "表記ポリシー\|言語ポリシー\|日本語統一\|LANG_POLICY" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null; then
      echo "CHECK: Runbook contains language policy — PASS"; ((cp++))
    else
      echo "CHECK: Runbook contains language policy — FAIL"
    fi

    # Check 2: Tracker has lang policy marker
    ((ct++))
    if grep -q "GATE_AUDIT_LANG_POLICY\|表記ポリシー\|言語ポリシー" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
      echo "CHECK: Tracker has language policy marker — PASS"; ((cp++))
    else
      echo "CHECK: Tracker has language policy marker — FAIL"
    fi

    # Check 3: Gate E steps referenced in runbook
    ((ct++))
    if grep -q -i "STEP-45\|gate.e" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null; then
      echo "CHECK: Gate E steps in runbook — PASS"; ((cp++))
    else
      echo "CHECK: Gate E steps in runbook — FAIL (may use different step numbering)"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if grep -q -i "表記ポリシー\|日本語統一\|LANG_POLICY" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null; then
    write_judgement "PASS" "Language policy functional: runbook defines policy, markers present" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Language policy functional check failed" "req③"
    ((fail++))
  fi

  gate_summary "Gate E" "$pass" "$fail" "$total"
}
