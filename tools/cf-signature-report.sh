#!/usr/bin/env bash
set -euo pipefail

MIN=2
SCOPE="."

usage() {
  cat <<'USAGE'
Usage: tools/cf-signature-report.sh [--min N] [--scope PATH]

Read-only signature counter for "Signature:" lines in markdown.

Options:
  --min N     minimum count to show (default: 2)
  --scope P   search scope (default: .)
  -h, --help  show this help
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --min)
      shift
      MIN="${1:-}"
      ;;
    --scope)
      shift
      SCOPE="${1:-}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
  shift
done

if ! command -v python3 >/dev/null 2>&1; then
  echo "ERROR: python3 is required for tools/cf-signature-report.sh" >&2
  exit 1
fi

# Guard (Repo Lock)
./tools/cf-guard.sh --check

# Use guard for ripgrep execution.
if ! ./tools/cf-guard.sh -- rg --version >/dev/null 2>&1; then
  echo "ERROR: rg (ripgrep) is required for tools/cf-signature-report.sh" >&2
  exit 1
fi

./tools/cf-guard.sh -- rg -n --no-heading --glob '*.md' '^\\s*Signature:' "$SCOPE" | \
python3 <(cat <<'PY'
import sys
from collections import defaultdict

min_n = int(sys.argv[1]) if len(sys.argv) > 1 else 2
counts = defaultdict(int)
refs = defaultdict(list)

for line in sys.stdin:
  line = line.rstrip("\n")
  if not line:
    continue
  try:
    path, rest = line.split(":", 1)
    lineno, content = rest.split(":", 1)
  except ValueError:
    continue
  content = content.strip()
  if not content.lower().startswith("signature:"):
    continue
  sig = content.split(":", 1)[1].strip()
  if not sig:
    continue
  counts[sig] += 1
  if len(refs[sig]) < 8:
    refs[sig].append(f"{path}:{lineno}")

items = sorted(counts.items(), key=lambda x: (-x[1], x[0]))
for sig, cnt in items:
  if cnt < min_n:
    continue
  r = refs.get(sig, [])
  suffix = ""
  if cnt > len(r):
    suffix = f" +{cnt - len(r)}"
  print(f"{cnt} | {sig} | {', '.join(r)}{suffix}")
PY
) "$MIN"
