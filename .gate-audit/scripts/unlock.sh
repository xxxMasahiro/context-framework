#!/usr/bin/env bash
# unlock.sh — 検証キット隔離解除（Phase 5）
# Usage: bash scripts/unlock.sh
#
# SSOT 準拠: verify_spec.md:103-108
#   二段階解除:
#     1. LOCKED.flag の存在確認（無ければ中断）
#     2. 固定フレーズ入力要求: "UNLOCK-VERIFY-KIT"（不一致で中断）
#   解除処理:
#     - ディレクトリを元のパスに戻す
#     - 権限を戻す（u+rwX）
#     - LOCKED.flag と README_LOCKED.md を削除

set -euo pipefail

EXPECTED_PASSPHRASE="UNLOCK-VERIFY-KIT"

# ── Resolve paths ────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUARANTINE_KIT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "=== unlock.sh — 検証キット隔離解除 ==="
echo ""
echo "Current kit location: ${QUARANTINE_KIT}"
echo ""

# ── Stage 1: LOCKED.flag 存在確認 ────────────────────────────
LOCKED_FLAG="${QUARANTINE_KIT}/LOCKED.flag"

if [[ ! -f "$LOCKED_FLAG" ]]; then
  echo "FATAL: LOCKED.flag not found at ${LOCKED_FLAG}" >&2
  echo "This kit does not appear to be in quarantine." >&2
  exit 1
fi

echo "Stage 1: LOCKED.flag found — OK"
echo ""

# LOCKED.flag から元のパスを読み取る
ORIGINAL_PATH=""
while IFS=': ' read -r key value; do
  if [[ "$key" == "source_path" ]]; then
    ORIGINAL_PATH="$value"
  fi
done < "$LOCKED_FLAG"

if [[ -z "$ORIGINAL_PATH" ]]; then
  echo "FATAL: Cannot determine original path from LOCKED.flag." >&2
  echo "source_path entry not found." >&2
  exit 1
fi

echo "Original path: ${ORIGINAL_PATH}"
echo ""

# 元のパスに既にディレクトリが存在しないことを確認
if [[ -d "$ORIGINAL_PATH" ]]; then
  echo "FATAL: Original path already exists: ${ORIGINAL_PATH}" >&2
  echo "Cannot restore — target directory is occupied." >&2
  exit 1
fi

# ── Stage 2: パスフレーズ確認 ────────────────────────────────
# 非対話環境では UNLOCK_PASSPHRASE 環境変数で指定可能
if [[ -n "${UNLOCK_PASSPHRASE:-}" ]]; then
  passphrase="$UNLOCK_PASSPHRASE"
else
  if [[ -t 0 ]]; then
    read -r -p "Enter passphrase to unlock: " passphrase
  else
    echo "FATAL: Non-interactive mode. Set UNLOCK_PASSPHRASE env var." >&2
    exit 1
  fi
fi

if [[ "$passphrase" != "$EXPECTED_PASSPHRASE" ]]; then
  echo "FATAL: Passphrase mismatch. Unlock aborted." >&2
  exit 1
fi

echo "Stage 2: Passphrase verified — OK"
echo ""

# ── Execute unlock ───────────────────────────────────────────
echo "--- Step 1/3: Restoring permissions ---"
chmod -R u+rwX "$QUARANTINE_KIT"

echo "--- Step 2/3: Removing LOCKED.flag and README_LOCKED.md ---"
rm -f "${QUARANTINE_KIT}/LOCKED.flag"
rm -f "${QUARANTINE_KIT}/README_LOCKED.md"

echo "--- Step 3/3: Moving kit back to original path ---"
# 親ディレクトリが存在することを確認
ORIGINAL_PARENT="$(dirname "$ORIGINAL_PATH")"
if [[ ! -d "$ORIGINAL_PARENT" ]]; then
  mkdir -p "$ORIGINAL_PARENT"
fi

mv "$QUARANTINE_KIT" "$ORIGINAL_PATH"

# quarantine ベースが空なら削除
QUARANTINE_BASE="$(dirname "$QUARANTINE_KIT")"
if [[ -d "$QUARANTINE_BASE" ]] && [[ -z "$(ls -A "$QUARANTINE_BASE" 2>/dev/null)" ]]; then
  rmdir "$QUARANTINE_BASE" 2>/dev/null || true
fi

echo ""
echo "=== Unlock Complete ==="
echo ""
echo "Kit has been restored to:"
echo "  ${ORIGINAL_PATH}"
echo ""
echo "You can now use the kit normally:"
echo "  cd ${ORIGINAL_PATH} && ./kit status"
