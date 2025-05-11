#!/system/bin/sh

AGH_DIR="/data/adb/agh"
LOG="$AGH_DIR/debug.log"

{
  echo "==== AdGuardHome Debug Log ===="
  date
  echo

  echo "== System Info =="
  uname -a
  echo "Android Version: $(getprop ro.build.version.release)"
  echo "Device: $(getprop ro.product.model)"
  echo "Architecture: $(uname -m)"
  echo

  echo "== Magisk Info =="
  [ -f /sbin/magisk ] && /sbin/magisk -v 2>/dev/null
  echo "Magisk Path: $(magisk --path 2>/dev/null)"
  echo

  echo "== AGH Directory Listing =="
  ls -lR "$AGH_DIR"
  echo

  echo "== AGH Bin Log (last 30 lines) =="
  tail -n 30 "$AGH_DIR/bin.log" 2>/dev/null
  echo

  echo "== AGH Settings =="
  cat "$AGH_DIR/settings.conf" 2>/dev/null
  echo

  echo "== AGH PID File =="
  cat "$AGH_DIR/bin/agh.pid" 2>/dev/null
  echo

  echo "== Running Processes (AdGuardHome) =="
  ps | grep AdGuardHome
  echo

  echo "== iptables -t nat -L -n -v =="
  iptables -t nat -L -n -v
  echo

  echo "== ip6tables -t filter -L -n -v =="
  ip6tables -t filter -L -n -v
  echo

  echo "== Network Interfaces =="
  ip addr
  echo

  echo "== Disk Usage =="
  df -h
  echo

  echo "== SELinux Status =="
  getenforce
  echo

} > "$LOG" 2>&1

echo "Debug info collected in $LOG"