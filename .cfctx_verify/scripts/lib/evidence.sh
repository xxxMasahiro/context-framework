#!/usr/bin/env bash
# evidence.sh — Common evidence functions for Gate verification
# Usage: source scripts/lib/evidence.sh

set -euo pipefail

# ── Globals (set by init_evidence; preserved if already set) ────
EVIDENCE_DIR="${EVIDENCE_DIR:-}"
EVIDENCE_META="${EVIDENCE_META:-}"
EVIDENCE_REFS_DIR="${EVIDENCE_REFS_DIR:-}"
EVIDENCE_CHECKSUMS="${EVIDENCE_CHECKSUMS:-}"
EVIDENCE_COMMANDS="${EVIDENCE_COMMANDS:-}"
EVIDENCE_JUDGEMENT_FILE="${EVIDENCE_JUDGEMENT_FILE:-}"
MAIN_REPO="${MAIN_REPO:-}"
KIT_ROOT="${KIT_ROOT:-}"

# ── Validate main repo ──────────────────────────────────────────
# Validates that a candidate path is actually context-framework.
# Checks:
#   1. .git directory exists (git repository)
#   2. _handoff_check/ directory exists (SSOT source — definitive marker)
#   3. At least one of: WORKFLOW/, controller/, rules/ exists (structural marker)
#   4. SSOT fingerprint match: Kit SSOT/ の sha256 と候補 repo _handoff_check/ を比較
#      (Kit SSOT が存在する場合のみ。全ファイル一致で PASS。不一致は WARN で候補を棄却)
# Returns: 0 if valid, 1 if invalid.
_validate_main_repo() {
  local candidate="$1"

  # Must be a git repository
  [[ -d "${candidate}/.git" ]] || return 1

  # Must have _handoff_check/ (SSOT source — unique to context-framework)
  if [[ ! -d "${candidate}/_handoff_check" ]]; then
    echo "WARN: Candidate repo missing _handoff_check/: ${candidate}" >&2
    return 1
  fi

  # Must have at least one structural marker
  if [[ ! -d "${candidate}/WORKFLOW" && ! -d "${candidate}/controller" && ! -d "${candidate}/rules" ]]; then
    echo "WARN: Candidate repo missing structural markers (WORKFLOW/controller/rules): ${candidate}" >&2
    return 1
  fi

  # SSOT fingerprint match (if Kit SSOT/ exists)
  local kit="${KIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local ssot_dir="${kit}/SSOT"
  if [[ -d "$ssot_dir" ]]; then
    local ssot_files=("cf_handoff_prompt.md" "cf_update_runbook.md" "cf_task_tracker_v5.md")
    for sf in "${ssot_files[@]}"; do
      local kit_f="${ssot_dir}/${sf}"
      local repo_f="${candidate}/_handoff_check/${sf}"
      if [[ -f "$kit_f" && -f "$repo_f" ]]; then
        local h1 h2
        h1="$(sha256sum "$kit_f" | awk '{print $1}')"
        h2="$(sha256sum "$repo_f" | awk '{print $1}')"
        if [[ "$h1" != "$h2" ]]; then
          echo "WARN: SSOT mismatch for ${sf} — candidate repo is not the expected version: ${candidate}" >&2
          return 1
        fi
      fi
    done
  fi

  return 0
}

# ── Discover main repo ──────────────────────────────────────────
# Resolution order:
#   1. CFCTX_MAIN_REPO env var (explicit override)
#   2. MAIN_REPO env var (if already set by caller)
#   3. Sibling directory: KIT_ROOT/../context-framework
#   4. CFCTX_SEARCH_PATH entries (colon-separated, default: $HOME/projects)
# All candidates are validated via _validate_main_repo() before acceptance.
# Returns: absolute path to main repo on stdout; exit 1 if not found.
discover_main_repo() {
  # 1. Explicit override
  if [[ -n "${CFCTX_MAIN_REPO:-}" ]]; then
    if _validate_main_repo "$CFCTX_MAIN_REPO"; then
      echo "$CFCTX_MAIN_REPO"
      return 0
    else
      echo "WARN: CFCTX_MAIN_REPO set but validation failed: ${CFCTX_MAIN_REPO}" >&2
    fi
  fi

  # 2. Already set
  if [[ -n "${MAIN_REPO:-}" ]]; then
    if _validate_main_repo "$MAIN_REPO"; then
      echo "$MAIN_REPO"
      return 0
    else
      echo "WARN: MAIN_REPO set but validation failed: ${MAIN_REPO}" >&2
    fi
  fi

  # 3. Sibling of kit's parent (common layout: parent/context-framework + parent/.cfctx_verify)
  local kit="${KIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  local sibling
  sibling="$(cd "$kit/.." 2>/dev/null && pwd)/context-framework" || true
  if _validate_main_repo "$sibling" 2>/dev/null; then
    echo "$sibling"
    return 0
  fi

  # 4. Search under CFCTX_SEARCH_PATH (default: $HOME/projects)
  local search_path="${CFCTX_SEARCH_PATH:-${HOME}/projects}"
  local IFS=':'
  for base_dir in $search_path; do
    [[ -d "$base_dir" ]] || continue
    local found_line
    while IFS= read -r found_line; do
      [[ -n "$found_line" ]] || continue
      if _validate_main_repo "$found_line" 2>/dev/null; then
        echo "$found_line"
        return 0
      fi
    done < <(find "$base_dir" -maxdepth 3 -type d -name "context-framework" 2>/dev/null || true)
  done

  echo ""
  return 1
}

# ── Timestamps ──────────────────────────────────────────────────
ts_utc() { date -u +"%Y%m%dT%H%M%SZ"; }
ts_jst() { TZ=Asia/Tokyo date +"%Y-%m-%dT%H:%M:%S%z"; }
ts_label() { date -u +"%Y%m%dT%H%M%SZ"; }

# ── Init evidence directory for a gate ──────────────────────────
# Usage: init_evidence <gate_label>   e.g. init_evidence "gateA"
init_evidence() {
  local gate_label="$1"
  local ts
  ts=$(ts_label)

  KIT_ROOT="${KIT_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
  MAIN_REPO="${MAIN_REPO:-$(discover_main_repo)}"

  if [[ -z "$MAIN_REPO" ]]; then
    echo "FATAL: Cannot find main repo. Set CFCTX_MAIN_REPO or CFCTX_SEARCH_PATH." >&2
    return 1
  fi

  EVIDENCE_DIR="${KIT_ROOT}/logs/evidence/${ts}_${gate_label}"
  EVIDENCE_REFS_DIR="${EVIDENCE_DIR}/references"
  EVIDENCE_META="${EVIDENCE_DIR}/meta.txt"
  EVIDENCE_CHECKSUMS="${EVIDENCE_DIR}/checksums.sha256"
  EVIDENCE_COMMANDS="${EVIDENCE_DIR}/commands.txt"
  EVIDENCE_JUDGEMENT_FILE="${EVIDENCE_DIR}/judgement.txt"

  mkdir -p "$EVIDENCE_REFS_DIR"

  # Write meta
  {
    echo "=== Evidence Meta ==="
    echo "ts_utc: $(ts_utc)"
    echo "ts_jst: $(ts_jst)"
    echo "gate: ${gate_label}"
    echo "main_repo_path: ${MAIN_REPO}"
    echo "main_repo_head: $(cd "$MAIN_REPO" && git rev-parse HEAD 2>&1 || echo 'N/A')"
    local repo_status
    repo_status=$(cd "$MAIN_REPO" && git status --porcelain 2>&1) || repo_status="(git status failed)"
    if [[ -z "$repo_status" ]]; then
      echo "main_repo_status: clean"
    else
      echo "main_repo_status:"
      echo "$repo_status" | sed 's/^/  /'
    fi
    echo "kit_root: ${KIT_ROOT}"
    echo ""
  } > "$EVIDENCE_META"

  # Init checksums and commands files
  : > "$EVIDENCE_CHECKSUMS"
  : > "$EVIDENCE_COMMANDS"
}

# ── Record a referenced file ────────────────────────────────────
# Usage: record_ref <relative_path_in_repo>
# Copies file to references/ and appends sha256 to checksums.
# Path in checksums.sha256 is "references/<rel_path>" so that
#   (cd EVIDENCE_DIR && sha256sum -c checksums.sha256) works.
# Duplicate calls for the same rel_path are silently skipped.
record_ref() {
  local rel_path="$1"
  local full_path="${MAIN_REPO}/${rel_path}"
  local ref_rel="references/${rel_path}"

  # Dedup: skip if already recorded
  if grep -qF "  ${ref_rel}" "$EVIDENCE_CHECKSUMS" 2>/dev/null; then
    return 0
  fi

  if [[ ! -f "$full_path" ]]; then
    echo "WARN: reference file not found: ${rel_path}" >> "$EVIDENCE_COMMANDS"
    echo "NOT_FOUND  ${ref_rel}" >> "$EVIDENCE_CHECKSUMS"
    return 0
  fi

  # Copy with directory structure
  local dest_dir
  dest_dir="${EVIDENCE_REFS_DIR}/$(dirname "$rel_path")"
  mkdir -p "$dest_dir"
  cp "$full_path" "${EVIDENCE_REFS_DIR}/${rel_path}"

  # Record sha256 — hash the COPY so verification is self-contained
  local hash
  hash=$(sha256sum "${EVIDENCE_REFS_DIR}/${rel_path}" | awk '{print $1}')
  echo "${hash}  ${ref_rel}" >> "$EVIDENCE_CHECKSUMS"
}

# ── Record a command that was executed ──────────────────────────
record_cmd() {
  local cmd_desc="$1"
  echo "[$(ts_utc)] $cmd_desc" >> "$EVIDENCE_COMMANDS"
}

# ── Run a check and capture output ──────────────────────────────
# Usage: run_check <description> <command...>
# Returns: command exit code (0=pass)
# Output is appended to the evidence directory
run_check() {
  local desc="$1"
  shift
  local output_file="${EVIDENCE_DIR}/${desc// /_}.txt"

  record_cmd "CHECK: $desc — $*"

  {
    echo "=== Check: $desc ==="
    echo "Command: $*"
    echo "Timestamp: $(ts_utc)"
    echo "---"
  } > "$output_file"

  local rc=0
  "$@" >> "$output_file" 2>&1 || rc=$?

  {
    echo ""
    echo "---"
    echo "Exit code: $rc"
  } >> "$output_file"

  return $rc
}

# ── Write judgement ─────────────────────────────────────────────
# Usage: write_judgement <PASS|FAIL> <reason> [<req_label>]
write_judgement() {
  local result="$1"
  local reason="$2"
  local req_label="${3:-}"

  {
    if [[ -n "$req_label" ]]; then
      echo "=== JUDGEMENT (${req_label}) ==="
    else
      echo "=== JUDGEMENT ==="
    fi
    echo "RESULT: ${result}"
    echo "REASON: ${reason}"
    echo "TIMESTAMP: $(ts_utc)"
    echo "EVIDENCE_DIR: ${EVIDENCE_DIR}"
    echo ""
  } >> "$EVIDENCE_JUDGEMENT_FILE"

  # Also echo to stdout for summary
  if [[ -n "$req_label" ]]; then
    echo "  ${req_label}: ${result} — ${reason}"
  else
    echo "  ${result} — ${reason}"
  fi
}

# ── Gate-level summary ──────────────────────────────────────────
# Usage: gate_summary <gate_label> <pass_count> <fail_count> <total>
# Strict rule: runs sha256sum -c on checksums.sha256;
#              any checksum failure → gate FAIL (no warning-PASS).
gate_summary() {
  local gate_label="$1"
  local pass="$2"
  local fail="$3"
  local total="$4"

  # ── Strict checksum integrity check ──
  local cksum_ok=true
  if [[ -s "$EVIDENCE_CHECKSUMS" ]]; then
    # Filter out NOT_FOUND lines before checking
    local tmpck="${EVIDENCE_DIR}/_valid_checksums.sha256"
    grep -v "^NOT_FOUND " "$EVIDENCE_CHECKSUMS" > "$tmpck" 2>/dev/null || true
    if [[ -s "$tmpck" ]]; then
      if ! (cd "$EVIDENCE_DIR" && sha256sum -c "$tmpck" > /dev/null 2>&1); then
        cksum_ok=false
      fi
    fi
    rm -f "$tmpck"
  fi

  if [[ "$cksum_ok" == "false" ]]; then
    ((fail++)) || true
    ((total++)) || true
    {
      echo "=== JUDGEMENT (checksum_integrity) ==="
      echo "RESULT: FAIL"
      echo "REASON: sha256sum -c checksums.sha256 failed — reference file integrity broken"
      echo "TIMESTAMP: $(ts_utc)"
      echo "EVIDENCE_DIR: ${EVIDENCE_DIR}"
      echo ""
    } >> "$EVIDENCE_JUDGEMENT_FILE"
    echo "  checksum_integrity: FAIL — sha256sum -c failed"
  fi

  local overall="PASS"
  if [[ "$fail" -gt 0 ]]; then
    overall="FAIL"
  fi

  {
    echo "=== Gate Summary ==="
    echo "Gate: ${gate_label}"
    echo "PASS: ${pass}/${total}"
    echo "FAIL: ${fail}/${total}"
    echo "CHECKSUM_INTEGRITY: ${cksum_ok}"
    echo "OVERALL: ${overall}"
    echo "EVIDENCE_DIR: ${EVIDENCE_DIR}"
    echo "TIMESTAMP: $(ts_utc)"
  } >> "$EVIDENCE_JUDGEMENT_FILE"

  # Emit evidence path marker for kit tracker auto-update
  local _gate_id="${gate_label##* }"
  echo "GATE_EVIDENCE:${_gate_id}:${EVIDENCE_DIR#${KIT_ROOT}/}"

  echo "${overall}"
}

# ── Check file exists in repo ───────────────────────────────────
# Usage: check_file_exists <relative_path> [<description>]
check_file_exists() {
  local rel="$1"
  local desc="${2:-$rel}"
  local full="${MAIN_REPO}/${rel}"

  if [[ -f "$full" ]]; then
    record_ref "$rel"
    record_cmd "EXISTS: ${desc} (${rel})"
    return 0
  else
    record_cmd "MISSING: ${desc} (${rel})"
    return 1
  fi
}

# ── Check directory exists in repo ──────────────────────────────
check_dir_exists() {
  local rel="$1"
  local desc="${2:-$rel}"
  local full="${MAIN_REPO}/${rel}"

  if [[ -d "$full" ]]; then
    record_cmd "DIR EXISTS: ${desc} (${rel})"
    return 0
  else
    record_cmd "DIR MISSING: ${desc} (${rel})"
    return 1
  fi
}

# ── Grep in repo file (safe, || true internally) ────────────────
# Usage: repo_grep <pattern> <relative_path>
# Returns 0 if found, 1 if not found
repo_grep() {
  local pattern="$1"
  local rel="$2"
  local full="${MAIN_REPO}/${rel}"

  if [[ ! -f "$full" ]]; then
    return 1
  fi

  grep -q "$pattern" "$full" 2>/dev/null || return 1
  return 0
}

# ── Grep in repo file and capture matches ───────────────────────
# Usage: repo_grep_capture <pattern> <relative_path>
# Outputs matching lines; returns grep exit code
repo_grep_capture() {
  local pattern="$1"
  local rel="$2"
  local full="${MAIN_REPO}/${rel}"

  if [[ ! -f "$full" ]]; then
    return 1
  fi

  grep -n "$pattern" "$full" 2>/dev/null || return 1
}

# ── Count files in repo directory ───────────────────────────────
repo_file_count() {
  local rel_dir="$1"
  local full="${MAIN_REPO}/${rel_dir}"
  if [[ -d "$full" ]]; then
    find "$full" -maxdepth 1 -type f | wc -l
  else
    echo 0
  fi
}
