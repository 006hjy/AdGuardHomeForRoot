until [ $(getprop init.svc.bootanim) = stopped ]; do
  sleep 5
done

/data/adb/agh/scripts/tool.sh start

inotifyd /data/adb/agh/scripts/inotify.sh /data/adb/modules/AdGuardHome:d,n &
