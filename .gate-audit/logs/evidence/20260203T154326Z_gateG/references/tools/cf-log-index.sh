#!/usr/bin/env bash
set -euo pipefail

input="${1:-_handoff_check/cf_task_tracker_v5.md}"
output="${2:-LOGS/INDEX.md}"

if [ ! -f "$input" ]; then
  echo "error: input not found: $input" >&2
  exit 1
fi

mkdir -p "$(dirname "$output")"

generated_at="$(date -Iseconds)"
tmpfile="$(mktemp)"

cat >"$tmpfile" <<EOF
# LOGS/INDEX（Generated）
- Generated: ${generated_at}
- 手編集禁止（再生成してください）
- 再生成コマンド: \`./tools/cf-log-index.sh\`
- Source: ${input}

## Progress Log/Updates（UPD-*）
EOF

upd_lines="$(
  awk -v input="$input" '
    function trim(s){ sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s; }
    BEGIN{in_section=0}
    {
      if ($0 ~ /^##[[:space:]]+Progress Log\/Updates/) { in_section=1; next }
      if (in_section && $0 ~ /^##[[:space:]]+/) { in_section=0 }
      if (in_section && $0 ~ /UPD-[0-9]{8}-[0-9]{2}/) {
        n=split($0, parts, "|");
        id="";
        summary="";
        if (n >= 2) { id=trim(parts[2]) }
        if (id == "" && match($0, /UPD-[0-9]{8}-[0-9]{2}/)) { id=substr($0, RSTART, RLENGTH) }
        if (n >= 3) { summary=trim(parts[3]) }
        if (summary == "") {
          summary=$0;
          sub(/^[[:space:]]*-[[:space:]]*/, "", summary);
          if (match(summary, /UPD-[0-9]{8}-[0-9]{2}/)) {
            summary=substr(summary, RSTART + RLENGTH);
          }
          summary=trim(summary);
          sub(/^[|:：-]+[[:space:]]*/, "", summary);
        }
        if (summary == "") { summary="(no summary)" }
        printf("- %s | %s | L%s | Ref: rg -n \"%s\" %s\n", id, summary, NR, id, input);
      }
    }
  ' "$input"
)"

if [ -z "$upd_lines" ]; then
  echo "- (none)" >>"$tmpfile"
else
  echo "$upd_lines" >>"$tmpfile"
fi

cat >>"$tmpfile" <<'EOF'

## 実行ログ（LOG-*）
EOF

log_lines="$(
  awk -v input="$input" '
    function trim(s){ sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s; }
    {
      if ($0 ~ /^### [[:space:]]*LOG-[0-9]+/) {
        line=$0;
        id="";
        if (match(line, /LOG-[0-9]+/)) { id=substr(line, RSTART, RLENGTH) }
        summary=line;
        sub(/^### [[:space:]]*LOG-[0-9]+/, "", summary);
        summary=trim(summary);
        sub(/^[｜|:-]+[[:space:]]*/, "", summary);
        if (summary == "") { summary="実行ログ" }
        printf("- %s | %s | L%s | Ref: rg -n \"%s\" %s\n", id, summary, NR, id, input);
      }
    }
  ' "$input"
)"

if [ -z "$log_lines" ]; then
  echo "- (none)" >>"$tmpfile"
else
  echo "$log_lines" >>"$tmpfile"
fi

cat >>"$tmpfile" <<'EOF'

## Skillログ（SKILL-LOG-*）
EOF

skill_lines="$(
  awk -v input="$input" '
    function trim(s){ sub(/^[[:space:]]+/, "", s); sub(/[[:space:]]+$/, "", s); return s; }
    {
      if ($0 ~ /^### [[:space:]]*SKILL-LOG-[0-9]+/) {
        line=$0;
        id="";
        if (match(line, /SKILL-LOG-[0-9]+/)) { id=substr(line, RSTART, RLENGTH) }
        summary=line;
        sub(/^### [[:space:]]*SKILL-LOG-[0-9]+/, "", summary);
        summary=trim(summary);
        sub(/^[｜|:-]+[[:space:]]*/, "", summary);
        if (summary == "") { summary="Skill log" }
        printf("- %s | %s | L%s | Ref: rg -n \"%s\" %s\n", id, summary, NR, id, input);
      }
    }
  ' "$input"
)"

if [ -z "$skill_lines" ]; then
  echo "- (none)" >>"$tmpfile"
else
  echo "$skill_lines" >>"$tmpfile"
fi

mv "$tmpfile" "$output"
echo "Generated: $output"
