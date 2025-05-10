. /data/adb/agh/settings.conf

if [ -f "$PID_FILE" ]; then
  $SCRIPT_DIR/tool.sh stop
else
  $SCRIPT_DIR/tool.sh start
fi

log "Waiting for 1 second to exit..." "- 等待 1 秒钟退出..."
sleep 1
