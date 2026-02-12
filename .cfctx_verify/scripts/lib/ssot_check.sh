#!/usr/bin/env bash
# ssot_check.sh — Compare kit SSOT/ with main repo _handoff_check/
# Usage: source scripts/lib/ssot_check.sh  (after sourcing evidence.sh)

# ── SSOT Comparison ─────────────────────────────────────────────
# Returns 0 if all match, 1 if diffs found
# Writes diff details to evidence
run_ssot_check() {
  local ssot_dir="${KIT_ROOT}/SSOT"
  local repo_hc="${MAIN_REPO}/_handoff_check"
  local diff_found=0

  local ssot_files=(
    "cf_handoff_prompt.md"
    "cf_update_runbook.md"
    "cf_task_tracker_v5.md"
  )

  local output_file="${EVIDENCE_DIR}/ssot_comparison.txt"
  {
    echo "=== SSOT Comparison ==="
    echo "Kit SSOT: ${ssot_dir}"
    echo "Repo _handoff_check: ${repo_hc}"
    echo "Timestamp: $(ts_utc)"
    echo ""
  } > "$output_file"

  for f in "${ssot_files[@]}"; do
    local kit_file="${ssot_dir}/${f}"
    local repo_file="${repo_hc}/${f}"

    echo "--- Checking: ${f} ---" >> "$output_file"

    if [[ ! -f "$kit_file" ]]; then
      echo "  Kit SSOT file MISSING: ${kit_file}" >> "$output_file"
      diff_found=1
      continue
    fi

    if [[ ! -f "$repo_file" ]]; then
      echo "  Repo _handoff_check file MISSING: ${repo_file}" >> "$output_file"
      diff_found=1
      continue
    fi

    # Record repo file reference
    record_ref "_handoff_check/${f}"

    # Compute hashes
    local kit_hash repo_hash
    kit_hash=$(sha256sum "$kit_file" | awk '{print $1}')
    repo_hash=$(sha256sum "$repo_file" | awk '{print $1}')

    echo "  Kit SHA256:  ${kit_hash}" >> "$output_file"
    echo "  Repo SHA256: ${repo_hash}" >> "$output_file"

    if [[ "$kit_hash" == "$repo_hash" ]]; then
      echo "  Status: MATCH" >> "$output_file"
    else
      echo "  Status: DIFFER" >> "$output_file"
      echo "" >> "$output_file"
      echo "  Diff (kit vs repo):" >> "$output_file"
      diff -u "$kit_file" "$repo_file" 2>/dev/null | head -100 >> "$output_file" || true
      diff_found=1
    fi
    echo "" >> "$output_file"
  done

  # Summary
  {
    echo "=== SSOT Comparison Summary ==="
    if [[ "$diff_found" -eq 0 ]]; then
      echo "RESULT: ALL MATCH"
    else
      echo "RESULT: DIFFERENCES FOUND"
      echo "NOTE: Kit SSOT snapshot differs from current repo _handoff_check."
      echo "This is expected if the repo has been updated since the snapshot was taken."
      echo "Gate verification will proceed with WARN, using the CURRENT repo state as truth."
    fi
  } >> "$output_file"

  return $diff_found
}
