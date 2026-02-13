#!/usr/bin/env bash
set -euo pipefail
###############################################################################
# verify_ro_mount_nopasswd_template_v5.sh
#
# NOPASSWD mount/umount 検証テンプレート（v5 形式）
#
# 目的:
#   sudo NOPASSWD で mount/umount のみ許可されている環境において、
#   CORE ディレクトリを bind mount → ro remount → rw remount → umount する
#   一連の操作が正常に動作し、汎用 sudo は不許可であることを確認する。
#
# 使い方:
#   bash tools/verify_ro_mount_nopasswd_template_v5.sh > /path/to/output.txt 2>&1
#
# CORE のデフォルトは下記変数で変更可能:
#   CORE=/other/path bash tools/verify_ro_mount_nopasswd_template_v5.sh
###############################################################################

CORE="${CORE:-${CFCTX_MAIN_REPO:-}}"
if [[ -z "$CORE" ]]; then
  echo "ERROR: Set CORE or CFCTX_MAIN_REPO to the context-framework path." >&2
  exit 1
fi

###############################################################################
# PASS 基準（明文）
###############################################################################
cat <<'CRITERIA'
========================================
PASS 基準（v5 テンプレート）
========================================
1. 負のテスト: sudo -n -k /usr/bin/id -u が「失敗」すること
   → mount/umount 以外の sudo は NOPASSWD でないことを確認
2. bind mount 後: findmnt -M "$CORE" で TARGET=$CORE が表示されること
3. ro remount 後: findmnt -M "$CORE" の OPTIONS に "ro" が含まれること
4. rw remount 後: findmnt -M "$CORE" の OPTIONS に "rw" が含まれること
5. umount 後:
   - findmnt -M "$CORE" が「該当なし」に戻ること
   - mountpoint -q "$CORE" が NO に戻ること
6. 上記すべてを満たせば RESULT: PASS、1つでも不合格なら RESULT: FAIL
========================================
CRITERIA

###############################################################################
# ユーティリティ
###############################################################################
FAIL_FLAG=0

fail_mark() {
  echo "  *** FAIL: $1"
  FAIL_FLAG=1
}

# findmnt 4 パターン + mountpoint を出力するヘルパー
dump_mount_state() {
  local label="$1"
  echo ""
  echo "---- $label ----"

  echo "[findmnt -T \"\$CORE\" -o TARGET,SOURCE,OPTIONS]"
  findmnt -T "$CORE" -o TARGET,SOURCE,OPTIONS 2>/dev/null || echo "  (該当なし)"

  echo "[findmnt -T \"\$CORE\" -no TARGET,SOURCE,OPTIONS]"
  findmnt -T "$CORE" -no TARGET,SOURCE,OPTIONS 2>/dev/null || echo "  (該当なし)"

  echo "[findmnt -M \"\$CORE\" -o TARGET,SOURCE,OPTIONS]"
  findmnt -M "$CORE" -o TARGET,SOURCE,OPTIONS 2>/dev/null || echo "  (該当なし)"

  echo "[findmnt -M \"\$CORE\" -no TARGET,SOURCE,OPTIONS]"
  findmnt -M "$CORE" -no TARGET,SOURCE,OPTIONS 2>/dev/null || echo "  (該当なし)"

  if mountpoint -q "$CORE" 2>/dev/null; then
    echo "[mountpoint -q \"\$CORE\"] => YES"
  else
    echo "[mountpoint -q \"\$CORE\"] => NO"
  fi
}

###############################################################################
# 安全ガード: 事前に mountpoint が YES の場合は中断
###############################################################################
echo ""
echo "=== 事前チェック ==="
echo "CORE=$CORE"

if mountpoint -q "$CORE" 2>/dev/null; then
  echo "ERROR: CORE が既に mountpoint です。安全のため中断します。"
  echo "       手動で umount してから再実行してください。"
  echo "RESULT: FAIL"
  exit 1
fi

###############################################################################
# Cleanup trap
###############################################################################
cleanup() {
  echo ""
  echo "=== Cleanup ==="
  if mountpoint -q "$CORE" 2>/dev/null; then
    echo "mountpoint=YES のため umount を試みます..."
    sudo -n -k /usr/bin/umount "$CORE" 2>/dev/null && echo "  umount 完了" || echo "  umount 失敗（手動対応が必要）"
  else
    echo "mountpoint=NO: cleanup 不要"
  fi
}
trap cleanup EXIT

###############################################################################
# (0) 事前状態
###############################################################################
dump_mount_state "事前状態"

###############################################################################
# (1) 負のテスト: sudo -n -k /usr/bin/id -u が失敗すること
###############################################################################
echo ""
echo "=== 負のテスト: sudo -n -k /usr/bin/id -u ==="
if sudo -n -k /usr/bin/id -u 2>/dev/null; then
  fail_mark "sudo -n -k /usr/bin/id -u が成功してしまった（汎用 sudo が NOPASSWD）"
else
  echo "  OK: sudo -n -k /usr/bin/id -u は失敗した（期待通り）"
fi

###############################################################################
# (2) bind mount
###############################################################################
echo ""
echo "=== 正のテスト: bind mount ==="
echo "実行: sudo -n -k /usr/bin/mount --bind \"\$CORE\" \"\$CORE\""
sudo -n -k /usr/bin/mount --bind "$CORE" "$CORE"
echo "  bind mount 成功"

dump_mount_state "bind mount 後"

# bind 後の判定: findmnt -M で TARGET が見えること
if findmnt -M "$CORE" -no TARGET 2>/dev/null | grep -q .; then
  echo "  OK: findmnt -M で TARGET 確認"
else
  fail_mark "bind mount 後に findmnt -M で TARGET が見えない"
fi

###############################################################################
# (3) ro remount
###############################################################################
echo ""
echo "=== 正のテスト: ro remount ==="
echo "実行: sudo -n -k /usr/bin/mount -o remount,ro,bind \"\$CORE\" \"\$CORE\""
sudo -n -k /usr/bin/mount -o remount,ro,bind "$CORE" "$CORE"
echo "  ro remount 成功"

dump_mount_state "ro remount 後"

# ro 判定
ro_opts=$(findmnt -M "$CORE" -no OPTIONS 2>/dev/null || true)
if echo "$ro_opts" | grep -qw 'ro'; then
  ro_present=YES
else
  ro_present=NO
fi
echo "  ro_present=$ro_present"
if [ "$ro_present" != "YES" ]; then
  fail_mark "ro remount 後に OPTIONS に ro が含まれない"
fi

###############################################################################
# (4) rw remount
###############################################################################
echo ""
echo "=== 正のテスト: rw remount ==="
echo "実行: sudo -n -k /usr/bin/mount -o remount,rw,bind \"\$CORE\" \"\$CORE\""
sudo -n -k /usr/bin/mount -o remount,rw,bind "$CORE" "$CORE"
echo "  rw remount 成功"

dump_mount_state "rw remount 後"

# rw 判定
rw_opts=$(findmnt -M "$CORE" -no OPTIONS 2>/dev/null || true)
if echo "$rw_opts" | grep -qw 'rw'; then
  echo "  OK: rw remount 後の OPTIONS に rw 確認"
else
  fail_mark "rw remount 後に OPTIONS に rw が含まれない"
fi

###############################################################################
# (5) umount
###############################################################################
echo ""
echo "=== 正のテスト: umount ==="
echo "実行: sudo -n -k /usr/bin/umount \"\$CORE\""
sudo -n -k /usr/bin/umount "$CORE"
echo "  umount 成功"

# trap の cleanup は mountpoint=NO なら何もしないので安全
dump_mount_state "umount 後"

# umount 後の判定: findmnt -M が該当なし & mountpoint=NO
if findmnt -M "$CORE" -no TARGET 2>/dev/null | grep -q .; then
  fail_mark "umount 後なのに findmnt -M で TARGET がまだ見える"
else
  echo "  OK: findmnt -M 該当なし"
fi

if mountpoint -q "$CORE" 2>/dev/null; then
  fail_mark "umount 後なのに mountpoint=YES のまま"
else
  echo "  OK: mountpoint=NO"
fi

###############################################################################
# 最終判定
###############################################################################
echo ""
echo "========================================"
if [ "$FAIL_FLAG" -eq 0 ]; then
  echo "RESULT: PASS"
else
  echo "RESULT: FAIL"
fi
echo "========================================"
