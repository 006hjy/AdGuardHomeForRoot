#!/system/bin/sh

(
  while [ "$(getprop init.svc.bootanim)" != "stopped" ]; do
    sleep 12
  done

  /data/adb/agh/scripts/start.sh 

  inotifyd /data/adb/agh/sctipts/inotify.sh /data/adb/modules/AdGuardHome:d,n &
) &
