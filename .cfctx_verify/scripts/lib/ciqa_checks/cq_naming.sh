#!/usr/bin/env bash
# cq_naming.sh — CQ-NAME: Naming convention check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: Evidence filenames follow YYYYMMDD-HHMMSS_* or YYYYMMDTHHMMSSZ_* pattern
# Pattern is configurable via naming_pattern in ciqa.conf
#
# @check_key: naming
# @check_id: CQ-NAME
# @check_display: Naming Convention
# @check_order: 60

run_check() {
  local verdict="PASS"
  local fail_count=0
  local check_count=0
  local details=""

  local evidence_dir="${KIT_ROOT}/logs/evidence"

  if [[ ! -d "$evidence_dir" ]]; then
    details+="SKIP: Evidence directory not found: logs/evidence"$'\n'
    echo "$details"
    return 0
  fi

  # Naming pattern from config (regex applied to basename)
  local pattern
  if [[ -n "${CIQA_NAMING_PATTERN:-}" ]]; then
    pattern="$CIQA_NAMING_PATTERN"
  else
    pattern='^[0-9]{8}[-T][0-9]{6}Z?_'
  fi

  details+="Config: naming_pattern=${pattern}"$'\n'
  details+="Evidence dir: logs/evidence"$'\n'
  details+=""$'\n'

  # Check each file in evidence dir (top-level only, exclude special files)
  while IFS= read -r filepath; do
    [[ -z "$filepath" ]] && continue
    local fname
    fname="$(basename "$filepath")"

    # Skip non-evidence files (INDEX.md, .gitkeep, directories)
    case "$fname" in
      INDEX.md|.gitkeep) continue ;;
    esac

    ((check_count++)) || true

    if ! echo "$fname" | grep -qP "$pattern"; then
      details+="  INVALID_FORMAT: ${fname}"$'\n'
      ((fail_count++)) || true
    fi
  done < <(find "$evidence_dir" -maxdepth 1 -type f 2>/dev/null | sort)

  details+=""$'\n'
  details+="Total: ${check_count} files checked, ${fail_count} naming violations"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
