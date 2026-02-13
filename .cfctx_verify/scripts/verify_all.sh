#!/usr/bin/env bash
# verify_all.sh — Run all gate verification in sequence
# Usage: bash scripts/verify_all.sh
#
# This script:
# 1. Discovers and validates the main repo (read-only)
# 2. Records repo reference evidence (HEAD, status, sha256)
# 3. Runs SSOT comparison (kit SSOT/ vs repo _handoff_check/)
# 4. Runs all discovered gates (auto-discovered from scripts/lib/gate_*.sh)
# 5. Produces a summary (PASS/FAIL per gate)
#
# Evidence is written to: logs/evidence/<timestamp>_<gate>/

set -euo pipefail

# ── Resolve paths ──────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export KIT_ROOT

# ── Source libraries ───────────────────────────────────────────
source "${SCRIPT_DIR}/lib/evidence.sh"
source "${SCRIPT_DIR}/lib/ssot_check.sh"
source "${SCRIPT_DIR}/lib/gate_registry.sh"
gr_source_all_gates

# ── Discover main repo ────────────────────────────────────────
MAIN_REPO=$(discover_main_repo) || true
export MAIN_REPO

if [[ -z "$MAIN_REPO" ]]; then
  echo "FATAL: Cannot locate main repo (context-framework)." >&2
  echo "Set CFCTX_MAIN_REPO=/path/to/context-framework or CFCTX_SEARCH_PATH=dir1:dir2" >&2
  exit 1
fi

mapfile -t GATES < <(gr_list_gate_ids)

if [[ ${#GATES[@]} -eq 0 ]]; then
  echo "FATAL: No gates discovered (gate_*.sh files missing or all had unsafe IDs)." >&2
  exit 1
fi

GATE_LIST_STR=$(IFS=','; echo "${GATES[*]}")

echo "=============================================="
echo " context-framework Gate Verification"
echo " Gates: ${GATE_LIST_STR}"
echo "=============================================="
echo ""
echo "Kit Root:   ${KIT_ROOT}"
echo "Main Repo:  ${MAIN_REPO}"
echo "HEAD:       $(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null || echo 'N/A')"
echo "Status:     $(cd "$MAIN_REPO" && git status --porcelain 2>&1 | head -5 || echo 'unknown')"
echo "Timestamp:  $(ts_utc) / $(ts_jst)"
echo ""

# ── Record initial repo reference evidence ────────────────────
REPO_EVIDENCE_DIR="${KIT_ROOT}/logs/evidence/$(ts_label)_repo_reference"
mkdir -p "$REPO_EVIDENCE_DIR"
{
  echo "=== Main Repo Reference Evidence ==="
  echo "ts_utc: $(ts_utc)"
  echo "ts_jst: $(ts_jst)"
  echo "main_repo_path: ${MAIN_REPO}"
  echo "main_repo_head: $(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null || echo 'N/A')"
  echo ""
  echo "--- git status --porcelain ---"
  (cd "$MAIN_REPO" && git status --porcelain 2>&1) || echo "(git status failed)"
  echo ""
  echo "--- SSOT 3-file sha256 ---"
  for f in cf_handoff_prompt.md cf_update_runbook.md cf_task_tracker_v5.md; do
    if [[ -f "${MAIN_REPO}/_handoff_check/${f}" ]]; then
      sha256sum "${MAIN_REPO}/_handoff_check/${f}" | awk '{print $1 "  _handoff_check/'"$f"'"}'
    fi
  done
} > "${REPO_EVIDENCE_DIR}/meta.txt"

echo "--- Repo reference evidence recorded ---"
echo ""

# ── SSOT Comparison ───────────────────────────────────────────
echo "=== Pre-check: SSOT Comparison ==="
# We need a temporary init_evidence for ssot_check
init_evidence "ssot_precheck"
local_ssot_result="MATCH"
if ! run_ssot_check; then
  local_ssot_result="DIFFER"
  echo "  WARN: Kit SSOT snapshot differs from current repo _handoff_check."
  echo "  Verification will use current repo state as truth."
  echo "  Diff details saved to: ${EVIDENCE_DIR}/ssot_comparison.txt"
else
  echo "  Kit SSOT and repo _handoff_check are identical."
fi
echo ""

# ── Run gates ─────────────────────────────────────────────────
declare -A GATE_RESULTS

for gate in "${GATES[@]}"; do
  func="$(gr_gate_func_for_id "$gate")"

  echo "----------------------------------------------"
  result=$("$func" 2>&1) || true
  # Last line of output is PASS or FAIL
  gate_result=$(echo "$result" | tail -1)
  GATE_RESULTS["$gate"]="$gate_result"

  echo "$result"
  echo ""
done

# ── Summary ───────────────────────────────────────────────────
echo "=============================================="
echo " VERIFICATION SUMMARY"
echo "=============================================="
echo ""
echo "SSOT Comparison: ${local_ssot_result}"
echo ""

total_pass=0
total_fail=0

for gate in "${GATES[@]}"; do
  r="${GATE_RESULTS[$gate]:-UNKNOWN}"
  printf "  Gate %s: %s\n" "$gate" "$r"
  if [[ "$r" == "PASS" ]]; then
    ((total_pass++)) || true
  else
    ((total_fail++)) || true
  fi
done

echo ""
echo "Total: ${total_pass} PASS / ${total_fail} FAIL (out of ${#GATES[@]} gates)"
echo ""

if [[ "$total_fail" -eq 0 && "$local_ssot_result" == "MATCH" ]]; then
  echo "OVERALL: ALL GATES PASS + SSOT MATCH"
else
  if [[ "$total_fail" -gt 0 ]]; then
    echo "OVERALL: SOME GATES FAILED — re-run individual gates with:"
    echo "  bash scripts/verify_gate.sh <${GATE_LIST_STR}>"
  fi
  if [[ "$local_ssot_result" != "MATCH" ]]; then
    echo "OVERALL: SSOT DIFFER — kit SSOT snapshot does not match repo _handoff_check."
  fi
fi

echo ""
echo "Evidence directory: ${KIT_ROOT}/logs/evidence/"
echo "Timestamp: $(ts_utc) / $(ts_jst)"
echo "=============================================="

# Exit code: 0 only if all PASS AND SSOT MATCH
if [[ "$total_fail" -gt 0 || "$local_ssot_result" != "MATCH" ]]; then
  exit 1
fi
exit 0
