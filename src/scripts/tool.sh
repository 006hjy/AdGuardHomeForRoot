#!/system/bin/sh

source "/data/adb/agh/settings.conf"

case "$1" in
start)
  # check if AdGuardHome is already running
  if [ -f "$PID_FILE" ] && ps -p $(cat "$PID_FILE") >/dev/null 2>&1; then
    log "AdGuardHome is already running" "- AdGuardHome 已经在运行"
    exit 0
  fi

  # to fix https://github.com/AdguardTeam/AdGuardHome/issues/7002
  export SSL_CERT_DIR="/system/etc/security/cacerts/"
  busybox setuidgid "$adg_user:$adg_group" "$BIN_DIR/AdGuardHome" --logfile "$BIN_DIR/AdGuardHome.log" &
  adg_pid=$!

  # check if AdGuardHome started successfully
  if ps -p "$adg_pid" -o comm= | grep -q "^AdGuardHome$"; then
    log "AdGuardHome started" "- AdGuardHome 启动成功"
    echo "$adg_pid" >"$PID_FILE"
    if [ "$enable_iptables" = true ]; then
      $SCRIPT_DIR/iptables.sh enable
    fi
  else
    log "Failed to start AdGuardHome" "- AdGuardHome 启动失败"
    exit 1
  fi
  ;;
stop)
  if [ ! -f "$PID_FILE" ]; then
    log "pid file not found" "- 未找到pid文件"
    exit 1
  fi
  log "Stopping AdGuardHome" "- 停止 AdGuardHome"
  kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
  rm "$PID_FILE"
  $SCRIPT_DIR/iptables.sh disable
  ;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
  ;;
esac