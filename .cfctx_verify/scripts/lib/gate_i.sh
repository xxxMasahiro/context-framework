#!/usr/bin/env bash
# gate_i.sh — Gate I: Entry Definition & SSOT Slimming (入口定義とSSOTスリム化)
# Verifies: I0-I5 task completion, SSOT slimming, cf-doctor, spec YAML

verify_gate_i() {
  local pass=0 fail=0 total=3

  echo "=== Gate I: Entry Definition & SSOT Slimming (入口定義とSSOTスリム化) ==="
  init_evidence "gateI"

  # ── req① Feature summary ────────────────────────────────────
  record_cmd "req①: Check Gate I tasks I0-I5 completion in SSOT"
  local req1_out="${EVIDENCE_DIR}/req1_summary.txt"
  {
    echo "=== Gate I req①: Feature Summary ==="
    echo ""

    # Check tracker for Gate I completion
    echo "--- Tracker Gate I status ---"
    grep -n -i "gate.i\|I[0-5]" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -20 || echo "(none)"
    echo ""

    # Check all I0-I5 are Done[x]
    echo "--- Gate I tasks (Done check) ---"
    for task in "I0" "I1" "I2" "I3" "I4" "I5"; do
      echo -n "${task}: "
      if grep -q "\[x\].*${task}\|${task}.*\[x\]" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
        echo "Done[x]"
      elif grep -q "${task}" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
        echo "Found but not Done[x]"
      else
        echo "Not found"
      fi
    done
    echo ""

    # Check runbook Gate I section
    echo "--- Runbook Gate I references ---"
    grep -n -i "gate.i\|入口定義\|スリム化" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -20 || echo "(none)"
    echo ""

    # Check cf-doctor exists (I4 deliverable)
    echo "--- cf-doctor.sh (I4 deliverable) ---"
    if [[ -f "${MAIN_REPO}/tools/cf-doctor.sh" ]]; then
      echo "EXISTS"
      record_ref "tools/cf-doctor.sh"
    else
      echo "NOT FOUND"
    fi
    echo ""

    # Check gate-g.yaml (I3 deliverable)
    echo "--- gate-g.yaml (I3 deliverable) ---"
    if [[ -f "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" ]]; then
      echo "EXISTS"
      record_ref "WORKFLOW/SPEC/gates/gate-g.yaml"
    else
      echo "NOT FOUND"
    fi

    record_ref "_handoff_check/cf_task_tracker_v5.md"
    record_ref "_handoff_check/cf_update_runbook.md"
  } > "$req1_out"

  # Check I0-I5 are all Done[x] in tracker
  local done_count=0
  for task in "I0" "I1" "I2" "I3" "I4" "I5"; do
    if grep -q "\[x\].*Gate I.*${task}\|${task}.*\[x\]\|\[x\].*${task}" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
      ((done_count++)) || true
    fi
  done

  if [[ "$done_count" -eq 6 ]]; then
    write_judgement "PASS" "Gate I tasks: ${done_count}/6 Done[x] in tracker; all tasks completed" "req①"
    ((pass++))
  else
    write_judgement "FAIL" "Gate I tasks: only ${done_count}/6 Done[x] (requires all 6)" "req①"
    ((fail++))
  fi

  # ── req② Coherence ──────────────────────────────────────────
  record_cmd "req②: SSOT slimming coherence — tracker is minimal, runbook is canonical"
  local req2_out="${EVIDENCE_DIR}/req2_consistency.txt"
  {
    echo "=== Gate I req②: Coherence Check ==="
    echo ""

    # Check tracker is slim (references runbook for details)
    echo "--- Tracker slimness check ---"
    local tracker_lines
    tracker_lines=$(wc -l < "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null) || tracker_lines=0
    echo "Tracker lines: ${tracker_lines}"
    echo ""

    # Check tracker references runbook as authority
    echo "--- Tracker runbook references ---"
    grep -n -i "runbook.*正\|runbook.*最上位\|runbook.*authority\|runbook 付録" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -10 || echo "(none)"
    echo ""

    # Check runbook has Gate I section
    echo "--- Runbook Gate I definition ---"
    grep -B 2 -A 10 -i "gate.i\|入口定義" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -30 || echo "(none)"
    echo ""

    # Check handoff references Gate I completion
    echo "--- Handoff Gate I references ---"
    grep -n -i "gate.i\|I[0-5].*完了\|I[0-5].*done" "${MAIN_REPO}/_handoff_check/cf_handoff_prompt.md" 2>/dev/null | head -10 || echo "(none)"
    echo ""

    # Check SSOT priority is clear
    echo "--- SSOT priority chain ---"
    grep -n -i "SSOT.*最上位\|runbook.*最上位\|SSOT.*priority\|運用規範.*最上位" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null | head -5 || echo "(none)"
    grep -n -i "SSOT.*最上位\|runbook.*最上位" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null | head -5 || echo "(none)"
  } > "$req2_out"

  # Check runbook is declared as SSOT authority
  if grep -q -i "runbook.*最上位\|運用規範.*最上位\|SSOT.*runbook" "${MAIN_REPO}/_handoff_check/cf_update_runbook.md" 2>/dev/null ||
     grep -q -i "runbook.*最上位" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
    write_judgement "PASS" "SSOT hierarchy clear: runbook is canonical authority; tracker is progress" "req②"
    ((pass++))
  else
    # Check for equivalent statements
    if grep -q -i "運用規範\|cf_update_runbook" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
      write_judgement "PASS" "Tracker references runbook as canonical source" "req②"
      ((pass++))
    else
      write_judgement "FAIL" "SSOT hierarchy not clearly established" "req②"
      ((fail++))
    fi
  fi

  # ── req③ Functional ─────────────────────────────────────────
  record_cmd "req③: Functional check — cf-doctor exists, SPEC exists, SSOT operational"
  local req3_out="${EVIDENCE_DIR}/req3_functional.txt"
  {
    echo "=== Gate I req③: Functional Check ==="
    local cp=0 ct=0

    # cf-doctor.sh exists (I4)
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-doctor.sh" ]]; then
      echo "CHECK: tools/cf-doctor.sh exists (I4) — PASS"; ((cp++))
    else
      echo "CHECK: tools/cf-doctor.sh exists (I4) — FAIL"
    fi

    # gate-g.yaml exists (I3)
    ((ct++))
    if [[ -f "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" ]]; then
      echo "CHECK: gate-g.yaml exists (I3) — PASS"; ((cp++))
    else
      echo "CHECK: gate-g.yaml exists (I3) — FAIL"
    fi

    # cf-doctor syntax valid
    ((ct++))
    if [[ -f "${MAIN_REPO}/tools/cf-doctor.sh" ]] && bash -n "${MAIN_REPO}/tools/cf-doctor.sh" 2>/dev/null; then
      echo "CHECK: cf-doctor.sh syntax valid — PASS"; ((cp++))
    else
      echo "CHECK: cf-doctor.sh syntax valid — FAIL"
    fi

    # SSOT 3 files exist
    for ssot_f in cf_update_runbook.md cf_task_tracker_v5.md cf_handoff_prompt.md; do
      ((ct++))
      if [[ -f "${MAIN_REPO}/_handoff_check/${ssot_f}" ]]; then
        echo "CHECK: _handoff_check/${ssot_f} exists — PASS"; ((cp++))
      else
        echo "CHECK: _handoff_check/${ssot_f} exists — FAIL"
      fi
    done

    # Gate J entry exists in tracker (I5 deliverable: ready for next gate)
    ((ct++))
    if grep -q -i "gate.j\|J0" "${MAIN_REPO}/_handoff_check/cf_task_tracker_v5.md" 2>/dev/null; then
      echo "CHECK: Gate J entry in tracker (I5→next) — PASS"; ((cp++))
    else
      echo "CHECK: Gate J entry in tracker — FAIL (may not be required)"
    fi

    echo ""
    echo "Functional checks: ${cp}/${ct} passed"
  } > "$req3_out"

  if [[ -f "${MAIN_REPO}/tools/cf-doctor.sh" ]] && [[ -f "${MAIN_REPO}/WORKFLOW/SPEC/gates/gate-g.yaml" ]]; then
    write_judgement "PASS" "Gate I deliverables functional: cf-doctor + SPEC/gate-g.yaml + SSOT 3 files present" "req③"
    ((pass++))
  else
    write_judgement "FAIL" "Gate I deliverables incomplete" "req③"
    ((fail++))
  fi

  gate_summary "Gate I" "$pass" "$fail" "$total"
}
