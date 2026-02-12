#!/usr/bin/env bash
# tracker_updater.sh — トラッカー自動更新ロジック（関数群）
# Usage: source scripts/lib/tracker_updater.sh
#
# Functions:
#   update_verify_tracker <gate> <verdict> <evidence_path>
#   update_test_tracker <phase> <verdict> <evidence_path>
#   append_progress_log <tracker_file> <message>

if [[ -z "${_TRACKER_UPDATER_LOADED:-}" ]]; then
  _TRACKER_UPDATER_LOADED=1
fi

# ── Resolve KIT_ROOT ──────────────────────────────────────────
_tu_init_kit_root() {
  if [[ -n "${KIT_ROOT:-}" ]]; then return 0; fi
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  KIT_ROOT="$(cd "${script_dir}/../.." && pwd)"
  export KIT_ROOT
}

# ── JST timestamp helpers ─────────────────────────────────────
_tu_ts_jst() { TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M JST'; }
_tu_ts_jst_short() { TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M'; }

# ────────────────────────────────────────────────────────────────
# _tu_update_section_checkboxes
#   Generic: find a section by heading pattern, then mark ALL
#   unchecked `- [ ]` items within that section as `- [x]`,
#   appending verdict/evidence/timestamp metadata lines below.
#
# Args:
#   $1 = tracker file path (absolute)
#   $2 = section heading grep pattern (e.g. "### Gate A")
#   $3 = verdict (PASS|FAIL)
#   $4 = evidence relative path (e.g. logs/evidence/...)
#
# Returns: 0 if updated, 1 if no unchecked items found
# ────────────────────────────────────────────────────────────────
_tu_update_section_checkboxes() {
  local tracker="$1"
  local section_pattern="$2"
  local verdict="$3"
  local evidence_path="$4"
  local ts_jst
  ts_jst="$(_tu_ts_jst)"

  if [[ ! -f "$tracker" ]]; then
    echo "WARN: tracker not found: $tracker" >&2
    return 1
  fi

  # Check if section exists
  if ! grep -q "$section_pattern" "$tracker" 2>/dev/null; then
    echo "WARN: section '$section_pattern' not found in $tracker" >&2
    return 1
  fi

  # Check if there are unchecked items in that section
  # We use awk to extract the section and check for [ ]
  local has_unchecked
  has_unchecked="$(awk -v pat="$section_pattern" '
    $0 ~ pat { found=1; next }
    found && /^###? / { found=0 }
    found && /^- \[ \]/ { print; }
  ' "$tracker")" || true

  if [[ -z "$has_unchecked" ]]; then
    echo "INFO: no unchecked items in section '$section_pattern'" >&2
    return 1
  fi

  # Build the replacement metadata block
  local meta_block
  meta_block="  - 判定: ${verdict}\\
  - Evidence: ${evidence_path}\\
  - 日時: ${ts_jst}"

  # Use awk to process: within the target section, replace `- [ ]` with `- [x]`
  # and insert metadata lines after each replaced checkbox.
  local tmpfile="${tracker}.tmp.$$"
  awk -v pat="$section_pattern" \
      -v verdict="$verdict" \
      -v evidence="$evidence_path" \
      -v ts_jst="$ts_jst" '
    BEGIN { in_section = 0 }
    $0 ~ pat { in_section = 1; print; next }
    # Exit section on next heading of same or higher level
    in_section && /^###? / { in_section = 0 }
    in_section && /^- \[ \]/ {
      sub(/^- \[ \]/, "- [x]")
      print
      print "  - 判定: " verdict
      print "  - Evidence: " evidence
      print "  - 日時: " ts_jst
      next
    }
    { print }
  ' "$tracker" > "$tmpfile"

  mv "$tmpfile" "$tracker"
  return 0
}

# ────────────────────────────────────────────────────────────────
# _tu_auto_create_gate_section <tracker_file> <gate_id>
#   Auto-creates a "### Gate <ID>" section with standard checkbox
#   items when a new Gate is detected but its section does not exist.
#   Inserts before "## Progress Log" (or appends to end).
# ────────────────────────────────────────────────────────────────
_tu_auto_create_gate_section() {
  local tracker="$1"
  local gate="$2"
  local ts_jst
  ts_jst="$(_tu_ts_jst)"

  local new_section
  new_section="### Gate ${gate}
- [ ] 要件①：追加/変更の要約（SSOT/ログ/差分）
- [ ] 要件②：体系整合（参照切れ/定義衝突/SSOT↔実装矛盾なし）
- [ ] 要件③：機能性（PASS/FAIL を伴う確認）
"

  if grep -q '^## Progress Log' "$tracker" 2>/dev/null; then
    # Insert before "## Progress Log"
    local tmpfile="${tracker}.tmp.$$"
    awk -v section="$new_section" '
      /^## Progress Log/ { printf "%s\n", section }
      { print }
    ' "$tracker" > "$tmpfile"
    mv "$tmpfile" "$tracker"
  else
    # Append to end
    printf '\n%s\n' "$new_section" >> "$tracker"
  fi

  echo "OK: auto-created section '### Gate ${gate}' in $(basename "$tracker")"
}

# ────────────────────────────────────────────────────────────────
# update_verify_tracker <gate> <verdict> <evidence_path>
#   Updates tasks/verify_task_tracker.md for the specified gate.
#   Marks all unchecked items under "### Gate <gate>" as checked.
#
# Args:
#   gate          — single letter: A, B, C, ..., I
#   verdict       — PASS or FAIL
#   evidence_path — relative path under kit root
# ────────────────────────────────────────────────────────────────
update_verify_tracker() {
  local gate="$1"
  local verdict="$2"
  local evidence_path="$3"
  _tu_init_kit_root

  local tracker="$KIT_ROOT/tasks/verify_task_tracker.md"
  local section_pattern="### Gate ${gate}"

  # Auto-create section if it does not exist (supports dynamic Gate addition)
  if ! grep -q "$section_pattern" "$tracker" 2>/dev/null; then
    _tu_auto_create_gate_section "$tracker" "$gate"
  fi

  if _tu_update_section_checkboxes "$tracker" "$section_pattern" "$verdict" "$evidence_path"; then
    echo "OK: verify_task_tracker.md Gate ${gate} updated (${verdict})"
  else
    echo "INFO: verify_task_tracker.md Gate ${gate} — no unchecked items to update"
  fi
}

# ────────────────────────────────────────────────────────────────
# update_test_tracker <phase> <verdict> <evidence_path>
#   Updates tasks/test_task_tracker.md for the specified phase.
#   Marks all unchecked items under "### Phase <phase>" as checked.
#
# Args:
#   phase         — 1, 2, or 3
#   verdict       — PASS or FAIL
#   evidence_path — relative path under kit root
# ────────────────────────────────────────────────────────────────
update_test_tracker() {
  local phase="$1"
  local verdict="$2"
  local evidence_path="$3"
  _tu_init_kit_root

  local tracker="$KIT_ROOT/tasks/test_task_tracker.md"
  local section_pattern="### Phase ${phase}"

  if _tu_update_section_checkboxes "$tracker" "$section_pattern" "$verdict" "$evidence_path"; then
    echo "OK: test_task_tracker.md Phase ${phase} updated (${verdict})"
  else
    echo "INFO: test_task_tracker.md Phase ${phase} — no unchecked items to update"
  fi
}

# ────────────────────────────────────────────────────────────────
# append_progress_log <tracker_file> <message>
#   Appends a timestamped entry to the "## Progress Log" section
#   at the end of the specified tracker file.
#
# Args:
#   tracker_file — absolute path to tracker .md
#   message      — log message (without timestamp prefix)
# ────────────────────────────────────────────────────────────────
append_progress_log() {
  local tracker="$1"
  local message="$2"
  local ts_jst
  ts_jst="$(_tu_ts_jst_short)"

  if [[ ! -f "$tracker" ]]; then
    echo "WARN: tracker not found: $tracker" >&2
    return 1
  fi

  # Check if Progress Log section exists
  if ! grep -q '^## Progress Log' "$tracker" 2>/dev/null; then
    # Append the section if missing
    printf '\n## Progress Log\n\n' >> "$tracker"
  fi

  # Append the entry at the end of the file (Progress Log is always last)
  printf -- '- %s JST | %s\n' "$ts_jst" "$message" >> "$tracker"

  echo "OK: appended to Progress Log in $(basename "$tracker")"
}
