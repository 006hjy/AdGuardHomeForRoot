#!/system/bin/sh

source "/data/adb/agh/settings.conf"

if [ -f "$PID_FILE" ]; then
  $SCRIPT_DIR/tool.sh stop
else
  $SCRIPT_DIR/tool.sh start
fi

echo "Waiting for 1 second..."
sleep 1
