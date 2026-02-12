#!/usr/bin/env python3
import argparse
import json
import os
import re
import sys
from datetime import datetime
from glob import glob
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_MANIFEST = REPO_ROOT / "rules" / "ssot_manifest.yaml"
DEFAULT_ROUTES = REPO_ROOT / "rules" / "routes.yaml"
DEFAULT_POLICY = REPO_ROOT / "rules" / "policy.json"
DEFAULT_LOG_DIR = REPO_ROOT / "LOGS" / "controller"


def parse_scalar(value: str):
    v = value.strip()
    if v.lower() in ("true", "false"):
        return v.lower() == "true"
    if re.fullmatch(r"-?\d+", v):
        return int(v)
    return v.strip("\"'")


def parse_manifest(path: Path):
    data = {}
    current = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        if re.match(r"^[A-Za-z_]+:\s*$", line):
            key = line.split(":", 1)[0]
            data[key] = []
            current = key
            continue
        if line.startswith("-") and current:
            item = line[1:].strip()
            data[current].append(item.strip("\"'"))
    return data


def parse_routes(path: Path):
    version = None
    routes = []
    default = {}
    current = None
    section = None
    for raw in path.read_text(encoding="utf-8").splitlines():
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        indent = len(raw) - len(raw.lstrip(" "))
        text = raw.strip()

        if indent == 0 and text.startswith("version:"):
            version = parse_scalar(text.split(":", 1)[1])
            continue
        if indent == 0 and text == "routes:":
            continue
        if indent == 2 and text.startswith("- id:"):
            current = {"id": parse_scalar(text.split(":", 1)[1]), "match": {}, "action": {}}
            routes.append(current)
            section = None
            continue
        if indent == 4 and text == "match:":
            section = "match"
            continue
        if indent == 4 and text == "action:":
            section = "action"
            continue
        if indent == 0 and text == "default:":
            section = "default"
            continue
        if indent == 4 and section == "default" and ":" in text:
            key, val = text.split(":", 1)
            default[key.strip()] = parse_scalar(val)
            continue
        if indent == 6 and section in ("match", "action") and current and ":" in text:
            key, val = text.split(":", 1)
            current[section][key.strip()] = parse_scalar(val)
            continue
    return {"version": version, "routes": routes, "default": default}


def load_policy(path: Path):
    return json.loads(path.read_text(encoding="utf-8"))


def validate_classification(obj, schema):
    errors = []
    required = schema.get("required", [])
    props = schema.get("properties", {})
    additional = schema.get("additionalProperties", True)

    for k in required:
        if k not in obj:
            errors.append(f"missing:{k}")

    if not additional:
        for k in obj.keys():
            if k not in props:
                errors.append(f"unexpected:{k}")

    for k, spec in props.items():
        if k not in obj:
            continue
        v = obj[k]
        t = spec.get("type")
        if t == "string" and not isinstance(v, str):
            errors.append(f"type:{k}")
        if t == "boolean" and not isinstance(v, bool):
            errors.append(f"type:{k}")
        if "enum" in spec and v not in spec["enum"]:
            errors.append(f"enum:{k}")
        if k == "notes" and isinstance(v, str) and "maxLength" in spec:
            if len(v) > spec["maxLength"]:
                errors.append(f"maxLength:{k}")

    return errors


def choose_route(routes, intent):
    for r in routes:
        if r.get("match", {}).get("intent") == intent:
            return r
    return None


def apply_route(classification, route, default_action):
    if route:
        action = route.get("action", {})
        for k, v in action.items():
            classification[k] = v
        classification["route_id"] = route.get("id")
    elif default_action:
        for k, v in default_action.items():
            classification[k] = v
        classification["route_id"] = "default"
    else:
        classification["route_id"] = "none"
    return classification


def resolve_files(patterns):
    files = []
    for pat in patterns:
        matches = glob(str(REPO_ROOT / pat), recursive=True)
        for m in matches:
            p = Path(m)
            if p.is_file():
                files.append(p)
    return sorted(set(files))


def is_allowed(path: Path, allow_prefixes):
    rel = path.relative_to(REPO_ROOT).as_posix() + "/"
    for prefix in allow_prefixes:
        if rel.startswith(prefix):
            return True
    return False


def build_bundle(manifest, context_profile):
    allow = manifest.get("allow_read_prefix", [])
    bundle_files = []

    def add_section(key):
        for p in resolve_files(manifest.get(key, [])):
            if is_allowed(p, allow):
                bundle_files.append(p)

    ssot_key = "handoff_check_files" if "handoff_check_files" in manifest else "ssot"
    if context_profile == "ssot_only":
        add_section(ssot_key)
    elif context_profile == "ssot_charter":
        add_section(ssot_key)
        add_section("charter")
        add_section("architect")
    else:
        add_section(ssot_key)
        add_section("charter")
        add_section("architect")
        add_section("skills")

    bundle_text = []
    for p in bundle_files:
        rel = p.relative_to(REPO_ROOT).as_posix()
        bundle_text.append(f"===== BEGIN {rel} =====")
        bundle_text.append(p.read_text(encoding="utf-8"))
        bundle_text.append(f"===== END {rel} =====")

    return "\n".join(bundle_text).strip() + "\n", [p.relative_to(REPO_ROOT).as_posix() for p in bundle_files]


def detect_risk_flags(text, policy):
    hits = []
    for cat, tokens in policy.get("risk_flags", {}).items():
        for token in tokens:
            if re.search(re.escape(token), text, re.IGNORECASE):
                hits.append(f"{cat}:{token}")
    return hits


def detect_dangerous_ops(text, policy):
    hits = []
    for cat, patterns in policy.get("dangerous_ops", {}).items():
        for pat in patterns:
            if re.search(pat, text, re.IGNORECASE):
                hits.append(f"{cat}:{pat}")
    return hits


def detect_prohibited_words(text, policy):
    hits = []
    for pat in policy.get("prohibited_words", []):
        if re.search(pat, text, re.IGNORECASE):
            hits.append(pat)
    return hits


def detect_banned(text, policy):
    hits = []
    for token in policy.get("banned", {}).get("phrases", []):
        if re.search(re.escape(token), text, re.IGNORECASE):
            hits.append(token)
    return hits


def build_classification_prompt(schema):
    required = schema.get("required", [])
    props = schema.get("properties", {})
    lines = [
        "以下の依頼を分類し、厳密JSONのみで出力してください。",
        "出力はJSONのみ（説明文は禁止）。",
        "必須キー: " + ", ".join(required)
    ]
    for key, spec in props.items():
        t = spec.get("type", "string")
        enum = spec.get("enum")
        if enum:
            lines.append(f"- {key} ({t}): {' | '.join(enum)}")
        else:
            lines.append(f"- {key} ({t})")
    return "\n".join(lines)


def build_generation_prompt():
    return (
        "出力は日本語で、次の構成を**必ず**含める:\n"
        "1) 根拠\n"
        "2) 判定\n"
        "3) 変更提案\n"
        "   - 次にやること（1つ、コマンド1つ）\n"
        "   - 意味（復習用）\n"
        "   - 変更点（Add/Del/Mod）\n"
        "注意: 余計な前置きや冗長な実行ログは不要。\n"
    )


def validate_generated_output(text):
    errors = []
    required = ["根拠", "判定", "変更提案", "次にやること", "意味（復習用）", "変更点"]
    for key in required:
        if key not in text:
            errors.append(f"missing:{key}")
    count_next = len(re.findall(r"次にやること", text))
    if count_next != 1:
        errors.append("next_step_count")
    for token in ["Add", "Del", "Mod"]:
        if token not in text:
            errors.append(f"missing:{token}")
    return errors


def extract_section(text, header_regex):
    lines = text.splitlines()
    start = None
    for i, line in enumerate(lines):
        if re.search(header_regex, line):
            start = i
            break
    if start is None:
        return None
    end = len(lines)
    for j in range(start + 1, len(lines)):
        if lines[j].startswith("## "):
            end = j
            break
    return "\n".join(lines[start:end]).strip()


def validate_agent_adapters(manifest, policy, adapter_paths_override=None):
    adapters = adapter_paths_override
    if adapters is None:
        adapters = manifest.get("projection", [])
    if not adapters:
        return {"ok": False, "reason": "projection_not_defined"}

    sot_regex = policy.get("gate_c", {}).get("sot_declaration_regex", "")
    if sot_regex:
        sot_regex = f"({sot_regex})|SSOT|Source of Truth"
    else:
        sot_regex = "SSOT|Source of Truth"

    links_regex = policy.get("gate_c", {}).get("links_regex", "Charter|Mode|Artifacts|Skills")
    skill_regex = policy.get("gate_c", {}).get("skill_first_regex", "Skill優先")

    sections = {}
    link_checks = {}
    skill_checks = {}

    for rel in adapters:
        path = REPO_ROOT / rel
        if not path.exists():
            return {"ok": False, "reason": f"missing_adapter:{rel}"}
        text = path.read_text(encoding="utf-8")
        section = extract_section(text, r"^##\s*SSOT参照順|^##\s*Source of Truth|SoT")
        if section is None:
            return {"ok": False, "reason": f"missing_sot_section:{rel}"}
        sections[rel] = section
        link_checks[rel] = all(re.search(rf"\b{t}\b", text) for t in ["Charter", "Mode", "Artifacts", "Skills"])
        skill_checks[rel] = re.search(skill_regex, text) is not None

    section_values = list(sections.values())
    sot_same = all(s == section_values[0] for s in section_values)
    links_ok = all(link_checks.values())
    skill_ok = all(skill_checks.values())

    ok = sot_same and links_ok and skill_ok
    reason = None
    if not sot_same:
        reason = "sot_mismatch"
    elif not links_ok:
        reason = "links_inconsistent"
    elif not skill_ok:
        reason = "skill_first_missing"

    return {
        "ok": ok,
        "checks": {
            "sot_declaration_same": sot_same,
            "links_consistent": links_ok,
            "skill_first_present": skill_ok
        },
        "reason": reason,
        "adapters": adapters
    }


def main():
    ap = argparse.ArgumentParser(description="Controller skeleton (Phase 1)")
    ap.add_argument("--task", default="", help="Task description")
    ap.add_argument("--task-file", default="", help="Task file path")
    ap.add_argument("--classification-json", default="", help="Classification JSON string")
    ap.add_argument("--classification-file", default="", help="Classification JSON file")
    ap.add_argument("--classification-stdin", action="store_true", help="Read classification JSON from stdin")
    ap.add_argument("--generated-text", default="", help="Generated output text to validate")
    ap.add_argument("--generated-file", default="", help="Generated output file to validate")
    ap.add_argument("--profile", default="", help="Override context_profile")
    ap.add_argument("--print-bundle", action="store_true", help="Print bundle to stdout")
    ap.add_argument("--out-bundle", default="", help="Write bundle to file")
    ap.add_argument("--dry-run", action="store_true", help="No LLM call; output stub")
    ap.add_argument("--skip-adapter-check", action="store_true", help="Skip adapter validation (dry-run only)")
    ap.add_argument("--adapter-paths", default="", help="Override adapter paths (comma-separated)")
    ap.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    ap.add_argument("--routes", default=str(DEFAULT_ROUTES))
    ap.add_argument("--policy", default=str(DEFAULT_POLICY))
    args = ap.parse_args()

    task_text = args.task
    if args.task_file:
        task_text = Path(args.task_file).read_text(encoding="utf-8")

    classification_raw = None
    if args.classification_json:
        classification_raw = args.classification_json
    elif args.classification_file:
        classification_raw = Path(args.classification_file).read_text(encoding="utf-8")
    elif args.classification_stdin:
        classification_raw = sys.stdin.read()

    if classification_raw:
        try:
            classification = json.loads(classification_raw)
        except Exception as e:
            print(f"ERROR: invalid classification JSON: {e}", file=sys.stderr)
            sys.exit(2)
    else:
        classification = {
            "intent": "verify",
            "actor": "codex",
            "risk": "low",
            "needs_gonogo": False,
            "context_profile": "ssot_only",
            "output_format": "checklist",
            "notes": "default_classification"
        }

    if args.profile:
        classification["context_profile"] = args.profile

    policy = load_policy(Path(args.policy))
    schema = policy.get("classification_schema", {})
    errors = validate_classification(classification, schema)
    if errors:
        print(f"ERROR: classification schema invalid: {errors}", file=sys.stderr)
        sys.exit(2)

    routes = parse_routes(Path(args.routes))
    route = choose_route(routes.get("routes", []), classification.get("intent"))
    classification = apply_route(classification, route, routes.get("default", {}))

    generated_text = ""
    if args.generated_text:
        generated_text = args.generated_text
    elif args.generated_file:
        generated_text = Path(args.generated_file).read_text(encoding="utf-8")

    scan_text = "\n".join([task_text, generated_text, json.dumps(classification, ensure_ascii=False)])
    risk_hits = detect_risk_flags(scan_text, policy)
    danger_hits = detect_dangerous_ops(scan_text, policy)
    prohibited_hits = detect_prohibited_words(scan_text, policy)
    banned_hits = detect_banned(scan_text, policy)

    risk_score = classification.get("risk_score", 0)
    require_cfg = policy.get("require_gonogo_conditions", {})
    risk_score_gte = require_cfg.get("risk_score_gte", 8)
    hit_categories = require_cfg.get("hit_categories", [])

    all_hits = {
        "risk_flags": risk_hits,
        "dangerous_ops": danger_hits,
        "prohibited_words": prohibited_hits,
        "banned": banned_hits
    }
    hit_keys = [k for k, v in all_hits.items() if v]

    adapter_paths = None
    if args.adapter_paths:
        adapter_paths = [p.strip() for p in args.adapter_paths.split(",") if p.strip()]

    adapter_result = {"ok": True, "checks": {"sot_declaration_same": True, "links_consistent": True, "skill_first_present": True}}
    if not args.skip_adapter_check:
        adapter_result = validate_agent_adapters(parse_manifest(Path(args.manifest)), policy, adapter_paths)
        if not adapter_result.get("ok"):
            log_path = write_log(classification, task_text, policy, adapter_result, all_hits, None, [])
            print(json.dumps({"status": "STOP_AND_REQUEST_GONOGO", "reason": adapter_result.get("reason"), "log": str(log_path)}, ensure_ascii=False), file=sys.stderr)
            sys.exit(4)

    need_gonogo = False
    reasons = []
    if classification.get("risk") == "high":
        need_gonogo = True
        reasons.append("risk=high")
    if classification.get("needs_gonogo"):
        need_gonogo = True
        reasons.append("needs_gonogo=true")
    if isinstance(risk_score, int) and risk_score >= risk_score_gte:
        need_gonogo = True
        reasons.append(f"risk_score>={risk_score_gte}")
    if hit_keys:
        for key in hit_keys:
            if key in hit_categories:
                need_gonogo = True
                reasons.append(f"hit:{key}")
        if not hit_categories:
            need_gonogo = True
            reasons.append("hit:policy")

    if need_gonogo:
        log_path = write_log(classification, task_text, policy, adapter_result, all_hits, None, [])
        print(json.dumps({
            "status": "STOP_AND_REQUEST_GONOGO",
            "reason": "risk_gate",
            "reasons": reasons,
            "risk_score": risk_score,
            "hits": all_hits,
            "question": "危険操作の可能性があります。続行しますか？(Go/NoGo)",
            "log": str(log_path)
        }, ensure_ascii=False), file=sys.stderr)
        sys.exit(3)

    manifest = parse_manifest(Path(args.manifest))
    bundle, bundle_files = build_bundle(manifest, classification.get("context_profile", "ssot_only"))

    if args.out_bundle:
        Path(args.out_bundle).write_text(bundle, encoding="utf-8")

    stage1_prompt = build_classification_prompt(schema)
    stage2_prompt = build_generation_prompt()

    generated_validation = {"ok": True, "errors": []}
    if generated_text:
        gen_errors = validate_generated_output(generated_text)
        if gen_errors:
            generated_validation = {"ok": False, "errors": gen_errors}
            log_path = write_log(classification, task_text, policy, adapter_result, all_hits, None, ["generated_invalid"], generated_validation)
            print(json.dumps({
                "status": "INVALID_OUTPUT",
                "errors": gen_errors,
                "question": "出力形式が不正です。修正して再実行してください。",
                "log": str(log_path)
            }, ensure_ascii=False), file=sys.stderr)
            sys.exit(5)

    log_path = write_log(classification, task_text, policy, adapter_result, all_hits, bundle_files, ["dry_run" if args.dry_run else "no_llm_call"], generated_validation)

    result = {
        "status": "OK",
        "classification": classification,
        "bundle_files": bundle_files,
        "stage1_prompt": stage1_prompt,
        "stage2_prompt": stage2_prompt,
        "generation_stub": stage2_prompt,
        "generated_validation": generated_validation,
        "log": str(log_path)
    }

    if args.print_bundle:
        sys.stdout.write(bundle)
        print(json.dumps(result, ensure_ascii=False, indent=2), file=sys.stderr)
    else:
        print(json.dumps(result, ensure_ascii=False, indent=2))


def write_log(classification, task_text, policy, adapter_result, hits, bundle_files, tags, generated_validation=None):
    DEFAULT_LOG_DIR.mkdir(parents=True, exist_ok=True)
    log = {
        "timestamp": datetime.now().isoformat(timespec="seconds"),
        "task": task_text,
        "classification": classification,
        "adapter_check": adapter_result,
        "risk_hits": hits,
        "bundle_files": bundle_files or [],
        "tags": tags or [],
        "generated_validation": generated_validation or {"ok": True, "errors": []}
    }
    log_path = DEFAULT_LOG_DIR / f"ctx-controller-{datetime.now().strftime('%Y%m%d-%H%M%S')}.json"
    log_path.write_text(json.dumps(log, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return log_path


if __name__ == "__main__":
    main()
