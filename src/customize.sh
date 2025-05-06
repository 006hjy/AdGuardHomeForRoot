#!/system/bin/sh
SKIPUNZIP=1

case $(getprop persist.sys.locale || getprop ro.product.locale) in
zh*)
  language=zh
  ;;
en*)
  language=en
  ;;
*)
  language=zh
  ;;
esac

function log() {
  local str
  local timestamp=$(date "+%Y-%m-%d %H:%M:%S")

  case $language in
  en)
    str="$timestamp $1"
    ;;
  zh)
    str="$timestamp $2"
    ;;
  esac

  ui_print "$str" | tee -a "$AGH_DIR/agh.log"
}

log "- Installing AdGuardHome for $ARCH" "- 开始安装 AdGuardHome for $ARCH"

AGH_DIR="/data/adb/agh"
BIN_DIR="$AGH_DIR/bin"
SCRIPT_DIR="$AGH_DIR/scripts"
BACKUP_DIR="$AGH_DIR/backup"
PID_FILE="$AGH_DIR/bin/agh_pid"

log "- Extracting module basic files..." "- 解压模块基本文件..."
unzip -o "$ZIPFILE" "uninstall.sh" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "module.prop" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "service.sh" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "action.sh" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "webroot/*" -d $MODPATH >/dev/null 2>&1

if [ -d "$AGH_DIR" ]; then
  # TODO: remove in future versions
  if [ -f "/data/adb/service.d/agh_service.sh" ]; then
    rm "/data/adb/service.d/agh_service.sh"
  fi
  # Stop AdGuardHome
  if [ -f "$PID_FILE" ]; then
    log "- Found running AdGuardHome process, stopping..." "- 发现正在运行的 AdGuardHome 进程，正在停止..."
    kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
    rm "$PID_FILE"
    sleep 1
  fi
  log "- Found old version, do you want to keep the old configuration? (If not, it will be automatically backed up)" "- 发现旧版模块，是否保留原来的配置文件？（若不保留则自动备份）"
  log "- (Volume Up = Yes, Volume Down = No)" "- （音量上键 = 是, 音量下键 = 否）"
  key_click=""
  while [ "$key_click" = "" ]; do
    key_click="$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_')"
    sleep 0.2
  done
  case "$key_click" in
  "KEY_VOLUMEUP")
    log "- Keeping old configuration files" "- 保留原来的配置文件"
    unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
      log "- Failed to extract scripts" "- 解压脚本文件失败"
      exit 1
    }
    unzip -o "$ZIPFILE" "bin/*" -x "bin/AdGuardHome.yaml" -d $AGH_DIR >/dev/null 2>&1 || {
      log "- Failed to extract binary files" "- 解压二进制文件失败"
      exit 1
    }
    ;;
  *)
    if [ -d "$BACKUP_DIR" ]; then
      rm -r "$BACKUP_DIR"
    fi
    mkdir -p "$BACKUP_DIR"
    log "- Backing up old configuration files..." "- 正在备份旧配置文件..."
    mv "$AGH_DIR/scripts/config.sh" "$BACKUP_DIR"
    mv "$AGH_DIR/bin/AdGuardHome.yaml" "$BACKUP_DIR"
    log "- Extracting script files..." "- 正在解压脚本文件..."
    unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
      log "- Failed to extract scripts" "- 解压脚本文件失败"
      exit 1
    }
    log "- Extracting binary files..." "- 正在解压二进制文件..."
    unzip -o "$ZIPFILE" "bin/*" -d $AGH_DIR >/dev/null 2>&1 || {
      log "- Failed to extract binary files" "- 解压二进制文件失败"
      exit 1
    }
    ;;
  esac
else
  log "- First time installation, extracting files..." "- 第一次安装，正在解压文件..."
  mkdir -p "$AGH_DIR" "$BIN_DIR" "$SCRIPT_DIR"
  log "- Extracting script files..." "- 正在解压脚本文件..."
  unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
    log "- Failed to extract scripts" "- 解压脚本文件失败"
    exit 1
  }
  log "- Extracting binary files..." "- 正在解压二进制文件..."
  unzip -o "$ZIPFILE" "bin/*" -d $AGH_DIR >/dev/null 2>&1 || {
    log "- Failed to extract binary files" "- 解压二进制文件失败"
    exit 1
  }
fi

log "- Setting permissions..." "- 设置权限..."
chmod +x "$BIN_DIR/AdGuardHome"
chmod +x "$SCRIPT_DIR/inotify.sh"
chmod +x "$SCRIPT_DIR/iptables.sh"
chmod +x "$SCRIPT_DIR/service.sh"
chmod +x "$SCRIPT_DIR/action.sh"
chmod +x "$MODPATH/uninstall.sh"
chown root:net_raw "$BIN_DIR/AdGuardHome"

log "- Installation completed, please reboot." "- 安装完成，请重启设备。"
