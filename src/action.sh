#!/system/bin/sh

source "/data/adb/agh/settings.conf"

if [ -f "$PID_FILE" ]; then
  $SCRIPT_DIR/stop.sh
else
  $SCRIPT_DIR/start.sh
fi

echo "Waiting for 1 second..."
sleep 1
