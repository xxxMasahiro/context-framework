#!/usr/bin/env bash
# ciqa_common.sh — CI/QA common helper functions
# Usage: source scripts/lib/ciqa_common.sh
# Provides: ciqa_emit_header, ciqa_emit_verdict, ciqa_count_checked,
#           ciqa_count_unchecked, ciqa_ts_jst, ciqa_ts_utc, ciqa_ts_label

if [[ -n "${_CIQA_COMMON_LOADED:-}" ]]; then return 0 2>/dev/null || true; fi
_CIQA_COMMON_LOADED=1

# ── Timestamps ─────────────────────────────────────────────────
ciqa_ts_jst()   { TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S %Z'; }
ciqa_ts_utc()   { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
ciqa_ts_label() { date -u +"%Y%m%d-%H%M%S"; }

# ── Evidence header ────────────────────────────────────────────
# Usage: ciqa_emit_header <check_name> <check_id>
ciqa_emit_header() {
  local check_name="$1"
  local check_id="$2"
  cat <<EOF
=== CIQA: ${check_name} ===
Timestamp (JST): $(ciqa_ts_jst)
Timestamp (UTC): $(ciqa_ts_utc)
Check: ${check_id}
EOF
}

# ── Verdict line ───────────────────────────────────────────────
# Usage: ciqa_emit_verdict <PASS|FAIL> <reason>
ciqa_emit_verdict() {
  local verdict="$1"
  local reason="$2"
  echo "VERDICT: ${verdict}"
  echo "---"
  echo "Reason: ${reason}"
}

# ── Tracker counters ───────────────────────────────────────────
# Usage: ciqa_count_checked <tracker_file>
ciqa_count_checked() {
  local f="$1"
  grep -cP '^\s*- \[x\]' "$f" 2>/dev/null || echo 0
}

# Usage: ciqa_count_unchecked <tracker_file>
ciqa_count_unchecked() {
  local f="$1"
  grep -cP '^\s*- \[ \]' "$f" 2>/dev/null || echo 0
}

# ── sha256 first 16 ───────────────────────────────────────────
ciqa_sha16() {
  sha256sum "$1" | cut -c1-16
}

# ── Load config ────────────────────────────────────────────────
# Usage: ciqa_load_config
# Sets: CIQA_CHECKS, CIQA_LINT_SEVERITY, CIQA_BASELINE_DIR,
#       CIQA_TRACKER_FILES (array), CIQA_DOC_PAIRS (array)
ciqa_load_config() {
  local config_file="${CIQA_CONFIG:-${KIT_ROOT}/config/ciqa.conf}"
  if [[ ! -f "$config_file" ]]; then
    echo "WARN: config not found: ${config_file}, using defaults" >&2
    CIQA_CHECKS="all"
    CIQA_LINT_SEVERITY="warning"
    CIQA_BASELINE_DIR="logs/ciqa/baseline"
    CIQA_TRACKER_FILES=()
    CIQA_DOC_PAIRS=()
    return 0
  fi

  # Parse simple key=value (ignore comments and blank lines)
  local checks="" lint_severity="" baseline_dir="" tracker_files="" doc_pairs=""
  local lint_targets="" naming_pattern=""
  while IFS='=' read -r key val; do
    # Strip leading/trailing whitespace
    key="$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    val="$(echo "$val" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
    [[ -z "$key" || "$key" == \#* ]] && continue
    case "$key" in
      checks)                  checks="$val" ;;
      lint_severity)           lint_severity="$val" ;;
      lint_targets)            lint_targets="$val" ;;
      naming_pattern)          naming_pattern="$val" ;;
      regression_baseline_dir) baseline_dir="$val" ;;
      tracker_files)           tracker_files="$val" ;;
      doc_pairs)               doc_pairs="$val" ;;
    esac
  done < "$config_file"

  CIQA_CHECKS="${checks:-all}"
  CIQA_LINT_SEVERITY="${lint_severity:-warning}"
  CIQA_BASELINE_DIR="${baseline_dir:-logs/ciqa/baseline}"
  if [[ -n "$naming_pattern" ]]; then
    CIQA_NAMING_PATTERN="$naming_pattern"
  else
    CIQA_NAMING_PATTERN='^[0-9]{8}[-T][0-9]{6}Z?_'
  fi

  # Split comma-separated into arrays
  IFS=',' read -ra CIQA_TRACKER_FILES <<< "${tracker_files:-}"
  IFS=',' read -ra CIQA_DOC_PAIRS <<< "${doc_pairs:-}"
  IFS=',' read -ra CIQA_LINT_TARGETS <<< "${lint_targets:-}"
}
