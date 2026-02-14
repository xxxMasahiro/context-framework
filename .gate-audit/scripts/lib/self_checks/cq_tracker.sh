#!/usr/bin/env bash
# cq_tracker.sh — CQ-TRK: Tracker Integrity check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: every [x] item has 判定, Evidence, 日時 metadata
#
# @check_key: tracker
# @check_id: CQ-TRK
# @check_display: Tracker Integrity
# @check_order: 10
#
# Handles two common formats:
#   Format A (inline):  - [x] text  - 判定: PASS
#   Format B (block):   - [x] text
#                         - 判定: PASS
#                         - Evidence: path
#                         - 日時: timestamp

run_check() {
  local verdict="PASS"
  local fail_count=0
  local check_count=0
  local details=""

  # Use tracker files from config, or discover them
  local tracker_list=()
  if [[ ${#SC_TRACKER_FILES[@]} -gt 0 ]]; then
    tracker_list=("${SC_TRACKER_FILES[@]}")
  else
    while IFS= read -r f; do
      tracker_list+=("$f")
    done < <(find "${KIT_ROOT}/tasks" -name '*_task_tracker.md' -type f 2>/dev/null | sort)
  fi

  for tracker_rel in "${tracker_list[@]}"; do
    local tracker
    if [[ "$tracker_rel" == /* ]]; then
      tracker="$tracker_rel"
    else
      tracker="${KIT_ROOT}/${tracker_rel}"
    fi

    if [[ ! -f "$tracker" ]]; then
      details+="SKIP: ${tracker_rel} (file not found)"$'\n'
      continue
    fi

    local short_name
    short_name="$(basename "$tracker")"
    local item_fail=0
    local item_count=0

    # Read all lines into array
    local -a lines=()
    while IFS= read -r l; do
      lines+=("$l")
    done < "$tracker"
    local total_lines=${#lines[@]}

    local i=0
    while [[ $i -lt $total_lines ]]; do
      local line="${lines[$i]}"

      # Is this a [x] line?
      if echo "$line" | grep -qP '^\s*- \[x\]'; then
        ((item_count++)) || true
        ((check_count++)) || true

        # Extract item text (for reporting)
        local item_text
        item_text="$(echo "$line" | sed 's/^\s*- \[x\] //' | sed 's/\s*- 判定:.*$//' | head -c 60)"

        local has_verdict=0
        local has_evidence=0
        local has_date=0

        # Check the [x] line itself for inline metadata
        if echo "$line" | grep -qP '判定:\s*(PASS|FAIL)'; then
          has_verdict=1
        fi
        if echo "$line" | grep -qiP 'Evidence:'; then
          has_evidence=1
        fi
        if echo "$line" | grep -qP '日時:'; then
          has_date=1
        fi

        # Scan subsequent indented lines for metadata
        local j=$((i + 1))
        while [[ $j -lt $total_lines ]]; do
          local next="${lines[$j]}"

          # Stop at: another checkbox, section header, ---, or blank+non-indented
          if echo "$next" | grep -qP '^\s*- \[[ x]\]|^## |^---'; then
            break
          fi
          # Stop at non-indented non-empty line that's not metadata
          if [[ -n "$next" ]] && ! echo "$next" | grep -qP '^\s'; then
            break
          fi

          # Check for metadata
          if echo "$next" | grep -qP '判定:\s*(PASS|FAIL)'; then
            has_verdict=1
          fi
          if echo "$next" | grep -qiP '(Evidence|確認内容):'; then
            has_evidence=1
          fi
          if echo "$next" | grep -qP '日時:'; then
            has_date=1
          fi

          ((j++)) || true
        done

        # Evaluate
        local missing=""
        if [[ "$has_verdict" -eq 0 ]]; then
          missing+="MISSING_VERDICT "
        fi
        if [[ "$has_evidence" -eq 0 ]]; then
          missing+="MISSING_EVIDENCE "
        fi
        if [[ "$has_date" -eq 0 ]]; then
          missing+="MISSING_DATE "
        fi

        if [[ -n "$missing" ]]; then
          details+="  FAIL: ${short_name}: \"${item_text}\" — ${missing}"$'\n'
          ((item_fail++)) || true
          ((fail_count++)) || true
        fi
      fi

      ((i++)) || true
    done

    local tracker_verdict="PASS"
    if [[ "$item_fail" -gt 0 ]]; then
      tracker_verdict="FAIL"
    fi
    details+="${short_name}: ${item_count} checked items, ${item_fail} missing metadata → ${tracker_verdict}"$'\n'
  done

  details+=""$'\n'
  details+="Total: ${check_count} [x] items checked, ${fail_count} failures"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
