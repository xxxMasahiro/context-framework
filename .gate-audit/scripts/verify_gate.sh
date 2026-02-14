#!/usr/bin/env bash
# verify_gate.sh — Run individual gate verification
# Usage: bash scripts/verify_gate.sh <GATE> [GATE...]
#        bash scripts/verify_gate.sh --list
#
# Gates are auto-discovered from scripts/lib/gate_*.sh.
# Use this to re-verify FAILed gates.

set -euo pipefail

# ── Resolve paths ──────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export KIT_ROOT

# ── Source registry (lightweight, no gate source yet) ─────────
source "${SCRIPT_DIR}/lib/gate_registry.sh"

# ── --list mode (no main repo needed, no side effects) ────────
if [[ "${1:-}" == "--list" || "${1:-}" == "list" ]]; then
  gr_list_gate_ids
  exit 0
fi

# ── Build valid gate set for usage / validation ───────────────
mapfile -t VALID_GATES < <(gr_list_gate_ids)
VALID_GATES_STR=$(IFS='|'; echo "${VALID_GATES[*]}")

# ── Parse arguments ───────────────────────────────────────────
if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <${VALID_GATES_STR}>" >&2
  echo "" >&2
  echo "Available gates: ${VALID_GATES[*]}" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 A        # Re-verify Gate A only" >&2
  echo "  $0 F        # Re-verify Gate F only" >&2
  echo "  $0 A B C    # Re-verify Gates A, B, C" >&2
  echo "  $0 --list   # List available gates (no side effects)" >&2
  exit 1
fi

# ── Source all gate + support libraries ───────────────────────
source "${SCRIPT_DIR}/lib/evidence.sh"
source "${SCRIPT_DIR}/lib/ssot_check.sh"
gr_source_all_gates

# ── Discover main repo ────────────────────────────────────────
MAIN_REPO=$(discover_main_repo) || true
export MAIN_REPO

if [[ -z "$MAIN_REPO" ]]; then
  echo "FATAL: Cannot locate main repo (context-framework)." >&2
  exit 1
fi

echo "=============================================="
echo " context-framework Gate Verification"
echo " Target: $*"
echo "=============================================="
echo ""
echo "Kit Root:   ${KIT_ROOT}"
echo "Main Repo:  ${MAIN_REPO}"
echo "HEAD:       $(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null || echo 'N/A')"
echo "Timestamp:  $(ts_utc) / $(ts_jst)"
echo ""

# ── Record repo reference ────────────────────────────────────
REPO_EVIDENCE_DIR="${KIT_ROOT}/logs/evidence/$(ts_label)_repo_reference_single"
mkdir -p "$REPO_EVIDENCE_DIR"
{
  echo "=== Main Repo Reference (single gate run) ==="
  echo "ts_utc: $(ts_utc)"
  echo "ts_jst: $(ts_jst)"
  echo "target_gates: $*"
  echo "main_repo_path: ${MAIN_REPO}"
  echo "main_repo_head: $(cd "$MAIN_REPO" && git rev-parse HEAD 2>/dev/null || echo 'N/A')"
  echo ""
  echo "--- SSOT 3-file sha256 ---"
  for f in cf_handoff_prompt.md cf_update_runbook.md cf_task_tracker_v5.md; do
    if [[ -f "${MAIN_REPO}/_handoff_check/${f}" ]]; then
      sha256sum "${MAIN_REPO}/_handoff_check/${f}" | awk '{print $1 "  _handoff_check/'"$f"'"}'
    fi
  done
} > "${REPO_EVIDENCE_DIR}/meta.txt"

# ── Gate dispatch ─────────────────────────────────────────────
# Build lookup set from valid gates
declare -A VALID_GATE_SET
for g in "${VALID_GATES[@]}"; do
  VALID_GATE_SET["$g"]=1
done

declare -A GATE_RESULTS
total_pass=0
total_fail=0
invalid_args=0

for gate_arg in "$@"; do
  gate=$(echo "$gate_arg" | tr '[:lower:]' '[:upper:]')

  if [[ -z "${VALID_GATE_SET[$gate]+_}" ]]; then
    echo "ERROR: Unknown gate '$gate'. Valid gates: ${VALID_GATES[*]}" >&2
    ((invalid_args++)) || true
    continue
  fi

  echo "----------------------------------------------"
  func="$(gr_gate_func_for_id "$gate")"
  result=$("$func" 2>&1) || true
  gate_result=$(echo "$result" | tail -1)
  GATE_RESULTS["$gate"]="$gate_result"

  echo "$result"
  echo ""

  if [[ "$gate_result" == "PASS" ]]; then
    ((total_pass++)) || true
  else
    ((total_fail++)) || true
  fi
done

# ── Summary ───────────────────────────────────────────────────
echo "=============================================="
echo " VERIFICATION RESULT"
echo "=============================================="

for gate_arg in "$@"; do
  gate=$(echo "$gate_arg" | tr '[:lower:]' '[:upper:]')
  printf "  Gate %s: %s\n" "$gate" "${GATE_RESULTS[$gate]:-UNKNOWN}"
done

echo ""
echo "Total: ${total_pass} PASS / ${total_fail} FAIL"
echo ""
echo "Evidence directory: ${KIT_ROOT}/logs/evidence/"
echo "Timestamp: $(ts_utc) / $(ts_jst)"
echo "=============================================="

# Exit code: 0 if all PASS, 1 if any FAIL or invalid arguments
if [[ "$total_fail" -gt 0 || "$invalid_args" -gt 0 ]]; then
  exit 1
fi
exit 0
