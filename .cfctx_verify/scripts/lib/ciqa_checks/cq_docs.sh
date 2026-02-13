#!/usr/bin/env bash
# cq_docs.sh — CQ-DOC: Document Consistency check
# Contract: run_check() → stdout details, exit 0=PASS / 1=FAIL
# Validates: req ↔ spec section correspondence for configured doc pairs
#
# @check_key: docs
# @check_id: CQ-DOC
# @check_display: Document Consistency
# @check_order: 40
#
# Checks per doc pair:
#   1. Both files exist
#   2. REQ-* identifiers from requirement SECTION HEADINGS are referenced
#      in spec (supports range notation like REQ-R01〜R07)
#      NOTE: Only headings (### REQ-*) are extracted, not body cross-refs
#   3. If no REQ-* in headings, verify spec references the requirement group
#   4. Both files have reasonable section structure (≥2 ## headings)

run_check() {
  local verdict="PASS"
  local fail_count=0
  local check_count=0
  local details=""

  # Get doc pairs from config (CIQA_DOC_PAIRS loaded by ciqa_load_config)
  local -a pairs=()
  if [[ ${#CIQA_DOC_PAIRS[@]} -gt 0 ]]; then
    for p in "${CIQA_DOC_PAIRS[@]}"; do
      [[ -n "$p" ]] && pairs+=("$p")
    done
  fi

  if [[ ${#pairs[@]} -eq 0 ]]; then
    details+="SKIP: No doc_pairs configured in ciqa.conf"$'\n'
    echo "$details"
    return 0
  fi

  for pair in "${pairs[@]}"; do
    local req_rel="${pair%%:*}"
    local spec_rel="${pair#*:}"
    local req_path="${KIT_ROOT}/${req_rel}"
    local spec_path="${KIT_ROOT}/${spec_rel}"
    local pair_label
    pair_label="$(basename "$req_rel") ↔ $(basename "$spec_rel")"
    local pair_fail=0
    local pair_check=0

    # ── Check 1: File existence ──────────────────────────────
    if [[ ! -f "$req_path" ]]; then
      details+="  SECTION_MISSING: ${pair_label} — requirements not found: ${req_rel}"$'\n'
      ((fail_count++)) || true
      ((check_count++)) || true
      continue
    fi
    if [[ ! -f "$spec_path" ]]; then
      details+="  SECTION_MISSING: ${pair_label} — spec not found: ${spec_rel}"$'\n'
      ((fail_count++)) || true
      ((check_count++)) || true
      continue
    fi

    local spec_content
    spec_content="$(cat "$spec_path")"

    # ── Check 2: REQ-* ID coverage ──────────────────────────
    # Extract unique REQ-* IDs from section headings only (### REQ-*)
    # This avoids false positives from cross-references in body text
    local -a req_ids=()
    while IFS= read -r id; do
      [[ -n "$id" ]] && req_ids+=("$id")
    done < <(grep -P '^#{1,6}\s+.*REQ-[A-Z]+[0-9]+' "$req_path" 2>/dev/null \
             | grep -oP 'REQ-[A-Z]+[0-9]+' | sort -u || true)

    if [[ ${#req_ids[@]} -gt 0 ]]; then
      # Build set of covered IDs from spec (direct + range-expanded)
      local -A covered=()

      # Direct mentions
      while IFS= read -r id; do
        [[ -n "$id" ]] && covered["$id"]=1
      done < <(echo "$spec_content" | grep -oP 'REQ-[A-Z]+[0-9]+' 2>/dev/null | sort -u || true)

      # Range expansion: e.g., REQ-R01〜R07, REQ-CQ01〜CQ08
      while IFS= read -r range; do
        [[ -z "$range" ]] && continue
        local prefix="" snum="" enum=""
        prefix="$(echo "$range" | grep -oP 'REQ-\K[A-Z]+' | head -1 || true)"
        snum="$(echo "$range" | grep -oP 'REQ-[A-Z]+\K[0-9]+' | head -1 || true)"
        enum="$(echo "$range" | grep -oP '[〜~][A-Z]*\K[0-9]+' | head -1 || true)"

        if [[ -n "$prefix" && -n "$snum" && -n "$enum" ]]; then
          local s=$((10#$snum)) e=$((10#$enum)) w=${#snum}
          local n
          for ((n=s; n<=e; n++)); do
            covered["REQ-${prefix}$(printf "%0${w}d" "$n")"]=1
          done
        fi
      done < <(echo "$spec_content" | grep -oP 'REQ-[A-Z]+[0-9]+[〜~][A-Z]*[0-9]+' 2>/dev/null || true)

      # Verify each requirement ID is covered in spec
      for rid in "${req_ids[@]}"; do
        ((pair_check++)) || true
        ((check_count++)) || true
        if [[ -z "${covered[$rid]+_}" ]]; then
          details+="  SECTION_MISSING: ${pair_label} — ${rid} not referenced in spec"$'\n'
          ((pair_fail++)) || true
          ((fail_count++)) || true
        fi
      done
    else
      # No explicit REQ-* IDs in requirements — structural fallback
      ((pair_check++)) || true
      ((check_count++)) || true

      # Check if spec references any REQ-* identifiers (acknowledges requirements)
      local spec_req_count
      spec_req_count="$(echo "$spec_content" | grep -cP 'REQ-[A-Z]+[0-9]+' 2>/dev/null || echo 0)"
      if [[ "$spec_req_count" -eq 0 ]]; then
        # Neither file uses REQ-* notation — check title keyword overlap
        local req_title
        req_title="$(head -1 "$req_path" | sed 's/^#\+[[:space:]]*//')"
        local title_kw
        title_kw="$(echo "$req_title" | grep -oP '[一-龥ぁ-んァ-ヶ]{2,}' 2>/dev/null | head -1 || true)"
        if [[ -n "$title_kw" ]] && echo "$spec_content" | grep -qF "$title_kw" 2>/dev/null; then
          : # Spec references requirements by title keyword — OK
        else
          details+="  SECTION_MISSING: ${pair_label} — spec does not reference requirements"$'\n'
          ((pair_fail++)) || true
          ((fail_count++)) || true
        fi
      fi
    fi

    # ── Check 3: Structural sanity ───────────────────────────
    ((pair_check++)) || true
    ((check_count++)) || true
    local req_sec_count spec_sec_count
    req_sec_count="$(grep -cP '^## ' "$req_path" 2>/dev/null || echo 0)"
    spec_sec_count="$(grep -cP '^## ' "$spec_path" 2>/dev/null || echo 0)"
    if [[ "$req_sec_count" -lt 2 || "$spec_sec_count" -lt 2 ]]; then
      details+="  SECTION_MISSING: ${pair_label} — insufficient structure (req:${req_sec_count} sections, spec:${spec_sec_count} sections)"$'\n'
      ((pair_fail++)) || true
      ((fail_count++)) || true
    fi

    # ── Per-pair summary ─────────────────────────────────────
    local pair_verdict="PASS"
    if [[ "$pair_fail" -gt 0 ]]; then
      pair_verdict="FAIL"
    fi
    details+="${pair_label}: ${pair_check} checks, ${pair_fail} issues → ${pair_verdict}"$'\n'
  done

  details+=$'\n'
  details+="Total: ${check_count} checks performed, ${fail_count} issues"$'\n'

  if [[ "$fail_count" -gt 0 ]]; then
    verdict="FAIL"
  fi

  echo "$details"
  if [[ "$verdict" == "FAIL" ]]; then
    return 1
  fi
  return 0
}
