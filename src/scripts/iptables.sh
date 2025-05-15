. /data/adb/agh/settings.conf
. /data/adb/agh/scripts/base.sh

iptables_w="iptables -w 64"
ip6tables_w="ip6tables -w 64"

enable_iptables() {
  # Check if the ADGUARD_REDIRECT_DNS chain exists before attempting to create it
  if $iptables_w -t nat -L ADGUARD_REDIRECT_DNS >/dev/null 2>&1; then
    log "ADGUARD_REDIRECT_DNS chain already exists, skipping creation" "ADGUARD_REDIRECT_DNS 链已经存在，跳过创建"
    return 0
  fi

  # create ADGUARD_REDIRECT_DNS chain
  log "Trying to create ADGUARD_REDIRECT_DNS chain" "尝试创建 ADGUARD_REDIRECT_DNS 链"
  $iptables_w -t nat -N ADGUARD_REDIRECT_DNS || {
    log "Failed to create ADGUARD_REDIRECT_DNS chain" "创建 ADGUARD_REDIRECT_DNS 链失败"
    return 1
  }
  log "Created ADGUARD_REDIRECT_DNS chain" "创建 ADGUARD_REDIRECT_DNS 链成功"

  # return requests from AdGuardHome
  log "Adding iptables rules, excluding AdGuardHome itself" "正在添加 iptables 规则（排除 AdGuardHome 自身）"
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -m owner --uid-owner $adg_user --gid-owner $adg_group -j RETURN || {
    log "Failed to add iptables rules" "添加 iptables 规则失败"
    return 1
  }
  log "Added iptables rules" "添加 iptables 规则成功"

  # return requests from ignore_dest_list
  for subnet in $ignore_dest_list; do
    log "Adding iptables rules for destination: $subnet" "正在添加 iptables 规则，目的地址: $subnet"
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -d $subnet -j RETURN || {
      log "Failed to add iptables rules for destination: $subnet" "添加 iptables 规则失败，目的地址: $subnet"
      return 1
    }
    log "Added iptables rules for destination: $subnet" "添加 iptables 规则成功，目的地址: $subnet"
  done

  # return requests from ignore_src_list
  for subnet in $ignore_src_list; do
    log "Adding iptables rules for source: $subnet" "正在添加 iptables 规则，源地址: $subnet"
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -s $subnet -j RETURN || {
      log "Failed to add iptables rules for source: $subnet" "添加 iptables 规则失败，源地址: $subnet"
      return 1
    }
    log "Added iptables rules for source: $subnet" "添加 iptables 规则成功，源地址: $subnet"
  done

  # redirect DNS requests to AdGuardHome
  log "Redirecting udp 53 to $redir_port" "正在重定向 udp 53 到 $redir_port"
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p udp --dport 53 -j REDIRECT --to-ports $redir_port || {
    log "Failed to redirect udp 53 to $redir_port" "重定向 udp 53 到 $redir_port 失败"
    return 1
  }
  log "Redirected udp 53 to $redir_port" "重定向 udp 53 到 $redir_port 成功"

  # redirect DNS requests to AdGuardHome
  log "Redirecting tcp 53 to $redir_port" "正在重定向 tcp 53 到 $redir_port"
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p tcp --dport 53 -j REDIRECT --to-ports $redir_port || {
    log "Failed to redirect tcp 53 to $redir_port" "重定向 tcp 53 到 $redir_port 失败"
    return 1
  }
  log "Redirected tcp 53 to $redir_port" "重定向 tcp 53 到 $redir_port 成功"

  # apply iptables rules
  log "Applying iptables rules" "正在应用 iptables 规则"
  $iptables_w -t nat -I OUTPUT -j ADGUARD_REDIRECT_DNS || {
    log "Failed to apply iptables rules" "应用 iptables 规则失败"
    return 1
  }
  log "Applied iptables rules" "应用 iptables 规则成功"
}

disable_iptables() {
  # Check if the ADGUARD_REDIRECT_DNS chain exists before attempting to delete rules
  if ! $iptables_w -t nat -L ADGUARD_REDIRECT_DNS >/dev/null 2>&1; then
    log "ADGUARD_REDIRECT_DNS chain does not exist, skipping deletion" "ADGUARD_REDIRECT_DNS 链不存在，跳过删除"
    return 0
  fi

  log "Deleting iptables rules" "正在删除 iptables 规则"
  $iptables_w -t nat -D OUTPUT -j ADGUARD_REDIRECT_DNS || {
    log "Failed to delete iptables rules" "删除 iptables 规则失败"
    return 1
  }
  log "Deleted iptables rules" "删除 iptables 规则成功"

  log "Flushing iptables rules" "正在清空 iptables 规则"
  $iptables_w -t nat -F ADGUARD_REDIRECT_DNS || {
    log "Failed to flush iptables rules" "清空 iptables 规则失败"
    return 1
  }
  log "Flushed iptables rules" "清空 iptables 规则成功"

  log "Deleting iptables chain" "正在删除 iptables 链"
  $iptables_w -t nat -X ADGUARD_REDIRECT_DNS || {
    log "Failed to delete iptables chain" "删除 iptables 链失败"
    return 1
  }
}

add_block_ipv6_dns() {
  # Check if the ADGUARD_BLOCK_DNS chain exists before attempting to create it
  if $ip6tables_w -t filter -L ADGUARD_BLOCK_DNS >/dev/null 2>&1; then
    log "ADGUARD_BLOCK_DNS chain already exists, skipping creation" "ADGUARD_BLOCK_DNS 链已经存在，跳过创建"
    return 0
  fi

  log "Creating ADGUARD_BLOCK_DNS chain" "正在创建 ADGUARD_BLOCK_DNS 链"
  $ip6tables_w -t filter -N ADGUARD_BLOCK_DNS || {
    log "Failed to create ADGUARD_BLOCK_DNS chain" "创建 ADGUARD_BLOCK_DNS 链失败"
    return 1
  }
  log "Created ADGUARD_BLOCK_DNS chain" "创建 ADGUARD_BLOCK_DNS 链成功"

  log "Blocking ipv6 udp 53" "正在阻止 ipv6 udp 53"
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p udp --dport 53 -j DROP || {
    log "Failed to block ipv6 udp 53" "阻止 ipv6 udp 53 失败"
    return 1
  }
  log "Blocked ipv6 udp 53" "阻止 ipv6 udp 53 成功"

  log "Blocking ipv6 tcp 53" "正在阻止 ipv6 tcp 53"
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p tcp --dport 53 -j DROP || {
    log "Failed to block ipv6 tcp 53" "阻止 ipv6 tcp 53 失败"
    return 1
  }
  log "Blocked ipv6 tcp 53" "阻止 ipv6 tcp 53 成功"

  log "Applying ipv6 iptables rules" "正在应用 ipv6 iptables 规则"
  $ip6tables_w -t filter -I OUTPUT -j ADGUARD_BLOCK_DNS || {
    log "Failed to apply ipv6 iptables rules" "应用 ipv6 iptables 规则失败"
    return 1
  }
  log "Applied ipv6 iptables rules" "应用 ipv6 iptables 规则成功"
}

del_block_ipv6_dns() {
  # Check if the ADGUARD_BLOCK_DNS chain exists before attempting to delete rules
  if ! $ip6tables_w -t filter -L ADGUARD_BLOCK_DNS >/dev/null 2>&1; then
    log "ADGUARD_BLOCK_DNS chain does not exist, skipping deletion" "ADGUARD_BLOCK_DNS 链不存在，跳过删除"
    return 0
  fi

  log "Deleting ipv6 iptables rules" "正在删除 ipv6 iptables 规则"
  $ip6tables_w -t filter -F ADGUARD_BLOCK_DNS || {
    log "Failed to delete ipv6 iptables rules" "删除 ipv6 iptables 规则失败"
    return 1
  }
  log "Deleted ipv6 iptables rules" "删除 ipv6 iptables 规则成功"

  log "Deleting ipv6 iptables chain" "正在删除 ipv6 iptables 链"
  $ip6tables_w -t filter -D OUTPUT -j ADGUARD_BLOCK_DNS || {
    log "Failed to delete ipv6 iptables chain" "删除 ipv6 iptables 链失败"
    return 1
  }
  log "Deleted ipv6 iptables chain" "删除 ipv6 iptables 链成功"

  log "Flushing ipv6 iptables rules" "正在清空 ipv6 iptables 规则"
  $ip6tables_w -t filter -X ADGUARD_BLOCK_DNS || {
    log "Failed to flush ipv6 iptables rules" "清空 ipv6 iptables 规则失败"
    return 1
  }
  log "Flushed ipv6 iptables rules" "清空 ipv6 iptables 规则成功"
}

case "$1" in
enable)
  log "Enabling iptables" "正在启用 iptables"
  enable_iptables || {
    log "Failed to enable iptables" "启用 iptables 失败"
    exit 1
  }
  log "Enabled iptables" "启用 iptables 成功"
  
  if [ "$block_ipv6_dns" = true ]; then
    log "Enabling ipv6 DNS blocking" "正在启用 ipv6 DNS 阻断"
    add_block_ipv6_dns || {
      log "Failed to enable ipv6 DNS blocking" "启用 ipv6 DNS 阻断失败"
      exit 1
    }
    log "Enabled ipv6 DNS blocking" "启用 ipv6 DNS 阻断成功"
  fi
  ;;
disable)
  log "Disabling iptables" "正在禁用 iptables"
  disable_iptables || {
    log "Failed to disable iptables" "禁用 iptables 失败"
    exit 1
  }
  log "Disabled iptables" "禁用 iptables 成功"
  log "Disabling ipv6 DNS blocking" "正在禁用 ipv6 DNS 阻断"
  del_block_ipv6_dns || {
    log "Failed to disable ipv6 DNS blocking" "禁用 ipv6 DNS 阻断失败"
    exit 1
  }
  log "Disabled ipv6 DNS blocking" "禁用 ipv6 DNS 阻断成功"
  ;;
*)
  echo "Usage: $0 {enable|disable}"
  exit 1
  ;;
esac
