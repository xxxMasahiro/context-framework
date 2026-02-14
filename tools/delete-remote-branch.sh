#!/usr/bin/env bash
set -euo pipefail

GUARD="${GUARD:-./tools/guard.sh}"

usage() {
  cat <<'USAGE'
Usage:
  tools/delete-remote-branch.sh <branch> [--remote <remote>] --yes

Deletes a remote branch SAFELY.
- Refuses to delete: main, master, HEAD
- Requires --yes to actually delete
- Always runs git commands via ./tools/guard.sh -- ...

Options:
  --remote <remote>  Remote name (default: origin)
  --yes              Actually perform deletion (required)
  -h, --help          Show this help
USAGE
}

REMOTE="origin"
YES="0"
BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote) REMOTE="${2:-}"; shift 2;;
    --yes) YES="1"; shift;;
    -h|--help) usage; exit 0;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage
      exit 2
      ;;
    *)
      if [[ -z "${BRANCH}" ]]; then
        BRANCH="$1"; shift
      else
        echo "ERROR: too many args: $1" >&2
        usage
        exit 2
      fi
      ;;
  esac
done

if [[ -z "${BRANCH}" ]]; then
  echo "ERROR: branch is required" >&2
  usage
  exit 2
fi

case "${BRANCH}" in
  main|master|HEAD)
    echo "ERROR: refusing to delete protected branch: ${BRANCH}" >&2
    exit 2
    ;;
esac

run() { "$GUARD" -- "$@"; }

echo "== Repo Lock check =="
"$GUARD" --check

if [[ "${YES}" != "1" ]]; then
  echo "DRY-RUN: --yes が無いので削除しません。実行するには次を実行:"
  echo "  $0 ${BRANCH} --remote ${REMOTE} --yes"
  exit 0
fi

echo "== Remote existence check (${REMOTE}/${BRANCH}) =="
if ! run git ls-remote --heads "$REMOTE" "$BRANCH" | grep -q .; then
  echo "ERROR: remote branch not found: ${REMOTE}/${BRANCH}" >&2
  exit 1
fi

echo "== Deleting remote branch: ${REMOTE}/${BRANCH} =="
run git push "$REMOTE" --delete "$BRANCH"

echo "== Prune + list branches =="
run git fetch --prune "$REMOTE"
run git branch -a
echo "== Done =="
