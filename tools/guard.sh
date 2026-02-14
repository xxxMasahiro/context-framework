#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage:
  ./tools/cf-guard.sh --check
  ./tools/cf-guard.sh -- <command...>
USAGE
}

mode=""
if [ "${1:-}" = "--check" ]; then
  mode="check"
  shift
elif [ "${1:-}" = "--" ]; then
  mode="run"
  shift
else
  usage
  exit 2
fi

if [ "$mode" = "run" ] && [ "$#" -eq 0 ]; then
  usage
  exit 2
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "Repo Lock: NG"
  echo "reason: python3 is required to read .repo-id/repo_fingerprint.json"
  exit 1
fi

root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
origin_url="$(git remote get-url origin 2>/dev/null || true)"
branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

reason=""
if [ -z "$root" ]; then
  reason="not a git repository"
fi

if [ -z "$reason" ]; then
  fingerprint="$root/.repo-id/repo_fingerprint.json"
  runbook="$root/_handoff_check/cf_update_runbook.md"

  if [ ! -f "$fingerprint" ]; then
    reason="missing .repo-id/repo_fingerprint.json"
  elif [ ! -f "$runbook" ]; then
    reason="missing _handoff_check/cf_update_runbook.md"
  elif [ -z "$origin_url" ]; then
    reason="missing origin remote"
  else
    if ! FINGERPRINT="$fingerprint" ORIGIN_URL="$origin_url" python3 - <<'PY'
import json
import os
import pathlib
import sys

path = pathlib.Path(os.environ["FINGERPRINT"])
origin = os.environ.get("ORIGIN_URL", "")

data = json.loads(path.read_text(encoding="utf-8"))
expected = data.get("expected_remotes", [])
if isinstance(expected, str):
  expected = [expected]

if origin and origin in expected:
  sys.exit(0)

sys.exit(1)
PY
    then
      reason="origin remote does not match expected_remotes"
    fi
  fi
fi

if [ -n "$reason" ]; then
  echo "Repo Lock: NG"
  echo "root: ${root:-<none>}"
  echo "origin: ${origin_url:-<none>}"
  echo "branch: ${branch:-<none>}"
  echo "reason: $reason"
  exit 1
fi

if [ "$mode" = "check" ]; then
  echo "Repo Lock: OK"
  exit 0
fi

"$@"
