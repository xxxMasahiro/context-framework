#!/usr/bin/env bash
set -euo pipefail

# Regenerate _meta/CHECKSUMS.sha256 inside a package root.
# Usage: ./regen_checksums.sh /path/to/package_root
#
# Notes:
# - Excludes .git and the checksum file itself
# - Sorts paths to keep deterministic output

ROOT="${1:-}"
if [[ -z "${ROOT}" ]]; then
  echo "Usage: $0 /path/to/package_root" >&2
  exit 2
fi

cd "${ROOT}"

tmpfile="$(mktemp)"
find . -type f \
  ! -path "./.git/*" \
  ! -path "./_meta/CHECKSUMS.sha256" \
  -print0 \
| sort -z \
| xargs -0 sha256sum \
| sed 's| \./|  |' \
> "${tmpfile}"

mv "${tmpfile}" _meta/CHECKSUMS.sha256
