#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GUARD="$ROOT/tools/cf-guard.sh"
LOG_DIR="$ROOT/LOGS/ci"
TS="$(date +%Y%m%dT%H%M%S)"
LOG_FILE="$LOG_DIR/ci-validate-${TS}.log"

mkdir -p "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "== cf-ci-validate =="
echo "root=$ROOT"
echo "log=$LOG_FILE"

"$GUARD" --check

export ROOT
python3 - <<'PY'
import importlib.util
import os
import sys
from pathlib import Path

root = Path(os.environ["ROOT"])
controller = root / "controller" / "main.py"
manifest_path = root / "rules" / "ssot_manifest.yaml"
routes_path = root / "rules" / "routes.yaml"
policy_path = root / "rules" / "policy.json"

spec = importlib.util.spec_from_file_location("controller_main", controller)
mod = importlib.util.module_from_spec(spec)
assert spec.loader is not None
spec.loader.exec_module(mod)

manifest = mod.parse_manifest(manifest_path)
if not manifest.get("ssot"):
    sys.exit("ERROR: manifest missing ssot")
missing = [p for p in manifest["ssot"] if not (root / p).exists()]
if missing:
    sys.exit(f"ERROR: ssot files missing: {missing}")

routes = mod.parse_routes(routes_path)
if routes.get("version") != 1:
    sys.exit("ERROR: routes version missing")
if not routes.get("routes"):
    sys.exit("ERROR: routes empty")
if not routes.get("default"):
    raw = routes_path.read_text(encoding="utf-8")
    if "default:" not in raw:
        sys.exit("ERROR: routes default missing")
for r in routes["routes"]:
    if not r.get("id"):
        sys.exit("ERROR: route missing id")
    if "intent" not in r.get("match", {}):
        sys.exit("ERROR: route missing match.intent")
    if not r.get("action"):
        sys.exit("ERROR: route missing action")

policy = mod.load_policy(policy_path)
schema = policy.get("classification_schema", {})
if not schema:
    sys.exit("ERROR: classification_schema missing")
required = schema.get("required", [])
props = schema.get("properties", {})

def pick_value(spec):
    if "enum" in spec and spec["enum"]:
        return spec["enum"][0]
    t = spec.get("type")
    if t == "boolean":
        return False
    if t == "integer":
        return 0
    return ""

sample = {k: pick_value(props.get(k, {})) for k in required}
errors = mod.validate_classification(sample, schema)
if errors:
    sys.exit(f"ERROR: classification_schema validation failed: {errors}")

print("OK: rules/schema validated")
PY

echo "== smoke =="
"$ROOT/tools/cf-controller-smoke.sh"

echo "OK: ci validate"
