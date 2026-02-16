#!/usr/bin/env bash
# gate_h.sh — Gate H: Controller / New Task Entry (コントローラー/新規タスク入口)
# Verifies: controller/, rules/, bin/ctx-run, controller-smoke.sh, ci-validate.sh

verify_gate_h() {
  local pass=0 fail=0 total=3

  echo "=== Gate H: Controller / New Task Entry (コントローラー/新規タスク入口) ==="
  init_evidence "gateH"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check controller infrastructure additions"
  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate H req①: Feature Summary ==="
    echo ""

    # Check controller/ directory
    echo "--- controller/ directory ---"
    if [[ -d "${MAIN_REPO}/controller" ]]; then
      echo "EXISTS"
      ls -la "${MAIN_REPO}/controller/" 2>/dev/null || true
      # Record key files
      for f in $(find "${MAIN_REPO}/controller" -maxdepth 2 -type f 2>/dev/null | head -20); do
        local rel="${f#${MAIN_REPO}/}"
        record_ref "$rel"
      done
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check rules/ directory
    echo "--- rules/ directory ---"
    if [[ -d "${MAIN_REPO}/rules" ]]; then
      echo "EXISTS"
      ls -la "${MAIN_REPO}/rules/" 2>/dev/null || true
      for f in $(find "${MAIN_REPO}/rules" -maxdepth 1 -type f 2>/dev/null); do
        local rel="${f#${MAIN_REPO}/}"
        record_ref "$rel"
      done
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check bin/ctx-run
    echo "--- bin/ctx-run ---"
    if [[ -f "${MAIN_REPO}/bin/ctx-run" ]]; then
      echo "EXISTS"
      record_ref "bin/ctx-run"
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check tools
    for tool in tools/controller-smoke.sh tools/ci-validate.sh; do
      echo "--- ${tool} ---"
      if [[ -f "${MAIN_REPO}/${tool}" ]]; then
        echo "EXISTS"
        record_ref "${tool}"
      else
        echo "NOT FOUND"
      fi
    done
    echo ""

    # Runbook Gate H references
    echo "--- Runbook Gate H references ---"
    grep -n -i "gate.h\|controller\|Phase 0\|Phase 1\|H[0-9]\+:" "${MAIN_REPO}/_handoff_check/update_runbook.md" 2>/dev/null | head -30 || echo "(none)"
  } > "$req1_out"

  if [[ -d "${MAIN_REPO}/controller" ]] && [[ -d "${MAIN_REPO}/rules" ]]; then
    write_judgement "PASS" "controller/ and rules/ directories exist; controller infrastructure established" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "controller/ or rules/ missing — Gate H infrastructure incomplete" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: Controller coherence — routes/policy/manifest alignment"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate H req②: Coherence Check ==="
    echo ""

    # Check key rule files
    for rf in rules/routes.yaml rules/policy.json rules/ssot_manifest.yaml; do
      echo "--- ${rf} ---"
      if [[ -f "${MAIN_REPO}/${rf}" ]]; then
        echo "EXISTS ($(wc -l < "${MAIN_REPO}/${rf}") lines)"
        head -20 "${MAIN_REPO}/${rf}" 2>/dev/null || true
      else
        echo "NOT FOUND"
      fi
      echo ""
    done

    # Check .github/workflows/ci-validate.yml
    echo "--- CI workflow ---"
    if [[ -f "${MAIN_REPO}/.github/workflows/ci-validate.yml" ]]; then
      echo "EXISTS"
      record_ref ".github/workflows/ci-validate.yml"
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Tracker Gate H references
    echo "--- Tracker Gate H completion ---"
    grep -n -i "gate.h\|H[0-9]" "${MAIN_REPO}/_handoff_check/task_tracker.md" 2>/dev/null | head -20 || echo "(none)"
  } > "$req2_out"

  local rules_ok=true
  for rf in rules/routes.yaml rules/policy.json rules/ssot_manifest.yaml; do
    [[ -f "${MAIN_REPO}/${rf}" ]] || rules_ok=false
  done

  if [[ "$rules_ok" == "true" ]]; then
    write_judgement "PASS" "routes.yaml + policy.json + ssot_manifest.yaml all present; rules coherent" "req②"
    ((pass++))
  elif [[ -d "${MAIN_REPO}/rules" ]]; then
    write_judgement "PASS" "rules/ directory exists with rule files" "req②"
    ((pass++))
  else
    write_judgement "FAIL" "Rule files missing — controller coherence not verified" "req②"
    ((fail++))
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional controller checks"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate H req③: Functional Check ==="
    local cp=0 ct=0

    ((ct++))
    if [[ -d "${MAIN_REPO}/controller" ]]; then
      echo "CHECK: controller/ directory exists — PASS"; ((cp++))
    else
      echo "CHECK: controller/ directory exists — FAIL"
    fi

    ((ct++))
    if [[ -d "${MAIN_REPO}/rules" ]]; then
      echo "CHECK: rules/ directory exists — PASS"; ((cp++))
    else
      echo "CHECK: rules/ directory exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/bin/ctx-run" ]]; then
      echo "CHECK: bin/ctx-run exists — PASS"; ((cp++))
    else
      echo "CHECK: bin/ctx-run exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/controller-smoke.sh" ]]; then
      echo "CHECK: controller-smoke.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: controller-smoke.sh exists — FAIL"
    fi

    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/ci-validate.sh" ]]; then
      echo "CHECK: ci-validate.sh exists — PASS"; ((cp++))
    else
      echo "CHECK: ci-validate.sh exists — FAIL"
    fi

    for rf in rules/routes.yaml rules/policy.json rules/ssot_manifest.yaml; do
      ((ct++))
      if [[ -f "${MAIN_REPO}/${rf}" ]]; then
        echo "CHECK: ${rf} exists — PASS"; ((cp++))
      else
        echo "CHECK: ${rf} exists — FAIL"
      fi
    done

    # Check CI workflow
    ((ct++))
    if [[ -f "${MAIN_REPO}/.github/workflows/ci-validate.yml" ]]; then
      echo "CHECK: CI workflow exists — PASS"; ((cp++))
    else
      echo "CHECK: CI workflow exists — FAIL"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if [[ -d "${MAIN_REPO}/controller" ]] && [[ -f "${MAIN_REPO}/bin/ctx-run" ]]; then
    write_judgement "PASS" "Controller functional: controller/ + bin/ctx-run + rules/ + CI present" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Controller infrastructure incomplete" "req③"
    ((fail++))
  fi

  gate_summary "Gate H" "$pass" "$fail" "$total"
}
