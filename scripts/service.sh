#!/system/bin/sh

AGH_DIR="/data/adb/agh"
BIN_DIR="$AGH_DIR/bin"
SCRIPT_DIR="$AGH_DIR/scripts"
source "$AGH_DIR/scripts/config.sh"

exec >>$AGH_DIR/agh.log 2>&1

start_bin() {
  # to fix https://github.com/AdguardTeam/AdGuardHome/issues/7002
  export SSL_CERT_DIR="/system/etc/security/cacerts/"
  busybox setuidgid "$adg_user:$adg_group" "$BIN_DIR/AdGuardHome" --logfile "$BIN_DIR/AdGuardHome.log" --no-check-update &
  echo $! >"$agh_pid_file"
}

stop_bin() {
  kill -9 $(cat "$agh_pid_file")
  rm "$agh_pid_file"
}

case "$1" in
start)
  start_bin
  ;;
stop)
  stop_bin
  ;;
*)
  echo "Usage: $0 {start|stop}"
  exit 1
  ;;
esac
