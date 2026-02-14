#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# Verification Kit: unified handoff generator (v2 — rebuild)
# Output: handoff/latest.md (and latest.txt)
#
# Uses scripts/lib/handoff_builder.sh emit_* functions to
# produce a self-contained latest.md that captures all kit
# state without requiring the reader to open referenced files.
# ============================================================

# ── Resolve KIT_ROOT ───────────────────────────────────────
# Derive from this script's location (scripts/ -> kit root)
# This avoids hardcoding the kit directory name.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
export KIT_ROOT

OUT_MD="${KIT_ROOT}/handoff/latest.md"
OUT_TXT="${KIT_ROOT}/handoff/latest.txt"

mkdir -p "${KIT_ROOT}/handoff"

# ── Source evidence.sh (discover_main_repo, repo_grep etc.) ─
EVIDENCE="${KIT_ROOT}/scripts/lib/evidence.sh"
if [[ -f "$EVIDENCE" ]]; then
  # shellcheck source=lib/evidence.sh
  source "$EVIDENCE"
fi

# ── Source handoff_builder (emit_* functions) ──────────────
BUILDER="${KIT_ROOT}/scripts/lib/handoff_builder.sh"
if [[ ! -f "$BUILDER" ]]; then
  echo "FAIL: handoff_builder.sh not found at ${BUILDER}" >&2
  exit 1
fi
# shellcheck source=lib/handoff_builder.sh
source "$BUILDER"

# ── Generate latest.md ─────────────────────────────────────
{
  echo "# Verification Kit Handoff"
  echo ""
  emit_meta
  echo ""
  emit_main_repo_snapshot
  echo ""
  emit_trackers_digest
  echo ""
  emit_evidence_index
  echo ""
  emit_kit_files
  echo ""
  emit_commands
  echo ""
  emit_notes
} > "${OUT_MD}"

# Also provide plain text version (identical content)
cp -f "${OUT_MD}" "${OUT_TXT}"

echo "OK: wrote ${OUT_MD}"
echo "OK: wrote ${OUT_TXT}"
