iptables = "iptables -w 100"
$iptables -t nat -D OUTPUT -j ADGUARD
$iptables -t nat -F ADGUARD
$iptables -t nat -X ADGUARD