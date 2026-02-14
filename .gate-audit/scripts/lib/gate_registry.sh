#!/usr/bin/env bash
# gate_registry.sh — Gate auto-discovery registry
#
# Automatically discovers gate_*.sh files and resolves Gate IDs / verify functions.
# Adding a new Gate requires only:
#   1. Create scripts/lib/gate_<id>.sh  (id = lowercase letter)
#   2. Define verify_gate_<id>() inside that file
# No changes to verify_all.sh, verify_gate.sh, or kit are needed.

# ── Resolve LIB_DIR ─────────────────────────────────────────
_GR_LIB_DIR="${_GR_LIB_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# ── _gr_is_safe_gate_id ─────────────────────────────────────
# Gate file IDs must be safe for function name and regex usage.
# Allowed: lowercase letters, digits, underscore.
_gr_is_safe_gate_id() {
  local id="${1:-}"
  [[ "$id" =~ ^[a-z0-9_]+$ ]]
}

# ── gr_list_gate_scripts ────────────────────────────────────
# Prints absolute paths of all gate_*.sh files (sorted).
# Excludes gate_registry.sh itself.
gr_list_gate_scripts() {
  local f
  for f in "${_GR_LIB_DIR}"/gate_*.sh; do
    [[ -f "$f" ]] || continue
    [[ "$(basename "$f")" == "gate_registry.sh" ]] && continue
    echo "$f"
  done
}

# ── gr_list_gate_ids ────────────────────────────────────────
# Prints Gate IDs (uppercase) derived from gate_<id>.sh filenames.
# Example output: A B C ... (one per line)
gr_list_gate_ids() {
  local f base id
  while IFS= read -r f; do
    base="$(basename "$f" .sh)"        # gate_a
    id="${base#gate_}"                  # a
    if ! _gr_is_safe_gate_id "$id"; then
      echo "FATAL: gate with unsafe ID '${id}' (must match [a-z0-9_]+). Aborting." >&2
      exit 1
    fi
    echo "${id^^}"                      # A
  done < <(gr_list_gate_scripts)
}

# ── gr_gate_func_for_id ────────────────────────────────────
# Usage: gr_gate_func_for_id <ID>
# Returns the verify function name for a Gate ID.
# Example: gr_gate_func_for_id A  =>  verify_gate_a
gr_gate_func_for_id() {
  local id="${1:?Usage: gr_gate_func_for_id <GATE_ID>}"
  local lower="${id,,}"
  echo "verify_gate_${lower}"
}

# ── gr_source_all_gates ────────────────────────────────────
# Sources all gate_*.sh files and verifies that the expected
# verify_gate_<id> function exists. Dies with FATAL on missing function.
gr_source_all_gates() {
  local f base id func
  while IFS= read -r f; do
    base="$(basename "$f" .sh)"
    id="${base#gate_}"
    if ! _gr_is_safe_gate_id "$id"; then
      echo "FATAL: gate source with unsafe ID '${id}' (must match [a-z0-9_]+). Aborting." >&2
      exit 1
    fi
    source "$f"
    func="verify_gate_${id}"
    if ! declare -F "$func" >/dev/null 2>&1; then
      echo "FATAL: ${f} was sourced but function '${func}' is not defined." >&2
      exit 1
    fi
  done < <(gr_list_gate_scripts)
}
