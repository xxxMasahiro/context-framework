#!/usr/bin/env bash
# cq_regression.sh — CQ-REG: Regression Detection check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: no check that was PASS in baseline has become FAIL
#
# @check_key: regression
# @check_id: CQ-REG
# @check_display: Regression Detection
# @check_order: 99
#
# Uses: CIQA_BASELINE_DIR (absolute path to baseline directory)
#       KIT_ROOT
#
# Baseline file: ${CIQA_BASELINE_DIR}/last_run.json
# Format (JSON):
#   { "checks": { "CQ-TRK": "PASS", "CQ-EVC": "PASS", ... },
#     "timestamp": "2026-02-04T06:00:00Z" }
#
# First run (no baseline): PASS with DIAG note

run_check() {
  local verdict="PASS"
  local details=""
  local baseline_dir="${CIQA_BASELINE_DIR_ABS:-${CIQA_BASELINE_DIR}}"
  local baseline_file="${baseline_dir}/last_run.json"

  # --- Check if baseline exists ---
  if [[ ! -f "$baseline_file" ]]; then
    details+="DIAG: No baseline found at ${baseline_file}"$'\n'
    details+="First run — no regression possible. PASS by default."$'\n'
    echo "$details"
    return 0
  fi

  # --- Read current run results from environment ---
  # CIQA_CURRENT_RESULTS is set by ciqa_runner.sh before calling CQ-REG
  # Format: "CQ-TRK:PASS CQ-EVC:PASS CQ-SSOT:FAIL ..."
  if [[ -z "${CIQA_CURRENT_RESULTS:-}" ]]; then
    details+="DIAG: No current results provided (CIQA_CURRENT_RESULTS empty)"$'\n'
    details+="Cannot compare — treating as PASS."$'\n'
    echo "$details"
    return 0
  fi

  # --- Parse baseline JSON (minimal jq-free parser) ---
  # Extract check:verdict pairs from baseline
  local -A baseline_results=()
  local baseline_ts=""

  # Parse "CQ-XXX": "PASS|FAIL" pairs
  while IFS= read -r line; do
    local key val
    if [[ "$line" =~ \"(CQ-[A-Z]+)\"[[:space:]]*:[[:space:]]*\"(PASS|FAIL|DIAG)\" ]]; then
      key="${BASH_REMATCH[1]}"
      val="${BASH_REMATCH[2]}"
      baseline_results["$key"]="$val"
    fi
    if [[ "$line" =~ \"timestamp\"[[:space:]]*:[[:space:]]*\"([^\"]+)\" ]]; then
      baseline_ts="${BASH_REMATCH[1]}"
    fi
  done < "$baseline_file"

  details+="Baseline: ${baseline_file}"$'\n'
  details+="Baseline timestamp: ${baseline_ts:-unknown}"$'\n'
  details+="Baseline checks: ${#baseline_results[@]}"$'\n'
  details+=""$'\n'

  # --- Parse current results ---
  local -A current_results=()
  for pair in ${CIQA_CURRENT_RESULTS}; do
    local ck="${pair%%:*}"
    local vd="${pair##*:}"
    current_results["$ck"]="$vd"
  done

  # --- Compare: detect regressions (PASS→FAIL) ---
  local regression_count=0
  local checked_count=0

  for ck in "${!baseline_results[@]}"; do
    local base_v="${baseline_results[$ck]}"
    local curr_v="${current_results[$ck]:-SKIP}"

    if [[ "$curr_v" == "SKIP" ]]; then
      details+="  ${ck}: baseline=${base_v}, current=NOT_RUN (skipped)"$'\n'
      continue
    fi

    ((checked_count++)) || true

    if [[ "$base_v" == "PASS" && "$curr_v" == "FAIL" ]]; then
      details+="  REGRESSION: ${ck}: PASS → FAIL"$'\n'
      ((regression_count++)) || true
      verdict="FAIL"
    else
      details+="  OK: ${ck}: ${base_v} → ${curr_v}"$'\n'
    fi
  done

  # Check for new checks not in baseline (informational only)
  for ck in "${!current_results[@]}"; do
    if [[ -z "${baseline_results[$ck]:-}" ]]; then
      details+="  NEW: ${ck}: ${current_results[$ck]} (not in baseline)"$'\n'
    fi
  done

  details+=""$'\n'
  details+="Compared: ${checked_count} checks, ${regression_count} regressions"$'\n'

  if [[ "$regression_count" -gt 0 ]]; then
    details+="FAIL: ${regression_count} regression(s) detected"$'\n'
  else
    details+="No regressions detected."$'\n'
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
