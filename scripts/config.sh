#!/system/bin/sh

# 添加busybox到PATH
if ! command -v busybox &> /dev/null; then
  export PATH="/data/adb/magisk:/data/adb/ksu/bin:/data/adb/ap/bin:$PATH:/system/bin"
fi

# 手动模式，默认关闭，开启后iptables.sh将跳过运行，如果你要在开机状态下修改本项，请先在Magisk/KernelSU关闭模块以确保预期的行为
# true: 开启
# false: 关闭
manual=false

# 是否开启 ipv6 DNS 查询，建议关闭
# true: 开启
# false: 关闭
ipv6=false

# 路由模式选择
# true: 黑名单
# false: 白名单
use_blacklist=true

# 重定向端口
redir_port=5591

# 用户组和用户
adg_user="root"
adg_group="net_raw"

# 应用包名列表
# 例如: ("com.tencent.mm" "com.tencent.mobileqq")
packages_list=()

# 以下内容无需修改
system_packages_file="/data/system/packages.list"
agh_pid_file="/data/adb/agh/bin/agh_pid"
iptables_w="iptables -w 64"
ip6tables_w="ip6tables -w 64"
