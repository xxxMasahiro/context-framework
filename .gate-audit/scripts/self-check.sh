#!/usr/bin/env bash
# self-check.sh — Self-check Runner (main entry point)
# Usage: bash scripts/self-check.sh [CHECK...]
#   CHECK = tracker | evidence | ssot | all (default: all)
#   Multiple checks can be specified: tracker evidence
#
# Phase 4: Plugin auto-detection
#   Check scripts are discovered via glob: scripts/lib/self_checks/cq_*.sh
#   Each script must declare metadata headers:
#     # @check_key: <key>       — config/CLI identifier (e.g. "tracker")
#     # @check_id: <id>         — short ID (e.g. "CQ-TRK")
#     # @check_display: <name>  — human-readable name (e.g. "Tracker Integrity")
#     # @check_order: <n>       — sort order (lower = earlier; default 50)
#
# Config checks= syntax:
#   checks=all                   — run all discovered checks
#   checks=tracker,ssot          — run only tracker and ssot
#   checks=!lint                 — run all except lint
#   checks=!lint,!naming         — run all except lint and naming
#
# Exit: 0 = all PASS, 1 = any FAIL

set -euo pipefail

# ── Resolve paths ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export KIT_ROOT

# ── Source libraries ─────────────────────────────────────────
source "${KIT_ROOT}/scripts/lib/evidence.sh"
source "${KIT_ROOT}/scripts/lib/self_check_common.sh"

# ── Init MAIN_REPO ───────────────────────────────────────────
MAIN_REPO="${MAIN_REPO:-$(discover_main_repo || true)}"
export MAIN_REPO

# ── Load config ──────────────────────────────────────────────
sc_load_config

# ── Plugin auto-detection ────────────────────────────────────
# Discover check scripts via glob and parse metadata headers.
# Populates: CHECK_SCRIPTS, CHECK_NAMES, CHECK_DISPLAY, AVAILABLE_CHECKS
declare -A CHECK_SCRIPTS CHECK_NAMES CHECK_DISPLAY
declare -A _CHECK_ORDER
AVAILABLE_CHECKS=()

_discover_plugins() {
  local checks_dir="${KIT_ROOT}/scripts/lib/self_checks"
  local -a found_scripts=()
  local -a found_orders=()
  local -a found_keys=()

  # Glob for plugin scripts (skip _template.sh and non-cq_ files)
  for script_path in "${checks_dir}"/cq_*.sh; do
    [[ -f "$script_path" ]] || continue

    # Parse metadata from header comments (first 30 lines)
    local key="" check_id="" display="" order="50"
    while IFS= read -r line; do
      case "$line" in
        *'@check_key:'*)
          key="$(echo "$line" | sed 's/.*@check_key:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
          ;;
        *'@check_id:'*)
          check_id="$(echo "$line" | sed 's/.*@check_id:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
          ;;
        *'@check_display:'*)
          display="$(echo "$line" | sed 's/.*@check_display:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
          ;;
        *'@check_order:'*)
          order="$(echo "$line" | sed 's/.*@check_order:[[:space:]]*//' | sed 's/[[:space:]]*$//')"
          ;;
      esac
    done < <(head -30 "$script_path")

    # Validate: all metadata must be present
    if [[ -z "$key" || -z "$check_id" || -z "$display" ]]; then
      echo "WARN: Skipping ${script_path##*/} — missing @check_key/@check_id/@check_display metadata" >&2
      continue
    fi

    CHECK_SCRIPTS["$key"]="$script_path"
    CHECK_NAMES["$key"]="$check_id"
    CHECK_DISPLAY["$key"]="$display"
    _CHECK_ORDER["$key"]="$order"

    found_scripts+=("$script_path")
    found_orders+=("$order")
    found_keys+=("$key")
  done

  # Sort by order (numeric), then by key (alphabetic) for stable ordering
  # Build "order:key" pairs, sort, extract keys
  local -a sort_input=()
  for i in "${!found_keys[@]}"; do
    sort_input+=("${found_orders[$i]}:${found_keys[$i]}")
  done

  AVAILABLE_CHECKS=()
  while IFS= read -r entry; do
    [[ -z "$entry" ]] && continue
    AVAILABLE_CHECKS+=("${entry#*:}")
  done < <(printf '%s\n' "${sort_input[@]}" | sort -t: -k1,1n -k2,2)
}

_discover_plugins

if [[ ${#AVAILABLE_CHECKS[@]} -eq 0 ]]; then
  echo "ERROR: No check plugins found in scripts/lib/self_checks/cq_*.sh" >&2
  exit 1
fi

# ── Determine which checks to run ────────────────────────────
# Priority: CLI args > config checks= > all
# Supports negation: checks=!lint,!naming → all except lint and naming
resolve_checks() {
  local args=("$@")

  # If CLI args provided and not "all", use them (highest priority)
  if [[ ${#args[@]} -gt 0 && "${args[0]}" != "all" ]]; then
    local resolved=()
    for arg in "${args[@]}"; do
      local found=0
      for avail in "${AVAILABLE_CHECKS[@]}"; do
        if [[ "$arg" == "$avail" ]]; then
          resolved+=("$arg")
          found=1
          break
        fi
      done
      if [[ "$found" -eq 0 ]]; then
        echo "ERROR: Unknown check '${arg}'. Available: ${AVAILABLE_CHECKS[*]}" >&2
        return 1
      fi
    done
    echo "${resolved[@]}"
    return
  fi

  # Fall back to config checks= (if not "all")
  if [[ -n "${SC_CHECKS:-}" && "$SC_CHECKS" != "all" ]]; then
    local -a config_items=()
    IFS=',' read -ra config_items <<< "$SC_CHECKS"

    # Detect negation mode: if ANY item starts with '!', treat as exclusion
    local has_negation=0
    local has_positive=0
    for ci in "${config_items[@]}"; do
      ci="$(echo "$ci" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
      [[ -z "$ci" ]] && continue
      if [[ "$ci" == !* ]]; then
        has_negation=1
      else
        has_positive=1
      fi
    done

    if [[ "$has_negation" -eq 1 && "$has_positive" -eq 1 ]]; then
      echo "ERROR: Cannot mix positive and negation checks in config (e.g., 'tracker,!lint')" >&2
      return 1
    fi

    if [[ "$has_negation" -eq 1 ]]; then
      # Exclusion mode: start with all, remove negated
      local -A exclude_set=()
      for ci in "${config_items[@]}"; do
        ci="$(echo "$ci" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [[ -z "$ci" ]] && continue
        local stripped="${ci#!}"
        local found=0
        for avail in "${AVAILABLE_CHECKS[@]}"; do
          if [[ "$stripped" == "$avail" ]]; then
            found=1
            break
          fi
        done
        if [[ "$found" -eq 0 ]]; then
          echo "WARN: Unknown check '${stripped}' in negation, ignoring" >&2
        else
          exclude_set["$stripped"]=1
        fi
      done
      local resolved=()
      for avail in "${AVAILABLE_CHECKS[@]}"; do
        if [[ -z "${exclude_set[$avail]:-}" ]]; then
          resolved+=("$avail")
        fi
      done
      if [[ ${#resolved[@]} -gt 0 ]]; then
        echo "${resolved[@]}"
        return
      fi
    else
      # Positive mode: run only listed checks
      local resolved=()
      for ci in "${config_items[@]}"; do
        ci="$(echo "$ci" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
        [[ -z "$ci" ]] && continue
        local found=0
        for avail in "${AVAILABLE_CHECKS[@]}"; do
          if [[ "$ci" == "$avail" ]]; then
            resolved+=("$ci")
            found=1
            break
          fi
        done
        if [[ "$found" -eq 0 ]]; then
          echo "WARN: Unknown check '${ci}' in config, skipping" >&2
        fi
      done
      if [[ ${#resolved[@]} -gt 0 ]]; then
        echo "${resolved[@]}"
        return
      fi
    fi
  fi

  # Default: all available checks
  echo "${AVAILABLE_CHECKS[@]}"
}

# ── Run a single check ───────────────────────────────────────
# Returns: sets RESULT_VERDICT, RESULT_DETAILS, RESULT_EVIDENCE_PATH
run_single_check() {
  local check_key="$1"
  local script="${CHECK_SCRIPTS[$check_key]}"
  local check_id="${CHECK_NAMES[$check_key]}"
  local display="${CHECK_DISPLAY[$check_key]}"

  export SC_CHECK_ID="$check_id"
  export SC_EVIDENCE_DIR="${KIT_ROOT}/logs/evidence"
  # Resolve SC_BASELINE_DIR to absolute (only if relative)
  if [[ "${SC_BASELINE_DIR}" == /* ]]; then
    export SC_BASELINE_DIR_ABS="${SC_BASELINE_DIR}"
  else
    export SC_BASELINE_DIR_ABS="${KIT_ROOT}/${SC_BASELINE_DIR}"
  fi

  if [[ ! -f "$script" ]]; then
    RESULT_VERDICT="FAIL"
    RESULT_DETAILS="Check script not found: ${script}"
    RESULT_EVIDENCE_PATH=""
    return 1
  fi

  # Source the check script (it defines run_check())
  # Use a subshell-like approach: unset run_check first
  unset -f run_check 2>/dev/null || true
  source "$script"

  # Execute
  local details=""
  local check_exit=0
  details="$(run_check 2>&1)" || check_exit=$?

  if [[ "$check_exit" -eq 0 ]]; then
    RESULT_VERDICT="PASS"
  else
    RESULT_VERDICT="FAIL"
  fi
  RESULT_DETAILS="$details"

  # Save evidence
  local ts_label
  ts_label="$(sc_ts_label)"
  local efile="${KIT_ROOT}/logs/evidence/${ts_label}_sc_${check_id}.txt"
  mkdir -p "$(dirname "$efile")"

  {
    sc_emit_header "$display" "$check_id"
    sc_emit_verdict "$RESULT_VERDICT" "${display} check"
    echo ""
    echo "$details"
  } > "$efile"

  RESULT_EVIDENCE_PATH="$efile"

  # Unset for next check
  unset -f run_check 2>/dev/null || true
}

# ── Main ─────────────────────────────────────────────────────
main() {
  local checks_to_run
  checks_to_run="$(resolve_checks "$@")" || exit 1
  read -ra check_list <<< "$checks_to_run"

  echo "=== kit self-check ==="
  echo ""

  local total_pass=0
  local total_fail=0
  local summary_lines=()
  local evidence_paths=()

  for check_key in "${check_list[@]}"; do
    local check_id="${CHECK_NAMES[$check_key]}"
    local display="${CHECK_DISPLAY[$check_key]}"

    RESULT_VERDICT=""
    RESULT_DETAILS=""
    RESULT_EVIDENCE_PATH=""

    # For regression check, pass current results so far
    if [[ "$check_key" == "regression" ]]; then
      export SC_CURRENT_RESULTS="${summary_lines[*]}"
    fi

    run_single_check "$check_key" || true

    if [[ "$RESULT_VERDICT" == "PASS" ]]; then
      ((total_pass++)) || true
    else
      ((total_fail++)) || true
    fi

    printf "  %-8s (%-22s): %s\n" "$check_id" "$display" "$RESULT_VERDICT"
    summary_lines+=("${check_id}:${RESULT_VERDICT}")
    if [[ -n "$RESULT_EVIDENCE_PATH" ]]; then
      evidence_paths+=("$RESULT_EVIDENCE_PATH")
    fi
  done

  local total=$((total_pass + total_fail))
  echo ""
  echo "Self-check Summary: ${total_pass}/${total} PASS, ${total_fail} FAIL"

  # Save summary evidence
  local ts_label
  ts_label="$(sc_ts_label)"
  local summary_file="${KIT_ROOT}/logs/evidence/${ts_label}_sc_summary.txt"
  {
    sc_emit_header "Self-check Summary" "SC-ALL"
    if [[ "$total_fail" -eq 0 ]]; then
      sc_emit_verdict "PASS" "All ${total} checks passed"
    else
      sc_emit_verdict "FAIL" "${total_fail}/${total} checks failed"
    fi
    echo ""
    echo "--- Per-check results ---"
    for sl in "${summary_lines[@]}"; do
      echo "  ${sl}"
    done
    echo ""
    echo "--- Evidence files ---"
    for ep in "${evidence_paths[@]}"; do
      local relp="${ep#"${KIT_ROOT}/"}"
      local sha
      sha="$(sc_sha16 "$ep")"
      echo "  ${relp}  sha256(16): ${sha}"
    done
  } > "$summary_file"

  local summary_sha
  summary_sha="$(sc_sha16 "$summary_file")"
  local summary_rel="${summary_file#"${KIT_ROOT}/"}"
  echo "Evidence: ${summary_rel}"
  echo "sha256(16): ${summary_sha}"
  echo ""

  # ── Save baseline (last_run.json) ──────────────────────────
  # Update baseline after each full run so CQ-REG can detect regressions next time
  local baseline_dir
  if [[ "${SC_BASELINE_DIR}" == /* ]]; then
    baseline_dir="${SC_BASELINE_DIR}"
  else
    baseline_dir="${KIT_ROOT}/${SC_BASELINE_DIR}"
  fi
  mkdir -p "$baseline_dir"
  local baseline_file="${baseline_dir}/last_run.json"
  {
    echo "{"
    echo "  \"timestamp\": \"$(date -u '+%Y-%m-%dT%H:%M:%SZ')\","
    echo "  \"total_pass\": ${total_pass},"
    echo "  \"total_fail\": ${total_fail},"
    echo "  \"checks\": {"
    local first=1
    for sl in "${summary_lines[@]}"; do
      local ck="${sl%%:*}"
      local vd="${sl##*:}"
      if [[ "$first" -eq 1 ]]; then
        first=0
      else
        echo ","
      fi
      printf "    \"%s\": \"%s\"" "$ck" "$vd"
    done
    echo ""
    echo "  }"
    echo "}"
  } > "$baseline_file"
  echo "Baseline: ${baseline_file#"${KIT_ROOT}/"} (updated)"

  if [[ "$total_fail" -gt 0 ]]; then
    return 1
  fi
  return 0
}

main "$@"
