#!/usr/bin/env bash
set -euo pipefail

GUARD="${GUARD:-./tools/guard.sh}"

usage() {
  cat <<'USAGE'
Usage:
  tools/cleanup-local-merged.sh [--base <branch>] [--remote <remote>] [--dry-run]

Safely clean up local branches that are already merged into the base branch.
- Uses `git branch -d` (safe): it will NOT delete unmerged branches.
- Always runs git commands via ./tools/guard.sh -- ...

Options:
  --base <branch>   Base branch to compare against (default: main)
  --remote <remote> Remote name (default: origin)
  --dry-run         Show candidates only (do not delete)
  -h, --help        Show this help
USAGE
}

BASE="main"
REMOTE="origin"
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --base) BASE="${2:-}"; shift 2;;
    --remote) REMOTE="${2:-}"; shift 2;;
    --dry-run) DRY_RUN="1"; shift;;
    -h|--help) usage; exit 0;;
    *) echo "ERROR: unknown arg: $1" >&2; usage; exit 2;;
  esac
done

run() { "$GUARD" -- "$@"; }

echo "== Repo Lock check =="
"$GUARD" --check

echo "== Ensure clean working tree =="
if [[ -n "$(run git status --porcelain)" ]]; then
  echo "ERROR: working tree is not clean. Commit/stashしてから再実行してください。" >&2
  run git status -sb
  exit 1
fi

echo "== Sync base branch (${BASE}) =="
run git fetch --prune "$REMOTE"
run git switch "$BASE"
run git pull --ff-only "$REMOTE" "$BASE"

echo "== Candidates (local branches merged into ${BASE}) =="
merged="$(run git branch --merged "$BASE" --format='%(refname:short)' | grep -vE "^(${BASE})$" || true)"
if [[ -z "${merged}" ]]; then
  echo "(none)"
else
  echo "${merged}"
fi

if [[ "${DRY_RUN}" == "1" ]]; then
  echo "== Dry-run: no branches deleted =="
  exit 0
fi

echo "== Delete merged local branches (safe: -d only) =="
if [[ -n "${merged}" ]]; then
  while IFS= read -r b; do
    [[ -z "$b" ]] && continue
    echo "-- deleting: $b"
    run git branch -d "$b" || echo "SKIP: could not delete $b (not fully merged or protected)" >&2
  done <<< "${merged}"
fi

echo "== Final prune + status =="
run git fetch --prune "$REMOTE"
run git status -sb
echo "== Done =="
