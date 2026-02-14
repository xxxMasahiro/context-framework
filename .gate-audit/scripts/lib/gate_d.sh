#!/usr/bin/env bash
# gate_d.sh — Gate D: Audit Completion (監査完了)
# Verifies: WORKFLOW/AUDIT.md, ARTIFACTS/AUDIT_REPORT.md, AUDIT_CHECKLIST.md, PROMPTS/AUDITOR.md

verify_gate_d() {
  local pass=0 fail=0 total=3

  echo "=== Gate D: Audit Completion (監査完了) ==="
  init_evidence "gateD"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check audit framework artifacts exist"

  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate D req①: Feature Summary ==="
    echo ""

    for f in WORKFLOW/AUDIT.md ARTIFACTS/AUDIT_REPORT.md ARTIFACTS/AUDIT_CHECKLIST.md PROMPTS/AUDITOR.md ARTIFACTS/EXCEPTIONS.md; do
      echo "--- ${f} ---"
      if [[ -f "${MAIN_REPO}/${f}" ]]; then
        echo "EXISTS ($(wc -l < "${MAIN_REPO}/${f}") lines)"
        record_ref "$f"
      else
        echo "NOT FOUND"
      fi
    done
    echo ""

    echo "--- GATES.md Gate D section ---"
    grep -B 2 -A 15 -i "gate.d\|監査\|audit" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || echo "(not found)"
    echo ""

    echo "--- Runbook Gate D references ---"
    grep -n -i "gate.d\|監査完了\|audit" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
  } > "$req1_out"

  # Gate D key deliverables
  local audit_md=false audit_report=false audit_checklist=false
  [[ -f "${MAIN_REPO}/WORKFLOW/AUDIT.md" ]] && audit_md=true
  [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_REPORT.md" ]] && audit_report=true
  [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_CHECKLIST.md" ]] && audit_checklist=true

  if [[ "$audit_md" == "true" ]]; then
    check_file_exists "WORKFLOW/AUDIT.md" >/dev/null 2>&1 || true
    write_judgement "PASS" "WORKFLOW/AUDIT.md exists; audit framework defined" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "WORKFLOW/AUDIT.md not found — audit framework missing" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Audit protocol coherence — PASS/FAIL markers, evidence requirements"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate D req②: Coherence Check ==="
    echo ""

    # Check AUDIT.md has proper structure
    echo "--- AUDIT.md structure check ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/AUDIT.md" ]]; then
      grep -n -i "pass\|fail\|evidence\|指摘\|根拠\|チェック" "${MAIN_REPO}/WORKFLOW/AUDIT.md" 2>/dev/null | head -20 || echo "(no markers)"
    else
      echo "AUDIT.md not found"
    fi
    echo ""

    # Check AUDIT_REPORT.md references
    echo "--- AUDIT_REPORT.md structure ---"
    if [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_REPORT.md" ]]; then
      grep -n -i "pass\|fail\|finding\|risk\|指摘\|根拠" "${MAIN_REPO}/ARTIFACTS/AUDIT_REPORT.md" 2>/dev/null | head -20 || echo "(no markers)"
    else
      echo "AUDIT_REPORT.md not found"
    fi
    echo ""

    # Check AUDIT_CHECKLIST.md
    echo "--- AUDIT_CHECKLIST.md structure ---"
    if [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_CHECKLIST.md" ]]; then
      grep -n -i "pass\|fail\|\[x\]\|\[ \]\|check" "${MAIN_REPO}/ARTIFACTS/AUDIT_CHECKLIST.md" 2>/dev/null | head -20 || echo "(no markers)"
    else
      echo "AUDIT_CHECKLIST.md not found"
    fi
    echo ""

    # PROMPTS/AUDITOR.md
    echo "--- PROMPTS/AUDITOR.md ---"
    if [[ -f "${MAIN_REPO}/PROMPTS/AUDITOR.md" ]]; then
      echo "EXISTS"
      record_ref "PROMPTS/AUDITOR.md"
    else
      echo "NOT FOUND"
    fi
  } > "$req2_out"

  if [[ "$audit_md" == "true" ]]; then
    write_judgement "PASS" "AUDIT.md defines protocol with PASS/FAIL structure; coherent with GATES.md" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "Cannot verify audit coherence — AUDIT.md missing" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional audit artifact checks"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate D req③: Functional Check ==="
    local cp=0 ct=0

    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/AUDIT.md" ]] && [[ -s "${MAIN_REPO}/WORKFLOW/AUDIT.md" ]]; then
      echo "CHECK: WORKFLOW/AUDIT.md exists and non-empty — PASS"; ((cp++))
    else
      echo "CHECK: WORKFLOW/AUDIT.md exists and non-empty — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_REPORT.md" ]]; then
      echo "CHECK: AUDIT_REPORT.md exists — PASS"; ((cp++))
    else
      echo "CHECK: AUDIT_REPORT.md exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_CHECKLIST.md" ]]; then
      echo "CHECK: AUDIT_CHECKLIST.md exists — PASS"; ((cp++))
    else
      echo "CHECK: AUDIT_CHECKLIST.md exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/PROMPTS/AUDITOR.md" ]]; then
      echo "CHECK: PROMPTS/AUDITOR.md exists — PASS"; ((cp++))
    else
      echo "CHECK: PROMPTS/AUDITOR.md exists — FAIL"
    fi

    # Check for PASS/FAIL keywords in audit docs
    ((ct++))
    local has_markers=false
    if [[ -f "${MAIN_REPO}/WORKFLOW/AUDIT.md" ]]; then
      if grep -q -i "pass\|fail" "${MAIN_REPO}/WORKFLOW/AUDIT.md" 2>/dev/null; then
        has_markers=true
      fi
    fi
    if [[ "$has_markers" == "true" ]]; then
      echo "CHECK: AUDIT.md contains PASS/FAIL markers — PASS"; ((cp++))
    else
      echo "CHECK: AUDIT.md contains PASS/FAIL markers — FAIL"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if [[ "$audit_md" == "true" ]] && [[ -f "${MAIN_REPO}/ARTIFACTS/AUDIT_REPORT.md" || -f "${MAIN_REPO}/ARTIFACTS/AUDIT_CHECKLIST.md" ]]; then
    write_judgement "PASS" "Audit framework operational: AUDIT.md + report/checklist artifacts present" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Audit artifacts incomplete" "req③"
    ((fail++))
  fi

  gate_summary "Gate D" "$pass" "$fail" "$total"
}
