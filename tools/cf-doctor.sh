#!/usr/bin/env sh
set -eu

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC_DEFAULT="$ROOT/WORKFLOW/SPEC/gates/gate-g.yaml"

usage() {
  echo "Usage: $0 step STEP-G003" >&2
  echo "       $0 gate G --phase 1" >&2
  exit 2
}

if [ $# -lt 2 ]; then
  usage
fi

MODE="$1"
TARGET="$2"
PHASE=""

if [ "$MODE" = "gate" ]; then
  shift 2
  while [ $# -gt 0 ]; do
    case "$1" in
      --phase)
        PHASE="$2"
        shift 2
        ;;
      *)
        shift 1
        ;;
    esac
  done
fi

SPEC_PATH="$SPEC_DEFAULT"
if [ ! -f "$SPEC_PATH" ]; then
  echo "[cf-doctor] FAIL: spec not found: $SPEC_PATH" >&2
  exit 1
fi

if [ -x "$ROOT/tools/cf-guard.sh" ]; then
  "$ROOT/tools/cf-guard.sh" --check >/dev/null 2>&1 || true
fi

has_rg() {
  command -v rg >/dev/null 2>&1
}

search_first() {
  file="$1"
  pattern="$2"
  if has_rg; then
    rg -n -- "$pattern" "$file" 2>/dev/null | head -n 1 || true
  else
    grep -nE "$pattern" "$file" 2>/dev/null | head -n 1 || true
  fi
}

add_check() {
  checks="$checks
$1|$2|$3"
}

build_checks() {
  step_id="$1"
  checks=""
  in_step=0
  in_ssot=0
  in_must=0
  in_inv=0
  cur_path=""
  cur_type=""
  cur_path2=""
  cur_pattern=""

  while IFS= read -r line; do
    case "$line" in
      ""|"#"*)
        continue
        ;;
    esac

    if printf "%s" "$line" | grep -q "^[[:space:]]*- id: "; then
      if printf "%s" "$line" | grep -q "$step_id"; then
        in_step=1
      else
        in_step=0
      fi
      in_ssot=0
      in_must=0
      in_inv=0
    fi

    if [ "$in_step" -eq 0 ]; then
      continue
    fi

    if printf "%s" "$line" | grep -q "^    ssot:"; then
      in_ssot=1
      in_inv=0
      in_must=0
      continue
    fi

    if printf "%s" "$line" | grep -q "^    invariants:"; then
      in_inv=1
      in_ssot=0
      in_must=0
      continue
    fi

    if [ "$in_ssot" -eq 1 ]; then
      if printf "%s" "$line" | grep -q "^      - path:"; then
        cur_path=$(printf "%s" "$line" | sed -E 's/^[[:space:]]*- path: "?([^"'"'"']+)"?$/\1/')
      fi
      if printf "%s" "$line" | grep -q "^        must_contain:"; then
        in_must=1
        continue
      fi
      if [ "$in_must" -eq 1 ] && printf "%s" "$line" | grep -q "^          - "; then
        pat=$(printf "%s" "$line" | sed -E 's/^[[:space:]]*- "?([^"'"'"']+)"?$/\1/')
        add_check "file_contains" "$cur_path" "$pat"
      fi
    fi

    if [ "$in_inv" -eq 1 ]; then
      if printf "%s" "$line" | grep -q "^      - type:"; then
        cur_type=$(printf "%s" "$line" | sed -E 's/^[[:space:]]*- type: "?([^"'"'"']+)"?$/\1/')
        cur_path2=""
        cur_pattern=""
        continue
      fi
      if printf "%s" "$line" | grep -q "^        path:"; then
        cur_path2=$(printf "%s" "$line" | sed -E 's/^[[:space:]]*path: "?([^"'"'"']+)"?$/\1/')
      fi
      if printf "%s" "$line" | grep -q "^        pattern:"; then
        cur_pattern=$(printf "%s" "$line" | sed -E 's/^[[:space:]]*pattern: "?([^"'"'"']+)"?$/\1/')
        if [ "$cur_type" = "file_contains" ]; then
          add_check "$cur_type" "$cur_path2" "$cur_pattern"
        fi
      fi
    fi
  done < "$SPEC_PATH"

  printf "%s" "$checks" | sed '/^$/d'
}

check_step() {
  step_id="$1"
  checks=$(build_checks "$step_id")
  if [ -z "$checks" ]; then
    echo "[cf-doctor] FAIL: no checks found for $step_id" >&2
    exit 1
  fi

  status="PASS"
  evidence=""
  failures=""
  need_index_fix=0
  need_runbook_fix=0

  echo "[cf-doctor] step=$step_id"

  while IFS='|' read -r ctype cpath cvalue; do
    path="$ROOT/$cpath"
    if [ ! -f "$path" ]; then
      status="FAIL"
      failures="$failures
- missing file: $cpath"
      if [ "$cpath" = "LOGS/INDEX.md" ]; then
        need_index_fix=1
      else
        need_runbook_fix=1
      fi
      continue
    fi

    pattern="$cvalue"

    match=$(search_first "$path" "$pattern")
    if [ -n "$match" ]; then
      line_no=${match%%:*}
      snippet=${match#*:}
      evidence="$evidence
- $cpath:$line_no | $snippet"
    else
      status="FAIL"
      failures="$failures
- missing pattern: $cpath | $pattern"
      if [ "$cpath" = "LOGS/INDEX.md" ]; then
        need_index_fix=1
      else
        need_runbook_fix=1
      fi
    fi
  done <<__CHECKS__
$checks
__CHECKS__

  if [ "$status" = "PASS" ]; then
    echo "- status: PASS"
    echo "- evidence:"
    printf "%s" "$evidence" | sed '/^$/d' | sed 's/^/  /'
    echo "- next: (none)"
    exit 0
  fi

  echo "- status: FAIL"
  echo "- failures:"
  printf "%s" "$failures" | sed '/^$/d' | sed 's/^/  /'
  echo "- evidence:"
  printf "%s" "$evidence" | sed '/^$/d' | sed 's/^/  /'

  next_action=""
  if [ "$need_index_fix" -eq 1 ]; then
    next_action="./tools/cf-guard.sh -- ./tools/cf-log-index.sh"
  elif [ "$need_runbook_fix" -eq 1 ]; then
    next_action="./tools/cf-guard.sh -- rg -n \"STEP-G003|LOG-009\" _handoff_check/cf_update_runbook.md || true"
  fi

  if [ -n "$next_action" ]; then
    echo "- next: $next_action"
  else
    echo "- next: (none)"
  fi
  exit 1
}

case "$MODE" in
  step)
    if [ "$TARGET" != "STEP-G003" ]; then
      echo "[cf-doctor] FAIL: unsupported step: $TARGET" >&2
      exit 2
    fi
    check_step "$TARGET"
    ;;
  gate)
    if [ "$TARGET" != "G" ]; then
      echo "[cf-doctor] FAIL: unsupported gate: $TARGET" >&2
      exit 2
    fi
    if [ -n "$PHASE" ] && [ "$PHASE" != "1" ]; then
      echo "[cf-doctor] FAIL: unsupported phase: $PHASE" >&2
      exit 2
    fi
    check_step "STEP-G003"
    ;;
  *)
    usage
    ;;
esac
