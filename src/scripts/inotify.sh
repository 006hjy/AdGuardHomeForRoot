readonly EVENTS=$1
readonly MONITOR_DIR=$2
readonly MONITOR_FILE=$3

source "/data/adb/agh/settings.conf"

if [ "${MONITOR_FILE}" = "disable" ]; then
  if [ "${EVENTS}" = "d" ]; then
    $SCRIPT_DIR/start.sh
  elif [ "${EVENTS}" = "n" ]; then
    $SCRIPT_DIR/stop.sh
  fi
fi
