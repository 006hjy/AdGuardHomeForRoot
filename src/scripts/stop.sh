#!/system/bin/sh

source "/data/adb/agh/settings.conf"

if [ ! -f "$PID_FILE" ]; then
  log "pid file not found"
  exit 1
fi
log "Stopping AdGuardHome"
kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
rm "$PID_FILE"
$SCRIPT_DIR/iptables.sh stop
