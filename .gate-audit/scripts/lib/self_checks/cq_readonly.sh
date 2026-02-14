#!/usr/bin/env bash
# cq_readonly.sh — CQ-RO: Read-only compliance check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Detects write operations against MAIN_REPO in gate/verify scripts.
# Ensures REQ-S02 (read-only) is not violated by any script.
#
# @check_key: readonly
# @check_id: CQ-RO
# @check_display: Read-only Compliance
# @check_order: 15

run_check() {
  local verdict="PASS"
  local fail_count=0
  local check_count=0
  local details=""

  # ── Define patterns that indicate write operations against MAIN_REPO ──
  # These patterns in gate/verify scripts would violate REQ-S02
  local -a write_patterns=(
    'git\s+(push|commit|add|reset|clean|checkout|merge|rebase|stash)\b'
    'git\s+-C\s+.*\s+(push|commit|add|reset|clean|checkout)\b'
    '>\s*"\$\{?MAIN_REPO'
    '>>\s*"\$\{?MAIN_REPO'
    '\btee\s+.*"\$\{?MAIN_REPO'
    '\bcp\s+.*"\$\{?MAIN_REPO'
    '\bmv\s+.*"\$\{?MAIN_REPO'
    '\brm\s+.*"\$\{?MAIN_REPO'
    '\bmkdir\s+.*"\$\{?MAIN_REPO'
    '\btouch\s+.*"\$\{?MAIN_REPO'
    '\bchmod\s+.*"\$\{?MAIN_REPO'
    '\bchown\s+.*"\$\{?MAIN_REPO'
    '\bsed\s+-i.*"\$\{?MAIN_REPO'
  )

  # ── Scan targets: gate scripts + verify scripts ──
  local -a targets=()
  local f

  # Gate scripts
  for f in "${KIT_ROOT}"/scripts/lib/gate_*.sh; do
    [[ -f "$f" ]] && targets+=("$f")
  done

  # Verify scripts
  for f in "${KIT_ROOT}"/scripts/verify_all.sh "${KIT_ROOT}"/scripts/verify_gate.sh; do
    [[ -f "$f" ]] && targets+=("$f")
  done

  # Evidence library (shared functions used by gates)
  [[ -f "${KIT_ROOT}/scripts/lib/evidence.sh" ]] && targets+=("${KIT_ROOT}/scripts/lib/evidence.sh")

  # Test runner and self-check runner (should also be read-only w.r.t. MAIN_REPO)
  for f in "${KIT_ROOT}"/scripts/run_tests.sh "${KIT_ROOT}"/scripts/self-check.sh; do
    [[ -f "$f" ]] && targets+=("$f")
  done

  if [[ ${#targets[@]} -eq 0 ]]; then
    details+="SKIP: No script files found to check"$'\n'
    echo "$details"
    return 0
  fi

  details+="Scan targets: ${#targets[@]} files"$'\n'
  details+="Write patterns: ${#write_patterns[@]} patterns"$'\n'
  details+=""$'\n'

  # ── Check each target ──
  for script in "${targets[@]}"; do
    ((check_count++)) || true
    local rel="${script#"${KIT_ROOT}/"}"
    local found_violations=""
    local violation_count=0

    for pattern in "${write_patterns[@]}"; do
      local matches=""
      matches="$(grep -nE "$pattern" "$script" 2>/dev/null)" || matches=""

      if [[ -n "$matches" ]]; then
        # Filter out comments (lines starting with #) and quoted strings in echo/details
        local real_violations=""
        while IFS= read -r line; do
          local line_content="${line#*:}"
          # Strip leading whitespace
          line_content="${line_content#"${line_content%%[![:space:]]*}"}"
          # Skip comment lines
          [[ "$line_content" == \#* ]] && continue
          # Skip lines that are inside string literals (echo, details+=, etc.)
          [[ "$line_content" == *'details+='* ]] && continue
          [[ "$line_content" == *'output+='* ]] && continue
          [[ "$line_content" == *'echo '* && "$line_content" != *'| git'* ]] && continue
          real_violations+="    ${line}"$'\n'
          ((violation_count++)) || true
        done <<< "$matches"

        if [[ -n "$real_violations" ]]; then
          found_violations+="$real_violations"
        fi
      fi
    done

    if [[ -n "$found_violations" && "$violation_count" -gt 0 ]]; then
      details+="  FAIL: ${rel} — ${violation_count} write operation(s) detected"$'\n'
      details+="${found_violations}"
      ((fail_count++)) || true
    else
      details+="  PASS: ${rel}"$'\n'
    fi
  done

  details+=""$'\n'
  details+="Total: ${check_count} scripts checked, ${fail_count} with violations"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
    details+="Action: Remove or relocate write operations that target MAIN_REPO (REQ-S02)"$'\n'
  else
    details+="REQ-S02 compliance: All scripts are read-only with respect to MAIN_REPO"$'\n'
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
