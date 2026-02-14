#!/usr/bin/env bash
# self_check_common.sh — Self-check common helper functions
# Usage: source scripts/lib/self_check_common.sh
# Provides: sc_emit_header, sc_emit_verdict, sc_count_checked,
#           sc_count_unchecked, sc_ts_jst, sc_ts_utc, sc_ts_label

if [[ -n "${_SC_COMMON_LOADED:-}" ]]; then return 0 2>/dev/null || true; fi
_SC_COMMON_LOADED=1

# ── Timestamps ─────────────────────────────────────────────────
sc_ts_jst()   { TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S %Z'; }
sc_ts_utc()   { date -u '+%Y-%m-%dT%H:%M:%SZ'; }
sc_ts_label() { date -u +"%Y%m%d-%H%M%S"; }

# ── Evidence header ────────────────────────────────────────────
# Usage: sc_emit_header <check_name> <check_id>
sc_emit_header() {
  local check_name="$1"
  local check_id="$2"
  cat <<EOF
=== Self-check: ${check_name} ===
Timestamp (JST): $(sc_ts_jst)
Timestamp (UTC): $(sc_ts_utc)
Check: ${check_id}
EOF
}

# ── Verdict line ───────────────────────────────────────────────
# Usage: sc_emit_verdict <PASS|FAIL> <reason>
sc_emit_verdict() {
  local verdict="$1"
  local reason="$2"
  echo "VERDICT: ${verdict}"
  echo "---"
  echo "Reason: ${reason}"
}

# ── Tracker counters ───────────────────────────────────────────
# Usage: sc_count_checked <tracker_file>
sc_count_checked() {
  local f="$1"
  grep -cP '^\s*- \[x\]' "$f" 2>/dev/null || echo 0
}

# Usage: sc_count_unchecked <tracker_file>
sc_count_unchecked() {
  local f="$1"
  grep -cP '^\s*- \[ \]' "$f" 2>/dev/null || echo 0
}

# ── sha256 first 16 ───────────────────────────────────────────
sc_sha16() {
  sha256sum "$1" | cut -c1-16
}

# ── Load config ────────────────────────────────────────────────
# Usage: sc_load_config
# Sets: SC_CHECKS, SC_LINT_SEVERITY, SC_BASELINE_DIR,
#       SC_TRACKER_FILES (array), SC_DOC_PAIRS (array)
sc_load_config() {
  local config_file="${SC_CONFIG:-${KIT_ROOT}/config/self-check.conf}"
  if [[ ! -f "$config_file" ]]; then
    echo "WARN: config not found: ${config_file}, using defaults" >&2
    SC_CHECKS="all"
    SC_LINT_SEVERITY="warning"
    SC_BASELINE_DIR="logs/self-check/baseline"
    SC_TRACKER_FILES=()
    SC_DOC_PAIRS=()
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

  SC_CHECKS="${checks:-all}"
  SC_LINT_SEVERITY="${lint_severity:-warning}"
  SC_BASELINE_DIR="${baseline_dir:-logs/self-check/baseline}"
  if [[ -n "$naming_pattern" ]]; then
    SC_NAMING_PATTERN="$naming_pattern"
  else
    SC_NAMING_PATTERN='^[0-9]{8}[-T][0-9]{6}Z?_'
  fi

  # Split comma-separated into arrays
  IFS=',' read -ra SC_TRACKER_FILES <<< "${tracker_files:-}"
  IFS=',' read -ra SC_DOC_PAIRS <<< "${doc_pairs:-}"
  IFS=',' read -ra SC_LINT_TARGETS <<< "${lint_targets:-}"
}
