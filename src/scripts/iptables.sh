. /data/adb/agh/settings.conf
. /data/adb/agh/scripts/base.sh

iptables_w="iptables -w 64"
ip6tables_w="ip6tables -w 64"

enable_iptables() {
  if $iptables_w -t nat -L ADGUARD_REDIRECT_DNS >/dev/null 2>&1; then
    log "ADGUARD_REDIRECT_DNS chain already exists" "ADGUARD_REDIRECT_DNS 链已经存在"
    return 0
  fi

  log "Creating ADGUARD_REDIRECT_DNS chain and adding rules" "创建 ADGUARD_REDIRECT_DNS 链并添加规则"
  $iptables_w -t nat -N ADGUARD_REDIRECT_DNS || return 1
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -m owner --uid-owner $adg_user --gid-owner $adg_group -j RETURN || return 1

  for subnet in $ignore_dest_list; do
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -d $subnet -j RETURN || return 1
  done

  for subnet in $ignore_src_list; do
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -s $subnet -j RETURN || return 1
  done

  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p udp --dport 53 -j REDIRECT --to-ports $redir_port || return 1
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p tcp --dport 53 -j REDIRECT --to-ports $redir_port || return 1
  $iptables_w -t nat -I OUTPUT -j ADGUARD_REDIRECT_DNS || return 1

  log "Applied iptables rules successfully" "成功应用 iptables 规则"
}

disable_iptables() {
  if ! $iptables_w -t nat -L ADGUARD_REDIRECT_DNS >/dev/null 2>&1; then
    log "ADGUARD_REDIRECT_DNS chain does not exist" "ADGUARD_REDIRECT_DNS 链不存在"
    return 0
  fi

  log "Deleting ADGUARD_REDIRECT_DNS chain and rules" "删除 ADGUARD_REDIRECT_DNS 链及规则"
  $iptables_w -t nat -D OUTPUT -j ADGUARD_REDIRECT_DNS || return 1
  $iptables_w -t nat -F ADGUARD_REDIRECT_DNS || return 1
  $iptables_w -t nat -X ADGUARD_REDIRECT_DNS || return 1
}

add_block_ipv6_dns() {
  if $ip6tables_w -t filter -L ADGUARD_BLOCK_DNS >/dev/null 2>&1; then
    log "ADGUARD_BLOCK_DNS chain already exists" "ADGUARD_BLOCK_DNS 链已经存在"
    return 0
  fi

  log "Creating ADGUARD_BLOCK_DNS chain and adding rules" "创建 ADGUARD_BLOCK_DNS 链并添加规则"
  $ip6tables_w -t filter -N ADGUARD_BLOCK_DNS || return 1
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p udp --dport 53 -j DROP || return 1
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p tcp --dport 53 -j DROP || return 1
  $ip6tables_w -t filter -I OUTPUT -j ADGUARD_BLOCK_DNS || return 1

  log "Applied ipv6 iptables rules successfully" "成功应用 ipv6 iptables 规则"
}

del_block_ipv6_dns() {
  if ! $ip6tables_w -t filter -L ADGUARD_BLOCK_DNS >/dev/null 2>&1; then
    log "ADGUARD_BLOCK_DNS chain does not exist" "ADGUARD_BLOCK_DNS 链不存在"
    return 0
  fi

  log "Deleting ADGUARD_BLOCK_DNS chain and rules" "删除 ADGUARD_BLOCK_DNS 链及规则"
  $ip6tables_w -t filter -F ADGUARD_BLOCK_DNS || return 1
  $ip6tables_w -t filter -D OUTPUT -j ADGUARD_BLOCK_DNS || return 1
  $ip6tables_w -t filter -X ADGUARD_BLOCK_DNS || return 1
}

case "$1" in
enable)
  log "Enabling iptables and ipv6 DNS blocking if configured" "启用 iptables 和 ipv6 DNS 阻断（如果已配置）"
  enable_iptables || exit 1
  [ "$block_ipv6_dns" = true ] && add_block_ipv6_dns || exit 1
  ;;
disable)
  log "Disabling iptables and ipv6 DNS blocking" "禁用 iptables 和 ipv6 DNS 阻断"
  disable_iptables || exit 1
  del_block_ipv6_dns || exit 1
  ;;
*)
  echo "Usage: $0 {enable|disable}"
  exit 1
  ;;
esac
