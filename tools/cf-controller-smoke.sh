#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BIN="$ROOT/bin/ctx-controller"

TMP_DIR="$(mktemp -d)"
cleanup() { rm -rf "$TMP_DIR"; }
trap cleanup EXIT

fail() { echo "FAIL: $1" >&2; exit 1; }

# 1) invalid JSON should fail
set +e
echo '{' | "$BIN" --classification-stdin --dry-run --skip-adapter-check >/dev/null 2>&1
code=$?
set -e
[ "$code" -ne 0 ] || fail "invalid JSON did not fail"

# 2) high risk should request Go/NoGo
cat > "$TMP_DIR/high.json" <<'JSON'
{
  "intent": "delete",
  "actor": "codex",
  "risk": "high",
  "needs_gonogo": true,
  "context_profile": "ssot_only",
  "output_format": "unified_diff",
  "notes": "test"
}
JSON
set +e
"$BIN" --classification-file "$TMP_DIR/high.json" --task "delete /etc" --dry-run --skip-adapter-check >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 3 ] || fail "high risk did not request Go/NoGo"

# 3) adapter validation NG should fail
mkdir -p "$TMP_DIR/adapters"
cat > "$TMP_DIR/adapters/CLAUDE.md" <<'TXT'
## SSOT参照順
- Charter -> Mode -> Artifacts -> Skills
TXT
cat > "$TMP_DIR/adapters/AGENTS.md" <<'TXT'
## SSOT参照順
- Charter -> Mode -> Artifacts -> Skills (DIFFERENT)
TXT
cat > "$TMP_DIR/adapters/GEMINI.md" <<'TXT'
## SSOT参照順
- Charter -> Mode -> Artifacts -> Skills
TXT

cat > "$TMP_DIR/ok.json" <<'JSON'
{
  "intent": "verify",
  "actor": "codex",
  "risk": "low",
  "needs_gonogo": false,
  "context_profile": "ssot_only",
  "output_format": "checklist",
  "notes": "test"
}
JSON
set +e
"$BIN" --classification-file "$TMP_DIR/ok.json" --dry-run --adapter-paths "${TMP_DIR}/adapters/CLAUDE.md,${TMP_DIR}/adapters/AGENTS.md,${TMP_DIR}/adapters/GEMINI.md" >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 4 ] || fail "adapter validation NG did not stop"

echo "OK: smoke tests passed"
