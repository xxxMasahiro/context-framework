#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
HANDOFF="$ROOT/handoff/latest.md"
INDEX="$ROOT/LOGS/INDEX.md"

usage() {
  echo "Usage: $0 step STEP-G003" >&2
  exit 2
}

if [ "$#" -ne 2 ] || [ "$1" != "step" ] || [ "$2" != "STEP-G003" ]; then
  usage
fi

if [ -x "$ROOT/tools/guard.sh" ]; then
  "$ROOT/tools/guard.sh" --check >/dev/null 2>&1 || true
fi

has_rg() { command -v rg >/dev/null 2>&1; }

search_first() {
  file="$1"
  pattern="$2"
  if has_rg; then
    rg -n -- "$pattern" "$file" 2>/dev/null | head -n 1 || true
  else
    grep -nE -- "$pattern" "$file" 2>/dev/null | head -n 1 || true
  fi
}

status="PASS"
evidence=""
failures=""
need_index_fix=0
need_handoff_fix=0

check_pattern() {
  file="$1"
  pattern="$2"
  label="$3"
  if [ ! -f "$file" ]; then
    status="FAIL"
    failures="$failures
- missing file: $label"
    [ "$label" = "LOGS/INDEX.md" ] && need_index_fix=1 || need_handoff_fix=1
    return
  fi
  match=$(search_first "$file" "$pattern")
  if [ -n "$match" ]; then
    line_no=${match%%:*}
    snippet=${match#*:}
    evidence="$evidence
- $label:$line_no | $snippet"
  else
    status="FAIL"
    failures="$failures
- missing pattern: $label | $pattern"
    [ "$label" = "LOGS/INDEX.md" ] && need_index_fix=1 || need_handoff_fix=1
  fi
}

echo "[doctor] step=STEP-G003"
check_pattern "$HANDOFF" "# Handoff" "handoff/latest.md"
check_pattern "$INDEX" "LOG-009" "LOGS/INDEX.md"

if [ "$status" = "PASS" ]; then
  echo "- status: PASS"
  echo "- evidence:"
  printf '%s\\n' "$evidence" | sed '/^$/d' | sed 's/^/  /'
  echo "- next: (none)"
  exit 0
fi

echo "- status: FAIL"
echo "- failures:"
printf '%s\\n' "$failures" | sed '/^$/d' | sed 's/^/  /'
echo "- evidence:"
printf '%s\\n' "$evidence" | sed '/^$/d' | sed 's/^/  /'

next_action=""
if [ "$need_index_fix" -eq 1 ]; then
  next_action="./tools/guard.sh -- ./tools/log-index.sh"
elif [ "$need_handoff_fix" -eq 1 ]; then
  next_action="./tools/guard.sh -- ls handoff/latest.md"
fi

if [ -n "$next_action" ]; then
  echo "- next: $next_action"
else
  echo "- next: (none)"
fi
exit 1
