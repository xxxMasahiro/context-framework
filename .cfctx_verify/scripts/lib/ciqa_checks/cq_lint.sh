#!/usr/bin/env bash
# cq_lint.sh — CQ-LINT: Script quality check (shellcheck)
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# If shellcheck is not installed → SKIP (exit 0) with WARN
# Severity and targets are read from config (CIQA_LINT_SEVERITY, CIQA_LINT_TARGETS)
#
# @check_key: lint
# @check_id: CQ-LINT
# @check_display: Script Quality
# @check_order: 50

run_check() {
  local verdict="PASS"
  local fail_count=0
  local check_count=0
  local details=""

  # Check if shellcheck is available
  if ! command -v shellcheck &>/dev/null; then
    details+="SKIP: shellcheck not found in PATH"$'\n'
    details+="WARN: Install shellcheck to enable CQ-LINT checks"$'\n'
    echo "$details"
    return 0
  fi

  local severity="${CIQA_LINT_SEVERITY:-warning}"

  # Resolve lint targets from config
  local -a targets=()
  if [[ ${#CIQA_LINT_TARGETS[@]} -gt 0 ]]; then
    for pattern in "${CIQA_LINT_TARGETS[@]}"; do
      [[ -z "$pattern" ]] && continue
      local full_pattern="${KIT_ROOT}/${pattern}"
      # Use bash globbing to expand
      local -a expanded=()
      # shellcheck disable=SC2206
      expanded=($full_pattern)
      for f in "${expanded[@]}"; do
        [[ -f "$f" ]] && targets+=("$f")
      done
    done
  fi

  # Fallback: scan scripts/ directory
  if [[ ${#targets[@]} -eq 0 ]]; then
    while IFS= read -r f; do
      [[ -n "$f" ]] && targets+=("$f")
    done < <(find "${KIT_ROOT}/scripts" -name '*.sh' -type f 2>/dev/null | sort)
  fi

  if [[ ${#targets[@]} -eq 0 ]]; then
    details+="SKIP: No script files found to lint"$'\n'
    echo "$details"
    return 0
  fi

  details+="Config: severity=${severity}, targets=${#targets[@]} files"$'\n'
  details+=""$'\n'

  for script in "${targets[@]}"; do
    ((check_count++)) || true
    local rel="${script#"${KIT_ROOT}/"}"
    local sc_output=""
    local sc_exit=0
    sc_output="$(shellcheck --severity="$severity" --format=gcc "$script" 2>&1)" || sc_exit=$?

    if [[ "$sc_exit" -ne 0 && -n "$sc_output" ]]; then
      local issue_count
      issue_count="$(echo "$sc_output" | wc -l)"
      details+="  FAIL: ${rel} — ${issue_count} issues"$'\n'
      details+="$(echo "$sc_output" | head -20 | sed 's/^/    /')"$'\n'
      if [[ "$issue_count" -gt 20 ]]; then
        details+="    ... (${issue_count} total, showing first 20)"$'\n'
      fi
      ((fail_count++)) || true
    else
      details+="  PASS: ${rel}"$'\n'
    fi
  done

  details+=""$'\n'
  details+="Total: ${check_count} scripts checked, ${fail_count} with issues"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
