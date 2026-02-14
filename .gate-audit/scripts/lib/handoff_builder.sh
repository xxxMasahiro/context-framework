#!/usr/bin/env bash
# handoff_builder.sh — latest.md 生成ロジック（関数群）
# Usage: source scripts/lib/handoff_builder.sh
# 各 emit_* 関数は stdout にMarkdownセクションを出力する。
# 前提: KIT_ROOT / MAIN_REPO が設定済み、または自動検出する。

# Guard: only set pipefail etc. when not already sourced
if [[ -z "${_HANDOFF_BUILDER_LOADED:-}" ]]; then
  _HANDOFF_BUILDER_LOADED=1
fi

# ── Discover KIT_ROOT ──────────────────────────────────────────
_hb_init_kit_root() {
  if [[ -n "${KIT_ROOT:-}" ]]; then return 0; fi
  # Derive from this script's location: scripts/lib/ -> kit root
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  KIT_ROOT="$(cd "${script_dir}/../.." && pwd)"
  export KIT_ROOT
}

# ── Discover MAIN_REPO (read-only) ────────────────────────────
# Delegates to discover_main_repo() from evidence.sh if available,
# otherwise uses GATE_AUDIT_MAIN_REPO env var.
_hb_init_main_repo() {
  if [[ -n "${MAIN_REPO:-}" && -d "${MAIN_REPO}/.git" ]]; then return 0; fi
  if type -t discover_main_repo &>/dev/null; then
    MAIN_REPO="$(discover_main_repo)" || true
  elif [[ -n "${GATE_AUDIT_MAIN_REPO:-}" && -d "${GATE_AUDIT_MAIN_REPO}/.git" ]]; then
    MAIN_REPO="$GATE_AUDIT_MAIN_REPO"
  fi
  if [[ -z "${MAIN_REPO:-}" ]]; then
    echo "FATAL: Cannot find main repo. Set GATE_AUDIT_MAIN_REPO or MAIN_REPO." >&2
    return 1
  fi
  export MAIN_REPO
}

# ── Ensure both roots are set ──────────────────────────────────
_hb_ensure_roots() {
  _hb_init_kit_root
  _hb_init_main_repo
}

# ────────────────────────────────────────────────────────────────
# emit_meta — ## 1. Meta
# ────────────────────────────────────────────────────────────────
emit_meta() {
  _hb_ensure_roots

  local ts_utc ts_jst kit_branch kit_head
  ts_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
  ts_jst="$(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S %Z')"
  kit_branch="$(git -C "$KIT_ROOT" symbolic-ref --short HEAD 2>/dev/null || echo 'detached')"
  kit_head="$(git -C "$KIT_ROOT" rev-parse --short HEAD 2>/dev/null || echo 'unknown')"

  cat <<EOF
## 1. Meta
- generated: ${ts_utc} / ${ts_jst}
- kit_root: ${KIT_ROOT}
- kit_branch: ${kit_branch}
- kit_HEAD: ${kit_head}
EOF
}

# ────────────────────────────────────────────────────────────────
# emit_main_repo_snapshot — ## 2. Main Repo Snapshot
# ────────────────────────────────────────────────────────────────
emit_main_repo_snapshot() {
  _hb_ensure_roots

  local head_short head_full branch status_raw dirty_count status_label
  head_short="$(git -C "$MAIN_REPO" rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  head_full="$(git -C "$MAIN_REPO" rev-parse HEAD 2>/dev/null || echo 'unknown')"
  branch="$(git -C "$MAIN_REPO" symbolic-ref --short HEAD 2>/dev/null || echo 'detached')"
  status_raw="$(git -C "$MAIN_REPO" status --porcelain 2>/dev/null)" || true
  if [[ -z "$status_raw" ]]; then
    status_label="clean"
  else
    dirty_count="$(echo "$status_raw" | wc -l | tr -d ' ')"
    status_label="dirty (${dirty_count} files)"
  fi

  # Repo lock
  # cf-guard.sh uses `git rev-parse --show-toplevel` to find the repo root,
  # so it must be run from within the main repo (subshell, read-only).
  local repo_lock="NG"
  if [[ -x "$MAIN_REPO/tools/cf-guard.sh" ]]; then
    local guard_out
    guard_out="$(cd "$MAIN_REPO" && bash "$MAIN_REPO/tools/cf-guard.sh" --check 2>&1)" || true
    if echo "$guard_out" | grep -q "OK" 2>/dev/null; then
      repo_lock="OK"
    fi
  fi

  # SSOT fingerprint (sha256 first 8 chars)
  local ssot_files=("cf_handoff_prompt.md" "cf_update_runbook.md" "cf_task_tracker_v5.md")
  local fp_lines=""
  for f in "${ssot_files[@]}"; do
    local fp="N/A"
    if [[ -f "$KIT_ROOT/SSOT/$f" ]]; then
      fp="$(sha256sum "$KIT_ROOT/SSOT/$f" 2>/dev/null | cut -c1-8)"
    fi
    fp_lines="${fp_lines}  - ${f}: ${fp}"$'\n'
  done

  # SSOT match (kit SSOT/ vs repo _handoff_check/)
  local ssot_match="NO"
  if [[ -d "$MAIN_REPO/_handoff_check" ]] && [[ -d "$KIT_ROOT/SSOT" ]]; then
    local diff_result
    diff_result="$(diff -rq "$KIT_ROOT/SSOT/" "$MAIN_REPO/_handoff_check/" 2>/dev/null)" || true
    if [[ -z "$diff_result" ]]; then
      ssot_match="YES"
    fi
  fi

  cat <<EOF
## 2. Main Repo Snapshot
- path: ${MAIN_REPO}
- HEAD: ${head_short} (${head_full})
- branch: ${branch}
- status: ${status_label}
- repo_lock: ${repo_lock}
- SSOT fingerprint:
${fp_lines}- SSOT match: ${ssot_match} (kit SSOT/ vs repo _handoff_check/)
EOF
}

# ────────────────────────────────────────────────────────────────
# _hb_digest_tracker — helper: parse a single tracker file
# Args: $1=label, $2=file_path
# ────────────────────────────────────────────────────────────────
_hb_digest_tracker() {
  local label="$1"
  local fpath="$2"

  if [[ ! -f "$fpath" ]]; then
    cat <<EOF
### ${label}
- progress: N/A (file not found)
- status: UNKNOWN
- pending items:
  - (file not found: ${fpath})
- last_updated: N/A
EOF
    return 0
  fi

  local done_count total_checked total_unchecked total pct status_label
  # Match only actual checkbox lines: "- [x]" or "- [ ]" (with optional leading whitespace)
  done_count="$(grep -cP '^\s*- \[x\]' "$fpath" 2>/dev/null)" || done_count=0
  total_unchecked="$(grep -cP '^\s*- \[ \]' "$fpath" 2>/dev/null)" || total_unchecked=0
  total=$((done_count + total_unchecked))

  if [[ "$total" -gt 0 ]]; then
    pct=$(( done_count * 100 / total ))
  else
    pct=0
  fi

  # Determine status
  if [[ "$total_unchecked" -eq 0 && "$total" -gt 0 ]]; then
    # Check if any FAIL in checked items
    local fail_count
    fail_count="$(grep -c '判定: FAIL' "$fpath" 2>/dev/null)" || fail_count=0
    if [[ "$fail_count" -gt 0 ]]; then
      status_label="HAS_FAIL"
    else
      status_label="ALL_PASS"
    fi
  elif [[ "$total" -eq 0 ]]; then
    status_label="EMPTY"
  else
    status_label="IN_PROGRESS"
  fi

  # Pending items (only actual checkboxes, not description text)
  local pending_items
  pending_items="$(grep -P '^\s*- \[ \]' "$fpath" 2>/dev/null | sed 's/^\s*- \[ \] /  - /')" || true

  # Last updated (file modification time)
  local last_updated
  last_updated="$(TZ=Asia/Tokyo stat -c '%y' "$fpath" 2>/dev/null | cut -d. -f1)" || last_updated="unknown"

  echo "### ${label}"
  echo "- progress: ${done_count}/${total} (${pct}%)"
  echo "- status: ${status_label}"
  echo "- pending items:"
  if [[ -z "$pending_items" ]]; then
    echo "  - (none)"
  else
    echo "$pending_items"
  fi
  echo "- last_updated: ${last_updated}"
}

# ────────────────────────────────────────────────────────────────
# emit_trackers_digest — ## 3. Trackers Digest
# ────────────────────────────────────────────────────────────────
emit_trackers_digest() {
  _hb_ensure_roots

  echo "## 3. Trackers Digest"
  echo ""
  _hb_digest_tracker \
    "3.1 Verification Tracker (tasks/verify_task_tracker.md)" \
    "$KIT_ROOT/tasks/verify_task_tracker.md"
  echo ""
  _hb_digest_tracker \
    "3.2 Test Tracker (tasks/test_task_tracker.md)" \
    "$KIT_ROOT/tasks/test_task_tracker.md"
  echo ""
  _hb_digest_tracker \
    "3.3 As-built Tracker (tasks/as_built_task_tracker.md)" \
    "$KIT_ROOT/tasks/as_built_task_tracker.md"
  echo ""
  _hb_digest_tracker \
    "3.4 Rebuild Tracker (tasks/rebuild_task_tracker.md)" \
    "$KIT_ROOT/tasks/rebuild_task_tracker.md"
  echo ""
  _hb_digest_tracker \
    "3.5 Post-rebuild Tracker (tasks/post_rebuild_task_tracker.md)" \
    "$KIT_ROOT/tasks/post_rebuild_task_tracker.md"
  echo ""
  _hb_digest_tracker \
    "3.6 Self-check Tracker (tasks/self_check_task_tracker.md)" \
    "$KIT_ROOT/tasks/self_check_task_tracker.md"
}

# ────────────────────────────────────────────────────────────────
# _hb_evidence_entry — helper: process a single evidence file/dir
# Args: $1=path (absolute), $2=counter
# Output: a table row to stdout
# ────────────────────────────────────────────────────────────────
_hb_evidence_entry() {
  local item="$1"
  local idx="$2"
  local evidence_base="$KIT_ROOT/logs/evidence"
  local rel_path="${item#${KIT_ROOT}/}"

  if [[ -d "$item" ]]; then
    # Directory-type evidence
    local dir_name
    dir_name="$(basename "$item")"
    local purpose
    # Extract purpose from directory name (e.g., 20260202T082000Z_gateC -> Gate C verification)
    purpose="$(echo "$dir_name" | sed 's/^[0-9T]*Z\?_//' | sed 's/_/ /g')"
    if [[ -z "$purpose" ]]; then purpose="$dir_name"; fi

    local sha="N/A"
    if ls "$item"/*.txt >/dev/null 2>&1; then
      sha="$(cat "$item"/*.txt 2>/dev/null | sha256sum | cut -c1-16)"
    fi

    local verdict="UNKNOWN"
    # Try to find verdict from judgement.txt
    if [[ -f "$item/judgement.txt" ]]; then
      local v
      v="$(grep -m1 'OVERALL:' "$item/judgement.txt" 2>/dev/null | awk '{print $2}')" || true
      if [[ -n "$v" ]]; then verdict="$v"; fi
    fi

    local command="-"
    local ts_part
    ts_part="$(echo "$dir_name" | grep -oP '^\d{8}T\d{6}Z?' 2>/dev/null)" || ts_part="$dir_name"

    echo "| ${idx} | ${ts_part} | ${purpose} | ${command} | ${verdict} | ${sha} | ${rel_path} |"

  elif [[ -f "$item" ]]; then
    # File-type evidence
    local fname
    fname="$(basename "$item")"

    # Extract timestamp from filename
    local ts_part
    ts_part="$(echo "$fname" | grep -oP '^\d{8}-\d{6}' 2>/dev/null)" || \
    ts_part="$(echo "$fname" | grep -oP '^\d{8}T\d{6}Z?' 2>/dev/null)" || \
    ts_part="$fname"

    # Try to extract purpose from header (=== <Purpose> ===)
    local purpose
    purpose="$(head -1 "$item" 2>/dev/null | sed -n 's/^=== \(.*\) ===$/\1/p')" || true
    if [[ -z "$purpose" ]]; then
      # Fallback: derive from filename
      purpose="$(echo "$fname" | sed 's/^[0-9T_-]*Z\?_\?//' | sed 's/\.txt$//' | sed 's/_/ /g')"
    fi
    if [[ -z "$purpose" ]]; then purpose="$fname"; fi

    # Try to extract command
    local command="-"
    local cmd_line
    cmd_line="$(grep -m1 '^Command:' "$item" 2>/dev/null | sed 's/^Command: //')" || true
    if [[ -n "$cmd_line" ]]; then
      # Truncate long commands
      if [[ ${#cmd_line} -gt 40 ]]; then
        command="${cmd_line:0:37}..."
      else
        command="$cmd_line"
      fi
    fi

    # Try to extract verdict
    local verdict="UNKNOWN"
    local v
    v="$(grep -m1 '^VERDICT:' "$item" 2>/dev/null | awk '{print $2}')" || true
    if [[ -z "$v" ]]; then
      # Fallback: look for RESULT: or 判定:
      v="$(grep -m1 'RESULT:' "$item" 2>/dev/null | awk '{print $2}')" || true
    fi
    if [[ -z "$v" ]]; then
      # Fallback: look for CHECK: PASS pattern
      if grep -q 'PASS' "$item" 2>/dev/null; then
        v="PASS"
      fi
    fi
    if [[ -n "$v" ]]; then verdict="$v"; fi

    # SHA256
    local sha
    sha="$(sha256sum "$item" 2>/dev/null | cut -c1-16)"

    echo "| ${idx} | ${ts_part} | ${purpose} | ${command} | ${verdict} | ${sha} | ${rel_path} |"
  fi
}

# ────────────────────────────────────────────────────────────────
# emit_evidence_index — ## 4. Evidence Index
# ────────────────────────────────────────────────────────────────
emit_evidence_index() {
  _hb_ensure_roots

  local evidence_dir="$KIT_ROOT/logs/evidence"

  echo "## 4. Evidence Index"
  echo ""
  echo "| # | Timestamp | Purpose | Command | Verdict | SHA256 (first 16) | Path |"
  echo "|---|-----------|---------|---------|---------|-------------------|------|"

  if [[ ! -d "$evidence_dir" ]]; then
    echo ""
    echo "Total: 0 evidences (0 PASS, 0 FAIL, 0 DIAG)"
    return 0
  fi

  # Collect all items (files and directories), sort by name descending (newest first)
  local items=()
  local idx=0
  local pass_count=0
  local fail_count=0
  local diag_count=0
  local unknown_count=0

  while IFS= read -r item; do
    [[ -z "$item" ]] && continue
    ((idx++)) || true
    local row
    row="$(_hb_evidence_entry "$item" "$idx")"
    echo "$row"

    # Count verdicts (DIAG = diagnostic pre-check, not a final judgement)
    if echo "$row" | grep -q '| PASS |' 2>/dev/null; then
      ((pass_count++)) || true
    elif echo "$row" | grep -q '| DIAG |' 2>/dev/null; then
      ((diag_count++)) || true
    elif echo "$row" | grep -q '| FAIL |' 2>/dev/null; then
      ((fail_count++)) || true
    else
      ((unknown_count++)) || true
    fi
  done < <(ls -1td "$evidence_dir"/* 2>/dev/null || true)

  echo ""
  local total=$((pass_count + fail_count + diag_count + unknown_count))
  echo "Total: ${total} evidences (${pass_count} PASS, ${fail_count} FAIL, ${diag_count} DIAG, ${unknown_count} UNKNOWN)"
}

# ────────────────────────────────────────────────────────────────
# emit_kit_files — ## 5. Kit Files
# ────────────────────────────────────────────────────────────────
emit_kit_files() {
  cat <<'EOF'
## 5. Kit Files
- SSOT/cf_handoff_prompt.md
- SSOT/cf_update_runbook.md
- SSOT/cf_task_tracker_v5.md
- verify/verify_requirements.md
- verify/verify_spec.md
- verify/verify_implementation_plan.md
- context/run_rules.md
- context/codex_high_prompt.md
EOF
}

# ────────────────────────────────────────────────────────────────
# emit_commands — ## 6. Commands
# ────────────────────────────────────────────────────────────────
emit_commands() {
  cat <<'EOF'
## 6. Commands
```
./kit handoff          latest.md を再生成
./kit verify [GATE]    検証実行 (例: ./kit verify C)
./kit test [PHASE]     テスト実行 (例: ./kit test 2)
./kit all              verify + test + handoff 一気通貫
./kit status           進捗サマリ表示
```
EOF
}

# ────────────────────────────────────────────────────────────────
# emit_notes — ## 7. Notes
# ────────────────────────────────────────────────────────────────
emit_notes() {
  cat <<'EOF'
## 7. Notes
- This kit is generated outside repo by default (safety).
- Evidence is saved under logs/evidence/ and referenced from trackers.
- verify/ docs are canonical (do not modify).
EOF
}
