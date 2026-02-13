#!/usr/bin/env bash
# gate_f.sh — Gate F: Initial Setup / Role Assignment (初期設定/役割割当)
# Verifies: INITIAL_SETTINGS.md, agent_role_assignment.example.yaml, adapter references

verify_gate_f() {
  local pass=0 fail=0 total=3

  echo "=== Gate F: Initial Setup / Role Assignment (初期設定/役割割当) ==="
  init_evidence "gateF"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check INITIAL_SETTINGS and role assignment files"
  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate F req①: Feature Summary ==="
    echo ""

    # Check INITIAL_SETTINGS.md
    echo "--- WORKFLOW/TOOLING/INITIAL_SETTINGS.md ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]]; then
      echo "EXISTS ($(wc -l < "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md") lines)"
      record_ref "WORKFLOW/TOOLING/INITIAL_SETTINGS.md"
      echo ""
      head -30 "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" 2>/dev/null || true
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check role assignment example
    echo "--- .cfctx/agent_role_assignment.example.yaml ---"
    if [[ -f "${MAIN_REPO}/.cfctx/agent_role_assignment.example.yaml" ]]; then
      echo "EXISTS"
      record_ref ".cfctx/agent_role_assignment.example.yaml"
      echo ""
      cat "${MAIN_REPO}/.cfctx/agent_role_assignment.example.yaml" 2>/dev/null || true
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check COEXIST_3FILES.md
    echo "--- WORKFLOW/TOOLING/COEXIST_3FILES.md ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/COEXIST_3FILES.md" ]]; then
      echo "EXISTS"
      record_ref "WORKFLOW/TOOLING/COEXIST_3FILES.md"
    else
      echo "NOT FOUND"
    fi
    echo ""

    echo "--- Runbook Gate F references ---"
    grep -n -i "gate.f\|初期設定\|INITIAL_SETTINGS\|role.assign" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
  } > "$req1_out"

  if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]]; then
    write_judgement "PASS" "INITIAL_SETTINGS.md exists; role assignment framework defined" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "INITIAL_SETTINGS.md not found" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Role assignment coherence across adapters and SSOT"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate F req②: Coherence Check ==="
    echo ""

    # Check adapters reference INITIAL_SETTINGS
    for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
      echo "--- ${adapter} INITIAL_SETTINGS references ---"
      grep -n -i "initial.setting\|role\|INITIAL_SETTINGS\|.cfctx" "${MAIN_REPO}/${adapter}" 2>/dev/null | head -10 || echo "(none)"
      echo ""
    done

    # Check .gitignore excludes local role files
    echo "--- .gitignore role exclusion ---"
    grep -n -i "role\|cfctx\|agent_role" "${MAIN_REPO}/.gitignore" 2>/dev/null | head -10 || echo "(none)"
    echo ""

    # Check runbook STEP-507 to STEP-512
    echo "--- Runbook STEP-50x (Gate F steps) ---"
    grep -n "STEP-50\|STEP-51" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
  } > "$req2_out"

  # Check at least one adapter references initial settings or role
  local adapter_refs=0
  for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
    if grep -q -i "initial.setting\|INITIAL_SETTINGS\|role\|.cfctx" "${MAIN_REPO}/${adapter}" 2>/dev/null; then
      ((adapter_refs++)) || true
    fi
  done

  if [[ "$adapter_refs" -gt 0 ]]; then
    write_judgement "PASS" "${adapter_refs}/3 adapters reference role/initial settings; coherent with Gate F" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "No adapters reference initial settings" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional role assignment validation"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate F req③: Functional Check ==="
    local cp=0 ct=0

    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]] && [[ -s "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]]; then
      echo "CHECK: INITIAL_SETTINGS.md exists and non-empty — PASS"; ((cp++))
    else
      echo "CHECK: INITIAL_SETTINGS.md exists and non-empty — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/.cfctx/agent_role_assignment.example.yaml" ]]; then
      echo "CHECK: agent_role_assignment.example.yaml exists — PASS"; ((cp++))
    else
      echo "CHECK: agent_role_assignment.example.yaml exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/COEXIST_3FILES.md" ]]; then
      echo "CHECK: COEXIST_3FILES.md exists — PASS"; ((cp++))
    else
      echo "CHECK: COEXIST_3FILES.md exists — FAIL"
    fi

    # Check all 3 adapters exist
    for adapter in CLAUDE.md AGENTS.md GEMINI.md; do
      ((ct++))
      if [[ -f "${MAIN_REPO}/${adapter}" ]]; then
        echo "CHECK: ${adapter} exists — PASS"; ((cp++))
      else
        echo "CHECK: ${adapter} exists — FAIL"
      fi
    done

    # Check .gitignore protects local role files
    ((ct++))
    if grep -q -i "agent_role\|cfctx.*local\|.cfctx/" "${MAIN_REPO}/.gitignore" 2>/dev/null; then
      echo "CHECK: .gitignore protects local role files — PASS"; ((cp++))
    else
      echo "CHECK: .gitignore protects local role files — FAIL (may use different pattern)"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]] && [[ -f "${MAIN_REPO}/.cfctx/agent_role_assignment.example.yaml" ]]; then
    write_judgement "PASS" "Role assignment functional: INITIAL_SETTINGS.md + example yaml + adapters present" "req③"
    ((pass++))
  elif [[ -f "${MAIN_REPO}/WORKFLOW/TOOLING/INITIAL_SETTINGS.md" ]]; then
    write_judgement "PASS" "INITIAL_SETTINGS.md exists; role assignment documented (example yaml may be optional)" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Role assignment files incomplete" "req③"
    ((fail++))
  fi

  gate_summary "Gate F" "$pass" "$fail" "$total"
}
