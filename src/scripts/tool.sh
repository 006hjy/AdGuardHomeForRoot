. /data/adb/agh/settings.conf

start_adguardhome() {
  # check if AdGuardHome is already running
  if [ -f "$PID_FILE" ] && ps | grep -w "$adg_pid" | grep -q "AdGuardHome"; then
    log "AdGuardHome is already running" "- AdGuardHome 已经在运行"
    exit 0
  fi

  # to fix https://github.com/AdguardTeam/AdGuardHome/issues/7002
  export SSL_CERT_DIR="/system/etc/security/cacerts/"
  busybox setuidgid "$adg_user:$adg_group" "$BIN_DIR/AdGuardHome" >>"$AGH_DIR/bin.log" 2>&1 &
  adg_pid=$!

  # check if AdGuardHome started successfully
  if ps | grep -w "$adg_pid" | grep -q "AdGuardHome"; then
    log "🥰 started, PID: $adg_pid" "- 🥰 启动成功，PID: $adg_pid"
    update_description "🥰 Started, PID: $adg_pid" "🥰 启动成功, PID: $adg_pid"
    echo "$adg_pid" >"$PID_FILE"
    if [ "$enable_iptables" = true ]; then
      $SCRIPT_DIR/iptables.sh enable
    fi
  else
    log "😭 Error occurred, check logs for details" "😭 出现错误，请检查日志以获取详细信息"
    update_description "😭 Error occurred, check logs for details" "😭 出现错误，请检查日志以获取详细信息"
    log "==== Last 20 lines of bin.log ====" "==== bin.log 的最后 20 行 ===="
    tail -n 20 "$AGH_DIR/bin.log" | while read -r line; do
      log "$line" "$line"
    done
    exit 1
  fi
}

stop_adguardhome() {
  if [ ! -f "$PID_FILE" ]; then
    log "AdGuardHome is not running" "- AdGuardHome 没有运行"
    exit 0
  fi
  log "Stopping AdGuardHome" "- 停止 AdGuardHome"
  kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
  rm "$PID_FILE"
  $SCRIPT_DIR/iptables.sh disable
  update_description "❌ Stopped" "❌ 已停止"
  log "AdGuardHome stopped" "- AdGuardHome 已停止"
}

case "$1" in
start)
  start_adguardhome
  ;;
stop)
  stop_adguardhome
  ;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
  ;;
esac
