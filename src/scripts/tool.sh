. /data/adb/agh/settings.conf
. /data/adb/agh/scripts/base.sh

start_adguardhome() {
  # check if AdGuardHome is already running
  if [ -f "$PID_FILE" ] && ps | grep -w "$adg_pid" | grep -q "AdGuardHome"; then
    log "AdGuardHome is already running" "AdGuardHome 已经在运行"
    exit 0
  fi

  # to fix https://github.com/AdguardTeam/AdGuardHome/issues/7002
  export SSL_CERT_DIR="/system/etc/security/cacerts/"
  # set timezone to Shanghai
  export TZ="Asia/Shanghai"
  # run binary
  busybox setuidgid "$adg_user:$adg_group" "$BIN_DIR/AdGuardHome" >>"$AGH_DIR/bin.log" 2>&1 &
  adg_pid=$!

  # check if AdGuardHome started successfully
  if ps | grep -w "$adg_pid" | grep -q "AdGuardHome"; then
    log "🥰 started" "🥰 启动成功"
    update_description "🥰 Started" "🥰 启动成功"
    echo "$adg_pid" >"$PID_FILE"
    log "AdGuardHome PID: $adg_pid" "AdGuardHome PID: $adg_pid"
    append_description " PID: $adg_pid" " PID: $adg_pid"
    # check if iptables is enabled
    if [ "$enable_iptables" = true ]; then
      $SCRIPT_DIR/iptables.sh enable
      append_description " enable_iptables: $enable_iptables" " enable_iptables: $enable_iptables"
    fi
  else
    log "😭 Error occurred, check logs for details" "😭 出现错误，请检查日志以获取详细信息"
    update_description "😭 Error occurred, check logs for details" "😭 出现错误，请检查日志以获取详细信息"
    $SCRIPT_DIR/debug.sh
    exit 1
  fi
}

stop_adguardhome() {
  if [ -f "$PID_FILE" ]; then
    log "Killing AdGuardHome using PID: $(cat $PID_FILE)" "使用 PID 杀死 AdGuardHome: $(cat $PID_FILE)"
    kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
    rm "$PID_FILE"
  else
    log "Force killing AdGuardHome" "强制杀死 AdGuardHome"
    pkill -f "AdGuardHome" || pkill -9 -f "AdGuardHome"
  fi
  update_description "❌ Stopped" "❌ 已停止"
  log "AdGuardHome stopped" "AdGuardHome 已停止"
  $SCRIPT_DIR/iptables.sh disable
  append_description " enable_iptables: $enable_iptables" " enable_iptables: $enable_iptables"
}

toggle_adguardhome() {
  if [ -f "$PID_FILE" ] && ps | grep -w "$(cat $PID_FILE)" | grep -q "AdGuardHome"; then
    stop_adguardhome
  else
    start_adguardhome
  fi
}

case "$1" in
start)
  start_adguardhome
  ;;
stop)
  stop_adguardhome
  ;;
toggle)
  toggle_adguardhome
  ;;
*)
  echo "Usage: $0 {start|stop|toggle}"
  exit 1
  ;;
esac
