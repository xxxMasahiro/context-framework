#!/usr/bin/env bash
# _template.sh — Custom self-check plugin template
# ================================================================
# Copy this file to create a new check plugin:
#   cp _template.sh cq_mycheck.sh
#
# Required: define the four @metadata headers below and the
#           run_check() function.
#
# The runner discovers plugins by globbing cq_*.sh in this
# directory and parsing the @metadata headers from the first
# 30 lines.
# ================================================================
#
# @check_key: mycheck
# @check_id: CQ-MYCK
# @check_display: My Custom Check
# @check_order: 50
#
# Contract:
#   - run_check() is the only required function
#   - stdout  → captured as check details (saved to Evidence)
#   - exit 0  → PASS
#   - exit 1  → FAIL
#
# Available environment variables (set by self-check.sh):
#   KIT_ROOT              — verification kit root directory
#   MAIN_REPO             — main repository path (read-only!)
#   SC_CHECK_ID           — this check's ID (e.g. "CQ-MYCK")
#   SC_EVIDENCE_DIR       — evidence output directory
#   SC_BASELINE_DIR_ABS   — regression baseline directory (absolute)
#
# Available helper functions (from self_check_common.sh):
#   sc_ts_jst             — current JST timestamp
#   sc_ts_utc             — current UTC timestamp
#   sc_ts_label           — timestamp for filenames (YYYYMMDD-HHMMSS)
#   sc_emit_header        — emit evidence header
#   sc_emit_verdict       — emit verdict line
#   sc_count_checked      — count [x] items in a tracker file
#   sc_count_unchecked    — count [ ] items in a tracker file
#   sc_sha16              — sha256sum first 16 hex chars
#
# Configuration:
#   Add custom config keys to config/self-check.conf as needed.
#   Access them via SC_* environment variables after loading.
# ================================================================

run_check() {
  local verdict="PASS"
  local fail_count=0
  local details=""

  # ── Your check logic here ──────────────────────────────────
  #
  # Example: verify that a specific file exists
  #
  # local target="${KIT_ROOT}/some/file.txt"
  # if [[ ! -f "$target" ]]; then
  #   details+="FAIL: ${target} not found"$'\n'
  #   ((fail_count++)) || true
  # else
  #   details+="OK: ${target} exists"$'\n'
  # fi

  details+="TODO: implement check logic"$'\n'

  # ── Verdict ────────────────────────────────────────────────
  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
