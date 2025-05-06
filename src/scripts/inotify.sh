readonly EVENTS=$1
readonly MONITOR_DIR=$2
readonly MONITOR_FILE=$3

AGH_DIR="/data/adb/agh"
SCRIPT_DIR="$AGH_DIR/scripts"
MOD_PATH="/data/adb/modules/AdGuardHome"
source "$AGH_DIR/scripts/config.sh"

exec >>$AGH_DIR/agh.log 2>&1

update_description() {
  sed -i "s/description=\[.*\]/description=\[$1\]/" "$MOD_PATH/module.prop"
}

if [ "${MONITOR_FILE}" = "disable" ]; then
  if [ "${EVENTS}" = "d" ]; then
    echo "trying to stop module"
    $SCRIPT_DIR/service.sh start
    if [ $? -ne 0 ]; then
      update_description "🔴failed to start bin"
      exit 1
    fi
    if [ "$enable_iptables" = true ]; then
      $SCRIPT_DIR/iptables.sh enable
      if [ $? -ne 0 ]; then
        update_description "🔴failed to enable iptables"
        exit 1
      fi
      echo "iptables is enabled"
      update_description "🟢bin is running \& iptables is enabled"
    else
      echo "iptables is disabled"
      update_description "🟢bin is running \& iptables is disabled"
    fi
  elif [ "${EVENTS}" = "n" ]; then
    if [ "$enable_iptables" = true ]; then
      $SCRIPT_DIR/iptables.sh disable
    fi
    $SCRIPT_DIR/service.sh stop
    update_description "🔴module is stopped"
  fi
fi
