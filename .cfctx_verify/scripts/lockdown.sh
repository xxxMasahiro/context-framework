#!/usr/bin/env bash
# lockdown.sh — 検証キット隔離（Phase 5）
# Usage: bash scripts/lockdown.sh
#
# SSOT 準拠: verify_spec.md:93-108
#   1. .cfctx_verify/ → .cfctx_quarantine/verify-<timestamp>/ に移動
#   2. chmod -R go-rwx を適用（owner のみアクセス可）
#   3. LOCKED.flag を作成（解除時の判定に利用）
#   4. README_LOCKED.md を作成（ロック中の説明）

set -euo pipefail

# ── Resolve KIT_ROOT ─────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
KIT_PARENT="$(cd "${KIT_ROOT}/.." && pwd)"
KIT_DIRNAME="$(basename "$KIT_ROOT")"

# ── Timestamp ────────────────────────────────────────────────
TS="$(date -u +"%Y%m%dT%H%M%SZ")"
TS_JST="$(TZ=Asia/Tokyo date '+%Y-%m-%d %H:%M:%S %Z')"

# ── Quarantine paths ─────────────────────────────────────────
QUARANTINE_BASE="${KIT_PARENT}/.cfctx_quarantine"
QUARANTINE_DIR="${QUARANTINE_BASE}/verify-${TS}"

# ── Pre-flight checks ────────────────────────────────────────
echo "=== lockdown.sh — 検証キット隔離 ==="
echo ""
echo "KIT_ROOT:       ${KIT_ROOT}"
echo "Quarantine to:  ${QUARANTINE_DIR}"
echo "Timestamp:      ${TS_JST}"
echo ""

# 1. Kit が存在することを確認
if [[ ! -d "$KIT_ROOT" ]]; then
  echo "FATAL: KIT_ROOT not found: ${KIT_ROOT}" >&2
  exit 1
fi

# 2. Kit が既にロック済みでないことを確認
if [[ -f "${KIT_ROOT}/LOCKED.flag" ]]; then
  echo "FATAL: Kit is already locked (LOCKED.flag exists)." >&2
  echo "Use unlock.sh to restore." >&2
  exit 1
fi

# 3. Quarantine 先が既に存在しないことを確認
if [[ -d "$QUARANTINE_DIR" ]]; then
  echo "FATAL: Quarantine directory already exists: ${QUARANTINE_DIR}" >&2
  exit 1
fi

# ── Confirmation ─────────────────────────────────────────────
echo "WARNING: This will move the entire verification kit to quarantine."
echo "  Source: ${KIT_ROOT}"
echo "  Dest:   ${QUARANTINE_DIR}"
echo ""

# 非対話環境でも動作するよう LOCKDOWN_CONFIRM 環境変数で確認スキップ可能
if [[ "${LOCKDOWN_CONFIRM:-}" != "yes" ]]; then
  if [[ -t 0 ]]; then
    read -r -p "Continue? (yes/no): " confirm
    if [[ "$confirm" != "yes" ]]; then
      echo "Aborted."
      exit 1
    fi
  else
    echo "FATAL: Non-interactive mode. Set LOCKDOWN_CONFIRM=yes to proceed." >&2
    exit 1
  fi
fi

# ── Execute lockdown ─────────────────────────────────────────
echo ""
echo "--- Step 1/4: Creating quarantine directory ---"
mkdir -p "$QUARANTINE_BASE"

echo "--- Step 2/4: Moving kit to quarantine ---"
mv "$KIT_ROOT" "$QUARANTINE_DIR"

echo "--- Step 3/4: Applying chmod -R go-rwx ---"
chmod -R go-rwx "$QUARANTINE_DIR"

echo "--- Step 4/4: Creating LOCKED.flag and README_LOCKED.md ---"

# LOCKED.flag — 解除判定用
cat > "${QUARANTINE_DIR}/LOCKED.flag" <<EOF
LOCKED
timestamp_utc: ${TS}
timestamp_jst: ${TS_JST}
source_path: ${KIT_ROOT}
quarantine_path: ${QUARANTINE_DIR}
EOF
chmod go-rwx "${QUARANTINE_DIR}/LOCKED.flag"

# README_LOCKED.md — ロック中の説明
cat > "${QUARANTINE_DIR}/README_LOCKED.md" <<EOF
# Verification Kit — LOCKED

This verification kit has been moved to quarantine by \`lockdown.sh\`.

## Status
- **State**: LOCKED (quarantined)
- **Locked at**: ${TS_JST}
- **Original path**: ${KIT_ROOT}
- **Quarantine path**: ${QUARANTINE_DIR}

## To unlock
Run the following command:

\`\`\`bash
bash ${QUARANTINE_DIR}/scripts/unlock.sh
\`\`\`

Unlock requires:
1. \`LOCKED.flag\` to exist in the kit root
2. Passphrase: \`UNLOCK-VERIFY-KIT\`
EOF
chmod go-rwx "${QUARANTINE_DIR}/README_LOCKED.md"

echo ""
echo "=== Lockdown Complete ==="
echo ""
echo "Kit has been moved to quarantine:"
echo "  ${QUARANTINE_DIR}"
echo ""
echo "To unlock, run:"
echo "  bash ${QUARANTINE_DIR}/scripts/unlock.sh"
echo ""
echo "Passphrase required: UNLOCK-VERIFY-KIT"
