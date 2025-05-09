SKIPUNZIP=1

language=$(getprop persist.sys.locale || getprop ro.product.locale | grep -q '^en' && echo en || echo zh)

function info() {
  [ "$language" = "en" ] && ui_print "$1" || ui_print "$2"
}

function error() {
  [ "$language" = "en" ] && abort "$1" || abort "$2"
}

info "- Installing AdGuardHome for $ARCH" "- 开始安装 AdGuardHome for $ARCH"

AGH_DIR="/data/adb/agh"
BIN_DIR="$AGH_DIR/bin"
SCRIPT_DIR="$AGH_DIR/scripts"
BACKUP_DIR="$AGH_DIR/backup"
PID_FILE="$AGH_DIR/bin/agh.pid"

info "- Extracting module basic files..." "- 解压模块基本文件..."
unzip -o "$ZIPFILE" "action.sh" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "module.prop" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "service.sh" -d $MODPATH >/dev/null 2>&1
unzip -o "$ZIPFILE" "uninstall.sh" -d $MODPATH >/dev/null 2>&1

extract_keep_config() {
  info "- Keeping old configuration files" "- 保留原来的配置文件"
  unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract scripts" "- 解压脚本文件失败"
  }
  unzip -o "$ZIPFILE" "bin/*" -x "bin/AdGuardHome.yaml" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract binary files" "- 解压二进制文件失败"
  }
  unzip -o "$ZIPFILE" "settings.conf" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract configuration files" "- 解压配置文件失败"
  }
}

extract_no_config() {
  if [ -d "$BACKUP_DIR" ]; then
    rm -r "$BACKUP_DIR"
  fi
  mkdir -p "$BACKUP_DIR"
  info "- Backing up old configuration files..." "- 正在备份旧配置文件..."
  mv "$AGH_DIR/settings.conf" "$BACKUP_DIR"
  mv "$AGH_DIR/bin/AdGuardHome.yaml" "$BACKUP_DIR"
  info "- Extracting script files..." "- 正在解压脚本文件..."
  unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract scripts" "- 解压脚本文件失败"
  }
  info "- Extracting binary files..." "- 正在解压二进制文件..."
  unzip -o "$ZIPFILE" "bin/*" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract binary files" "- 解压二进制文件失败"
  }
  info "- Extracting configuration files..." "- 正在解压配置文件..."
  unzip -o "$ZIPFILE" "settings.conf" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract configuration files" "- 解压配置文件失败"
  }
}

first_install_extract() {
  info "- First time installation, extracting files..." "- 第一次安装，正在解压文件..."
  mkdir -p "$AGH_DIR" "$BIN_DIR" "$SCRIPT_DIR"
  info "- Extracting script files..." "- 正在解压脚本文件..."
  unzip -o "$ZIPFILE" "scripts/*" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract scripts" "- 解压脚本文件失败"
  }
  info "- Extracting binary files..." "- 正在解压二进制文件..."
  unzip -o "$ZIPFILE" "bin/*" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract binary files" "- 解压二进制文件失败"
  }
  info "- Extracting configuration files..." "- 正在解压配置文件..."
  unzip -o "$ZIPFILE" "settings.conf" -d $AGH_DIR >/dev/null 2>&1 || {
    error "- Failed to extract configuration files" "- 解压配置文件失败"
  }
}

if [ -d "$AGH_DIR" ]; then
  if [ -f "$PID_FILE" ]; then
    info "- Found running AdGuardHome process, stopping..." "- 发现正在运行的 AdGuardHome 进程，正在停止..."
    kill $(cat "$PID_FILE") || kill -9 $(cat "$PID_FILE")
    rm "$PID_FILE"
    sleep 1
  fi
  info "- Found old version, do you want to keep the old configuration? (If not, it will be automatically backed up)" "- 发现旧版模块，是否保留原来的配置文件？（若不保留则自动备份）"
  info "- (Volume Up = Yes, Volume Down = No, 10s no input = No)" "- （音量上键 = 是, 音量下键 = 否，10秒无操作 = 否）"
  START_TIME=$(date +%s)
  while true ; do
    NOW_TIME=$(date +%s)
    timeout 1 getevent -lc 1 2>&1 | grep KEY_VOLUME > "$TMPDIR/events"
    if [ $(( NOW_TIME - START_TIME )) -gt 9 ]; then
      info "- No input detected after 10 seconds, defaulting to not keep old configuration." "- 10秒无输入，默认不保留原配置。"
      extract_no_config
      break
    elif $(cat $TMPDIR/events | grep -q KEY_VOLUMEUP); then
      extract_keep_config
      break
    elif $(cat $TMPDIR/events | grep -q KEY_VOLUMEDOWN); then
      extract_no_config
      break
    fi
  done
else
  first_install_extract
fi

info "- Setting permissions..." "- 设置权限..."
chmod +x "$BIN_DIR/AdGuardHome"
chown root:net_raw "$BIN_DIR/AdGuardHome"

chmod +x "$SCRIPT_DIR/inotify.sh"
chmod +x "$SCRIPT_DIR/iptables.sh"
chmod +x "$SCRIPT_DIR/tool.sh"

chmod +x "$MODPATH/action.sh"
chmod +x "$MODPATH/service.sh"
chmod +x "$MODPATH/uninstall.sh"

info "- Installation completed, please reboot." "- 安装完成，请重启设备。"
