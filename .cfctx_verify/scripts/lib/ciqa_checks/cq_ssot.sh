#!/usr/bin/env bash
# cq_ssot.sh — CQ-SSOT: SSOT Drift check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: kit SSOT/ files match repo _handoff_check/ files (sha256)
#
# @check_key: ssot
# @check_id: CQ-SSOT
# @check_display: SSOT Drift
# @check_order: 30

run_check() {
  local verdict="PASS"
  local fail_count=0
  local match_count=0
  local details=""

  # SSOT files to compare
  local ssot_files=("cf_handoff_prompt.md" "cf_update_runbook.md" "cf_task_tracker_v5.md")

  local kit_ssot_dir="${KIT_ROOT}/SSOT"
  local repo_ssot_dir="${MAIN_REPO}/_handoff_check"

  # Pre-checks
  if [[ -z "${MAIN_REPO:-}" ]]; then
    details+="FATAL: MAIN_REPO not set"$'\n'
    echo "$details"
    return 1
  fi

  if [[ ! -d "$kit_ssot_dir" ]]; then
    details+="FATAL: Kit SSOT directory not found: ${kit_ssot_dir}"$'\n'
    echo "$details"
    return 1
  fi

  if [[ ! -d "$repo_ssot_dir" ]]; then
    details+="FATAL: Repo _handoff_check directory not found: ${repo_ssot_dir}"$'\n'
    echo "$details"
    return 1
  fi

  for sf in "${ssot_files[@]}"; do
    local kit_file="${kit_ssot_dir}/${sf}"
    local repo_file="${repo_ssot_dir}/${sf}"

    if [[ ! -f "$kit_file" ]]; then
      details+="  DRIFT: ${sf} — kit file MISSING"$'\n'
      ((fail_count++)) || true
      continue
    fi

    if [[ ! -f "$repo_file" ]]; then
      details+="  DRIFT: ${sf} — repo file MISSING"$'\n'
      ((fail_count++)) || true
      continue
    fi

    local kit_sha repo_sha
    kit_sha="$(sha256sum "$kit_file" | awk '{print $1}')"
    repo_sha="$(sha256sum "$repo_file" | awk '{print $1}')"

    if [[ "$kit_sha" == "$repo_sha" ]]; then
      details+="  MATCH: ${sf} (sha256: ${kit_sha:0:16})"$'\n'
      ((match_count++)) || true
    else
      details+="  DRIFT: ${sf} — kit=${kit_sha:0:16} repo=${repo_sha:0:16}"$'\n'
      ((fail_count++)) || true
    fi
  done

  details+=""$'\n'
  details+="SSOT comparison: ${match_count}/${#ssot_files[@]} match, ${fail_count} drift"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
