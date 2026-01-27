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

# 2) schema mismatch should fail
cat > "$TMP_DIR/missing.json" <<'JSON'
{
  "actor": "codex",
  "risk": "low",
  "needs_gonogo": false,
  "context_profile": "ssot_only",
  "output_format": "checklist"
}
JSON
set +e
"$BIN" --classification-file "$TMP_DIR/missing.json" --dry-run --skip-adapter-check >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 2 ] || fail "schema mismatch did not fail"

# 3) high risk should request Go/NoGo
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

# 4) prohibited word should request Go/NoGo
cat > "$TMP_DIR/low.json" <<'JSON'
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
"$BIN" --classification-file "$TMP_DIR/low.json" --generated-text "rm -rf /" --dry-run --skip-adapter-check >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 3 ] || fail "prohibited word did not request Go/NoGo"

# 5) two-stage output prompt should include required headings
OUT_JSON="$("$BIN" --dry-run --skip-adapter-check 2>/dev/null)"
OUT_JSON="$OUT_JSON" python3 - <<'PY'
import json, sys
import os
data = json.loads(os.environ.get("OUT_JSON", ""))
stage2 = data.get("stage2_prompt", "")
required = ["根拠", "判定", "変更提案", "次にやること", "意味（復習用）", "変更点"]
missing = [k for k in required if k not in stage2]
if missing:
    raise SystemExit(f"missing headings: {missing}")
PY

# 6) adapter validation OK should pass
set +e
"$BIN" --dry-run >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 0 ] || fail "adapter validation OK did not pass"

# 7) adapter validation NG should fail
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

# 8) invalid generated output should fail validation
cat > "$TMP_DIR/bad.txt" <<'TXT'
根拠: なし
判定: OK
変更提案:
- 次にやること: echo hello
TXT
set +e
"$BIN" --classification-file "$TMP_DIR/low.json" --generated-file "$TMP_DIR/bad.txt" --dry-run --skip-adapter-check >/dev/null 2>&1
code=$?
set -e
[ "$code" -eq 5 ] || fail "invalid generated output did not fail"

echo "OK: smoke tests passed"
