#!/usr/bin/env bash
# cq_evidence.sh — CQ-EVC: Evidence Chain check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: Evidence paths referenced in trackers actually exist on disk
#
# @check_key: evidence
# @check_id: CQ-EVC
# @check_display: Evidence Chain
# @check_order: 20

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
    local file_fail=0
    local file_check=0

    # Extract Evidence paths from tracker
    # Pattern: "Evidence: <path>" or "Evidence: <path> (sha256:...)"
    while IFS= read -r eline; do
      # Extract the path portion after "Evidence:"
      local raw_path
      raw_path="$(echo "$eline" | sed -n 's/.*Evidence:\s*//p')"
      [[ -z "$raw_path" ]] && continue

      # Normalize separators: semicolons and commas
      raw_path="$(echo "$raw_path" | sed 's/\s*;\s*/,/g')"

      # Handle multiple comma-separated evidence paths
      IFS=',' read -ra path_parts <<< "$raw_path"
      for part in "${path_parts[@]}"; do
        # Clean up: strip leading/trailing whitespace, strip (sha256:...), strip trailing text
        local epath
        epath="$(echo "$part" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | sed 's/\s*(sha256:[^)]*)//' | sed 's/[[:space:]]*$//')"

        # Skip non-path entries (descriptions, globs, trailing text)
        if echo "$epath" | grep -qP '内の|配下|同一|確認済み|確認内容|以降|ディレクトリ群'; then
          continue
        fi

        # Skip glob patterns (contain * or ?)
        if echo "$epath" | grep -qP '[*?]'; then
          continue
        fi

        # Skip if it's clearly a description, not a path
        if [[ ! "$epath" =~ ^(logs/|tasks/|docs/|verify/|SSOT/|scripts/) ]]; then
          continue
        fi

        # Strip any trailing description after the path (space-delimited)
        epath="$(echo "$epath" | grep -oP '^[^\s]+' | head -1)"

        # Strip trailing semicolons or punctuation
        epath="${epath%;}"
        epath="${epath%,}"

        ((file_check++)) || true
        ((check_count++)) || true

        local full_path="${KIT_ROOT}/${epath}"
        if [[ -f "$full_path" || -d "$full_path" ]]; then
          : # exists, OK
        else
          details+="  FILE_NOT_FOUND: ${short_name} → ${epath}"$'\n'
          ((file_fail++)) || true
          ((fail_count++)) || true
        fi
      done
    done < <(grep -P '^\s*-\s+Evidence:' "$tracker" 2>/dev/null || true)

    local tracker_verdict="PASS"
    if [[ "$file_fail" -gt 0 ]]; then
      tracker_verdict="FAIL"
    fi
    details+="${short_name}: ${file_check} evidence refs checked, ${file_fail} not found → ${tracker_verdict}"$'\n'
  done

  details+=""$'\n'
  details+="Total: ${check_count} evidence references checked, ${fail_count} failures"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
