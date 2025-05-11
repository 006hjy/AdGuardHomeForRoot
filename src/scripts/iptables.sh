. /data/adb/agh/settings.conf

iptables_w="iptables -w 64"
ip6tables_w="ip6tables -w 64"

enable_iptables() {
  $iptables_w -t nat -N ADGUARD_REDIRECT_DNS

  # return requests from AdGuardHome
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -m owner --uid-owner $adg_user --gid-owner $adg_group -j RETURN

  # return requests from ignore_dest_list
  for subnet in $ignore_dest_list; do
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -d $subnet -j RETURN
  done

  # return requests from ignore_src_list
  for subnet in $ignore_src_list; do
    $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -s $subnet -j RETURN
  done

  # redirect DNS requests to AdGuardHome
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p udp --dport 53 -j REDIRECT --to-ports $redir_port
  $iptables_w -t nat -A ADGUARD_REDIRECT_DNS -p tcp --dport 53 -j REDIRECT --to-ports $redir_port

  # apply iptables rules
  $iptables_w -t nat -I OUTPUT -j ADGUARD_REDIRECT_DNS
}

disable_iptables() {
  $iptables_w -t nat -D OUTPUT -j ADGUARD_REDIRECT_DNS
  $iptables_w -t nat -F ADGUARD_REDIRECT_DNS
  $iptables_w -t nat -X ADGUARD_REDIRECT_DNS
}

add_block_ipv6_dns() {
  $ip6tables_w -t filter -N ADGUARD_BLOCK_DNS
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p udp --dport 53 -j DROP
  $ip6tables_w -t filter -A ADGUARD_BLOCK_DNS -p tcp --dport 53 -j DROP
  $ip6tables_w -t filter -I OUTPUT -j ADGUARD_BLOCK_DNS
}

del_block_ipv6_dns() {
  $ip6tables_w -t filter -F ADGUARD_BLOCK_DNS
  $ip6tables_w -t filter -D OUTPUT -j ADGUARD_BLOCK_DNS
  $ip6tables_w -t filter -X ADGUARD_BLOCK_DNS
}

case "$1" in
enable)
  enable_iptables
  [ "$block_ipv6_dns" = true ] && add_block_ipv6_dns
  ;;
disable)
  disable_iptables
  del_block_ipv6_dns
  ;;
*)
  echo "Usage: $0 {enable|disable}"
  exit 1
  ;;
esac
