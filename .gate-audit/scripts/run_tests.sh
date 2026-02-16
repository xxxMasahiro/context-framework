#!/usr/bin/env bash
# run_tests.sh — Test runner for Phase 1/2/3
# Usage: bash scripts/run_tests.sh [PHASE]
#   PHASE = 1 | 2 | 3 | all (default: all)
#
# Each phase produces evidence in logs/evidence/ and returns:
#   0 = PASS, 1 = FAIL

set -euo pipefail

# ── Resolve paths ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export KIT_ROOT

# ── Source libraries ─────────────────────────────────────────
source "${SCRIPT_DIR}/lib/evidence.sh"
source "${SCRIPT_DIR}/lib/gate_registry.sh"

# ── Timestamp helpers ────────────────────────────────────────
_rt_ts_label() { date -u +"%Y%m%d-%H%M%S"; }
_rt_ts_jst()   { TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S %Z'; }
_rt_ts_utc()   { date -u '+%Y-%m-%dT%H:%M:%SZ'; }

# ── Evidence writer ──────────────────────────────────────────
# Usage: _rt_save_evidence <label> <content>
# Returns: evidence file path (absolute)
_rt_save_evidence() {
  local label="$1"
  local content="$2"
  local ts
  ts="$(_rt_ts_label)"
  local efile="${KIT_ROOT}/logs/evidence/${ts}_${label}.txt"
  mkdir -p "$(dirname "$efile")"
  echo "$content" > "$efile"
  echo "$efile"
}

# ── sha256 first 16 chars ───────────────────────────────────
_rt_sha16() {
  sha256sum "$1" | cut -c1-16
}

# ── Phase 1: 共通（環境・スモーク）───────────────────────────
run_phase1() {
  echo "=== Phase 1: 共通（環境・スモーク）==="
  echo ""

  local fail=0
  local output=""

  # --- 1a: 環境前提確認 ---
  local section="--- 1a: 環境前提確認 ---"
  output+="${section}"$'\n'

  # Kit is repo-external
  local kit_git_top
  kit_git_top="$(cd "$KIT_ROOT" && git rev-parse --show-toplevel 2>/dev/null)" || kit_git_top=""
  MAIN_REPO="${MAIN_REPO:-$(discover_main_repo || true)}"
  export MAIN_REPO

  if [[ -z "$MAIN_REPO" ]]; then
    output+="FATAL: Main repo not found"$'\n'
    fail=1
  fi

  if [[ -n "$kit_git_top" && "$kit_git_top" != *"context-framework"* ]]; then
    output+="Kit location: $KIT_ROOT (repo-external): PASS"$'\n'
  elif [[ -n "$kit_git_top" && "$kit_git_top" == *"context-framework"* ]]; then
    output+="Kit location: FAIL (inside main repo!)"$'\n'
    fail=1
  else
    output+="Kit location: $KIT_ROOT (not a git repo or standalone): PASS"$'\n'
  fi

  # Main repo clean check
  if [[ -n "$MAIN_REPO" ]]; then
    local repo_status
    repo_status="$(cd "$MAIN_REPO" && git status --porcelain 2>/dev/null)" || repo_status=""
    if [[ -z "$repo_status" ]]; then
      output+="Main repo status: clean: PASS"$'\n'
    else
      output+="Main repo status: dirty (has changes): WARN"$'\n'
    fi
    local head_sha
    head_sha="$(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null)" || head_sha="N/A"
    output+="Main repo HEAD: ${head_sha}"$'\n'
  fi

  # Repo Lock check
  if [[ -n "$MAIN_REPO" && -f "${MAIN_REPO}/tools/guard.sh" ]]; then
    local lock_result
    lock_result="$(cd "$MAIN_REPO" && bash tools/guard.sh --check 2>&1)" || lock_result="FAIL: ${lock_result:-unknown}"
    if [[ "$lock_result" == FAIL:* ]]; then
      output+="Repo Lock (guard.sh): WARN (${lock_result})"$'\n'
    else
      output+="Repo Lock (guard.sh): OK"$'\n'
    fi
  else
    output+="Repo Lock: guard.sh not found (skipped)"$'\n'
  fi

  # Scripts read-only check (no git push/commit/write in gate scripts)
  local write_cmds
  write_cmds="$(grep -rlE 'git (push|commit|checkout|reset)' "${KIT_ROOT}/scripts/lib/gate_"*.sh 2>/dev/null)" || write_cmds=""
  if [[ -z "$write_cmds" ]]; then
    output+="Scripts read-only check: PASS (no write commands in gate scripts)"$'\n'
  else
    output+="Scripts read-only check: FAIL (write commands found)"$'\n'
    fail=1
  fi

  # OS-level read-only mount verification (optional — requires NOPASSWD for mount/umount)
  local ro_template="${KIT_ROOT}/tools/verify_ro_mount_nopasswd_template_v5.sh"
  if [[ -f "$ro_template" ]]; then
    if sudo -n -k /usr/bin/mount --help >/dev/null 2>&1; then
      local ro_out
      ro_out="$(CORE="${MAIN_REPO:-}" bash "$ro_template" 2>&1)" || true
      if echo "$ro_out" | grep -q "RESULT: PASS"; then
        output+="RO mount verification: PASS (OS-level bind mount ro/rw/umount cycle OK)"$'\n'
      else
        output+="RO mount verification: FAIL (see tools/verify_ro_mount_nopasswd_template_v5.sh)"$'\n'
        fail=1
      fi
    else
      output+="RO mount verification: SKIP (sudo NOPASSWD not configured for mount)"$'\n'
    fi
  else
    output+="RO mount verification: SKIP (template not found)"$'\n'
  fi

  output+=""$'\n'

  # --- 1b: 最小スモーク（verify_all.sh）---
  local section2="--- 1b: 最小スモーク（verify_all.sh）---"
  output+="${section2}"$'\n'

  local smoke_out
  smoke_out="$(bash "${KIT_ROOT}/scripts/verify_all.sh" 2>&1)" || {
    output+="verify_all.sh: FAIL (exit code $?)"$'\n'
    fail=1
  }

  # Check for "ALL GATES PASS" in output
  if echo "$smoke_out" | grep -q "ALL GATES PASS"; then
    output+="verify_all.sh: ALL GATES PASS: PASS"$'\n'
  else
    output+="verify_all.sh: Not all gates passed: FAIL"$'\n'
    fail=1
  fi

  # Count gates from output (dynamic — uses gate_registry.sh)
  local _rt_gate_ids
  _rt_gate_ids="$(gr_list_gate_ids)"
  local _rt_gate_count
  _rt_gate_count="$(echo "$_rt_gate_ids" | wc -l)"
  local _rt_gate_pattern
  _rt_gate_pattern="$(echo "$_rt_gate_ids" | tr '\n' '|' | sed 's/|$//')"
  local pass_count
  pass_count="$(echo "$smoke_out" | grep -cE "Gate (${_rt_gate_pattern}): PASS" || true)"
  output+="Gates passed: ${pass_count}/${_rt_gate_count}"$'\n'

  output+=""$'\n'

  # --- Judgement ---
  local verdict="PASS"
  if [[ "$fail" -gt 0 ]]; then
    verdict="FAIL"
  fi

  local full_content
  full_content="=== Phase 1: 共通（環境・スモーク）===
Timestamp (JST): $(_rt_ts_jst)
Timestamp (UTC): $(_rt_ts_utc)

${output}
--- OVERALL JUDGEMENT ---
RESULT: ${verdict}
REASON: Environment prerequisites and smoke test (verify_all.sh)
"
  local efile
  efile="$(_rt_save_evidence "test_phase1" "$full_content")"
  local sha16
  sha16="$(_rt_sha16 "$efile")"

  echo "$output"
  echo "RESULT: ${verdict}"
  echo "Evidence: ${efile}"
  echo "sha256(16): ${sha16}"
  echo ""

  PHASE1_VERDICT="$verdict"
  PHASE1_EVIDENCE="$efile"
  PHASE1_SHA16="$sha16"

  if [[ "$verdict" == "FAIL" ]]; then return 1; fi
  return 0
}

# ── Phase 2: Gate固有（個別Gate検証）─────────────────────────
run_phase2() {
  echo "=== Phase 2: Gate固有（個別Gate検証）==="
  echo ""

  local fail=0
  local output=""

  MAIN_REPO="${MAIN_REPO:-$(discover_main_repo || true)}"
  export MAIN_REPO

  # Run each gate individually via verify_gate.sh (dynamic — uses gate_registry.sh)
  local gates=()
  while IFS= read -r _gid; do
    gates+=("$_gid")
  done < <(gr_list_gate_ids)

  if [[ ${#gates[@]} -eq 0 ]]; then
    output+="FATAL: No gates discovered (gr_list_gate_ids returned empty or failed)."$'\n'
    fail=1
  fi

  local gate_pass=0
  local gate_fail=0

  for g in "${gates[@]}"; do
    local gout
    gout="$(bash "${KIT_ROOT}/scripts/verify_gate.sh" "$g" 2>&1)" || true
    # verify_gate.sh prints "  Gate X: PASS" in its summary section
    local gresult
    gresult="$(echo "$gout" | grep -oP "Gate ${g}: \K(PASS|FAIL)" | head -1)" || gresult="FAIL"

    if [[ "$gresult" == "PASS" ]]; then
      output+="Gate ${g}: PASS"$'\n'
      ((gate_pass++)) || true
    else
      output+="Gate ${g}: FAIL"$'\n'
      ((gate_fail++)) || true
      fail=1
    fi
  done

  output+=""$'\n'
  output+="Total: ${gate_pass} PASS / ${gate_fail} FAIL (out of ${#gates[@]} gates)"$'\n'

  local verdict="PASS"
  if [[ "$fail" -gt 0 ]]; then
    verdict="FAIL"
  fi

  local full_content
  full_content="=== Phase 2: Gate固有（個別Gate検証）===
Timestamp (JST): $(_rt_ts_jst)
Timestamp (UTC): $(_rt_ts_utc)

${output}
--- OVERALL JUDGEMENT ---
RESULT: ${verdict}
REASON: Individual gate verification ($(echo "${gates[*]}") via verify_gate.sh)
"
  local efile
  efile="$(_rt_save_evidence "test_phase2" "$full_content")"
  local sha16
  sha16="$(_rt_sha16 "$efile")"

  echo "$output"
  echo "RESULT: ${verdict}"
  echo "Evidence: ${efile}"
  echo "sha256(16): ${sha16}"
  echo ""

  PHASE2_VERDICT="$verdict"
  PHASE2_EVIDENCE="$efile"
  PHASE2_SHA16="$sha16"

  if [[ "$verdict" == "FAIL" ]]; then return 1; fi
  return 0
}

# ── Phase 3: 横断E2E（全体導線＋再現性）─────────────────────
run_phase3() {
  echo "=== Phase 3: 横断E2E（全体導線＋再現性）==="
  echo ""

  local fail=0
  local output=""

  MAIN_REPO="${MAIN_REPO:-$(discover_main_repo || true)}"
  export MAIN_REPO

  # --- 3a: E2E 全体導線 ---
  output+="--- 3a: E2E 全体導線 ---"$'\n'

  # Step 1: repo check
  local head_sha
  head_sha="$(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null)" || head_sha="N/A"
  output+="Main repo HEAD: ${head_sha}"$'\n'

  # Step 2: Kit structure check
  local required_files=(
    "SSOT/handoff_prompt.md"
    "SSOT/update_runbook.md"
    "SSOT/task_tracker.md"
    "scripts/verify_all.sh"
    "scripts/verify_gate.sh"
    "scripts/generate_handoff.sh"
    "scripts/run_tests.sh"
    "scripts/lib/evidence.sh"
    "scripts/lib/handoff_builder.sh"
    "scripts/lib/tracker_updater.sh"
    "tasks/verify_task_tracker.md"
    "tasks/test_task_tracker.md"
    "kit"
  )
  local struct_pass=0
  local struct_fail=0
  for f in "${required_files[@]}"; do
    if [[ -f "${KIT_ROOT}/${f}" ]]; then
      output+="  EXISTS: ${f}"$'\n'
      ((struct_pass++)) || true
    else
      output+="  MISSING: ${f}"$'\n'
      ((struct_fail++)) || true
      fail=1
    fi
  done
  output+="Kit structure: ${struct_pass}/${#required_files[@]} files found"$'\n'
  output+=""$'\n'

  # Step 3: SSOT comparison
  output+="--- 3b: SSOT比較 ---"$'\n'
  local ssot_files=("handoff_prompt.md" "update_runbook.md" "task_tracker.md")
  local ssot_match=0
  local ssot_total=0
  for sf in "${ssot_files[@]}"; do
    ((ssot_total++)) || true
    local kit_f="${KIT_ROOT}/SSOT/${sf}"
    local repo_f="${MAIN_REPO}/_handoff_check/${sf}"
    if [[ -f "$kit_f" && -f "$repo_f" ]]; then
      local h1 h2
      h1="$(sha256sum "$kit_f" | awk '{print $1}')"
      h2="$(sha256sum "$repo_f" | awk '{print $1}')"
      if [[ "$h1" == "$h2" ]]; then
        output+="  ${sf}: MATCH"$'\n'
        ((ssot_match++)) || true
      else
        output+="  ${sf}: DIFFER"$'\n'
        fail=1
      fi
    else
      output+="  ${sf}: FILE(S) NOT FOUND"$'\n'
      fail=1
    fi
  done
  output+="SSOT comparison: ${ssot_match}/${ssot_total} match"$'\n'
  output+=""$'\n'

  # Step 4: verify_all.sh
  output+="--- 3c: verify_all.sh 実行 ---"$'\n'
  local va_out
  va_out="$(bash "${KIT_ROOT}/scripts/verify_all.sh" 2>&1)" || true
  if echo "$va_out" | grep -q "ALL GATES PASS"; then
    output+="verify_all.sh: ALL GATES PASS"$'\n'
  else
    output+="verify_all.sh: FAIL"$'\n'
    fail=1
  fi
  output+=""$'\n'

  # Step 5: handoff generation
  output+="--- 3d: handoff 生成確認 ---"$'\n'
  if ! bash "${KIT_ROOT}/scripts/generate_handoff.sh" > /dev/null 2>&1; then
    output+="handoff generation: WARN (generate_handoff.sh failed)"$'\n'
  fi
  if [[ -f "${KIT_ROOT}/handoff/latest.md" ]]; then
    output+="handoff/latest.md: EXISTS"$'\n'
  else
    output+="handoff/latest.md: MISSING"$'\n'
    fail=1
  fi
  output+=""$'\n'

  # --- 3e: 再現性確認 ---
  output+="--- 3e: 再現性確認 ---"$'\n'
  # Build dynamic gate pattern from registry
  local _p3_gate_ids _p3_gate_pattern
  _p3_gate_ids="$(gr_list_gate_ids)"
  _p3_gate_pattern="$(echo "$_p3_gate_ids" | tr '\n' '|' | sed 's/|$//')"
  local run1_summary run2_summary
  run1_summary="$(bash "${KIT_ROOT}/scripts/verify_all.sh" 2>&1 | grep -E "Gate (${_p3_gate_pattern}):" | sort)" || true
  run2_summary="$(bash "${KIT_ROOT}/scripts/verify_all.sh" 2>&1 | grep -E "Gate (${_p3_gate_pattern}):" | sort)" || true
  if [[ "$run1_summary" == "$run2_summary" ]]; then
    output+="Reproducibility: Two runs produce identical results: PASS"$'\n'
  else
    output+="Reproducibility: Results differ: FAIL"$'\n'
    fail=1
  fi

  output+=""$'\n'

  local verdict="PASS"
  if [[ "$fail" -gt 0 ]]; then
    verdict="FAIL"
  fi

  local full_content
  full_content="=== Phase 3: 横断E2E（全体導線＋再現性）===
Timestamp (JST): $(_rt_ts_jst)
Timestamp (UTC): $(_rt_ts_utc)

${output}
--- OVERALL JUDGEMENT ---
RESULT: ${verdict}
REASON: E2E full pipeline + reproducibility verification
"
  local efile
  efile="$(_rt_save_evidence "test_phase3" "$full_content")"
  local sha16
  sha16="$(_rt_sha16 "$efile")"

  echo "$output"
  echo "RESULT: ${verdict}"
  echo "Evidence: ${efile}"
  echo "sha256(16): ${sha16}"
  echo ""

  PHASE3_VERDICT="$verdict"
  PHASE3_EVIDENCE="$efile"
  PHASE3_SHA16="$sha16"

  if [[ "$verdict" == "FAIL" ]]; then return 1; fi
  return 0
}

# ── Main ─────────────────────────────────────────────────────
main() {
  local phase="${1:-all}"

  echo "=============================================="
  echo " Test Runner — Phase: ${phase}"
  echo "=============================================="
  echo ""

  local exit_code=0

  # Init globals for per-phase results
  PHASE1_VERDICT="" ; PHASE1_EVIDENCE="" ; PHASE1_SHA16=""
  PHASE2_VERDICT="" ; PHASE2_EVIDENCE="" ; PHASE2_SHA16=""
  PHASE3_VERDICT="" ; PHASE3_EVIDENCE="" ; PHASE3_SHA16=""

  case "$phase" in
    1)
      run_phase1 || exit_code=1
      ;;
    2)
      run_phase2 || exit_code=1
      ;;
    3)
      run_phase3 || exit_code=1
      ;;
    all)
      run_phase1 || exit_code=1
      echo "----------------------------------------------"
      run_phase2 || exit_code=1
      echo "----------------------------------------------"
      run_phase3 || exit_code=1
      ;;
    *)
      echo "ERROR: Unknown phase '${phase}'. Supported: 1, 2, 3, all" >&2
      exit 1
      ;;
  esac

  echo "=============================================="
  echo " TEST SUMMARY"
  echo "=============================================="
  echo ""

  # Print per-phase summary (only for phases that ran)
  local total_pass=0
  local total_fail=0

  for p in 1 2 3; do
    local vvar="PHASE${p}_VERDICT"
    local evar="PHASE${p}_EVIDENCE"
    local svar="PHASE${p}_SHA16"
    local v="${!vvar:-}"
    local e="${!evar:-}"
    local s="${!svar:-}"

    if [[ -n "$v" ]]; then
      local relpath="${e#"${KIT_ROOT}/"}"
      printf "  Phase %s: %-4s  Evidence: %s  sha256(16): %s\n" "$p" "$v" "$relpath" "$s"
      if [[ "$v" == "PASS" ]]; then
        ((total_pass++)) || true
      else
        ((total_fail++)) || true
      fi
    fi
  done

  echo ""
  local phases_run=$((total_pass + total_fail))
  echo "Total: ${total_pass} PASS / ${total_fail} FAIL (out of ${phases_run} phases)"
  echo ""

  if [[ "$total_fail" -eq 0 ]]; then
    echo "OVERALL: ALL PHASES PASS"
  else
    echo "OVERALL: SOME PHASES FAILED"
  fi

  echo ""
  echo "Timestamp: $(_rt_ts_jst)"
  echo "=============================================="

  return "$exit_code"
}

main "$@"
