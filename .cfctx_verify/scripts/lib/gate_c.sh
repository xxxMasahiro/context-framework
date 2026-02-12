#!/usr/bin/env bash
# gate_c.sh — Gate C: Walkthrough Completion (ウォークスルー完走)
# Verifies: ARTIFACTS/WALKTHROUGH.md, LOGS/, evidence trail, adapter references

verify_gate_c() {
  local pass=0 fail=0 total=3

  echo "=== Gate C: Walkthrough Completion (ウォークスルー完走) ==="
  init_evidence "gateC"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check WALKTHROUGH.md and LOGS/ exist"

  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate C req①: Feature Summary ==="

    if [[ -f "${MAIN_REPO}/ARTIFACTS/WALKTHROUGH.md" ]]; then
      echo "ARTIFACTS/WALKTHROUGH.md: EXISTS"
      record_ref "ARTIFACTS/WALKTHROUGH.md"
      echo ""
      echo "--- Excerpt (first 50 lines) ---"
      head -50 "${MAIN_REPO}/ARTIFACTS/WALKTHROUGH.md" 2>/dev/null || true
    else
      echo "ARTIFACTS/WALKTHROUGH.md: NOT FOUND"
    fi
    echo ""
    echo "--- LOGS/ directory ---"
    if [[ -d "${MAIN_REPO}/LOGS" ]]; then
      echo "LOGS/ EXISTS"
      ls -la "${MAIN_REPO}/LOGS/" 2>/dev/null || true
    else
      echo "LOGS/ NOT FOUND"
    fi
    echo ""
    echo "--- GATES.md Gate C section ---"
    grep -B 2 -A 15 -i "gate.c\|ウォークスルー" "${MAIN_REPO}/WORKFLOW/GATES.md" 2>/dev/null || echo "(not found)"
  } > "$req1_out"

  if check_file_exists "ARTIFACTS/WALKTHROUGH.md" "Walkthrough artifact"; then
    write_judgement "PASS" "ARTIFACTS/WALKTHROUGH.md exists; walkthrough documented" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "ARTIFACTS/WALKTHROUGH.md not found" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Adapter reference consistency and LOGS/ presence"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate C req②: Coherence Check ==="
    echo ""

    # Check adapter files reference WORKFLOW/ARTIFACTS
    for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
      echo "--- ${adapter} references ---"
      if [[ -f "${MAIN_REPO}/${adapter}" ]]; then
        record_ref "${adapter}"
        grep -n -i "WORKFLOW\|ARTIFACTS\|GATES\|walkthrough" "${MAIN_REPO}/${adapter}" 2>/dev/null | head -10 || echo "(no references found)"
      else
        echo "${adapter}: NOT FOUND"
      fi
      echo ""
    done

    # Check LOGS/ has content
    echo "--- LOGS/ content count ---"
    local log_count
    log_count=$(find "${MAIN_REPO}/LOGS" -type f 2>/dev/null | wc -l) || log_count=0
    echo "Files in LOGS/: ${log_count}"
    echo ""

    # Check LOGS/INDEX.md
    echo "--- LOGS/INDEX.md ---"
    if [[ -f "${MAIN_REPO}/LOGS/INDEX.md" ]]; then
      echo "EXISTS"
      record_ref "LOGS/INDEX.md"
    else
      echo "NOT FOUND"
    fi
  } > "$req2_out"

  if [[ -d "${MAIN_REPO}/LOGS" ]] && check_file_exists "WORKFLOW/GATES.md" >/dev/null 2>&1; then
    write_judgement "PASS" "LOGS/ exists; adapters reference workflow; GATES.md defines Gate C" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "LOGS/ or GATES.md missing — coherence not verified" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional adapter reference check"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate C req③: Functional Check ==="
    local cp=0 ct=0

    ((ct++))
    if [[ -f "${MAIN_REPO}/ARTIFACTS/WALKTHROUGH.md" ]] && [[ -s "${MAIN_REPO}/ARTIFACTS/WALKTHROUGH.md" ]]; then
      echo "CHECK: WALKTHROUGH.md exists and non-empty — PASS"; ((cp++))
    else
      echo "CHECK: WALKTHROUGH.md exists and non-empty — FAIL"
    fi

    ((ct++))
    if [[ -d "${MAIN_REPO}/LOGS" ]]; then
      echo "CHECK: LOGS/ directory exists — PASS"; ((cp++))
    else
      echo "CHECK: LOGS/ directory exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/LOGS/INDEX.md" ]]; then
      echo "CHECK: LOGS/INDEX.md exists — PASS"; ((cp++))
    else
      echo "CHECK: LOGS/INDEX.md exists — FAIL"
    fi

    # Check adapter integrity
    for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
      ((ct++))
      if [[ -f "${MAIN_REPO}/${adapter}" ]] && [[ -s "${MAIN_REPO}/${adapter}" ]]; then
        echo "CHECK: ${adapter} exists and non-empty — PASS"; ((cp++))
      else
        echo "CHECK: ${adapter} exists and non-empty — FAIL"
      fi
    done

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  local all_adapters=true
  for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
    [[ -f "${MAIN_REPO}/${adapter}" ]] || all_adapters=false
  done

  if [[ "$all_adapters" == "true" ]] && [[ -d "${MAIN_REPO}/LOGS" ]]; then
    write_judgement "PASS" "All adapters present; LOGS/ exists; walkthrough infrastructure complete" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Missing adapters or LOGS/ — functional check failed" "req③"
    ((fail++))
  fi

  gate_summary "Gate C" "$pass" "$fail" "$total"
}
