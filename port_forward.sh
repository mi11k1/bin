#!/bin/bash

IPTBL=/sbin/iptables

IF_IN=eno1
PORT_IN=10006

IP_OUT=10.42.2.179
PORT_OUT=80

echo "1" > /proc/sys/net/ipv4/ip_forward
$IPTBL -A PREROUTING -t nat -i $IF_IN -p tcp --dport $PORT_IN -j DNAT --to-destination ${IP_OUT}:${PORT_OUT}
$IPTBL -A FORWARD -p tcp -d $IP_OUT --dport $PORT_OUT -j ACCEPT
$IPTBL -A POSTROUTING -t nat -j MASQUERADE
