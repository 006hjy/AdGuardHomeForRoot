iptables -t nat -N ADGUARD
# 返回所有 AdGuardHome 的请求
iptables -t nat -A ADGUARD -m owner --uid-owner root --gid-owner net_admin -j RETURN
# 将 53 端口所有 udp tcp 流量转发到 adguard home
# iptables -t nat -A ADGUARD -p udp --dport 53 -j DNAT --to-destination 127.0.0.1:5591
# iptables -t nat -A ADGUARD -p tcp --dport 53 -j DNAT --to-destination 127.0.0.1:5591
iptables -t nat -A ADGUARD -p udp --dport 53 -j REDIRECT --to-ports 5591
iptables -t nat -A ADGUARD -p tcp --dport 53 -j REDIRECT --to-ports 5591
# 将 ADGUARD 规则添加到 OUTPUT
iptables -t nat -A OUTPUT -j ADGUARD