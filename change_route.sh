#!/bin/bash
#set -x

usage() { 
  echo "Usage: $0 IP_ADDRESS mode (mode:4g|vpn|amazon)" 1>&2; exit 1; 
}

if [ $# = 2 ]; then
  address=$1
  mode=$2
else
  usage
fi

RT_TABLE="vpn"
RT_TABLE2="vpn2"

add_vpn_subnet() {
  ip route show table $RT_TABLE | grep "10.8.0.0/24 dev tun0  scope link" > /dev/null
  if [ $? != 0 ]; then
    ip route add 10.8.0.0/24 dev tun0 table $RT_TABLE
  fi
  ip route show table $RT_TABLE2 | grep "10.8.1.0/24 dev tun1  scope link" > /dev/null
  if [ $? != 0 ]; then
    ip route add 10.8.1.0/24 dev tun1 table $RT_TABLE2
  fi
}

add_rule_to_vpn_gw() {
  ip rule |grep "from all to 10.8.0.1 lookup $RT_TABLE" > /dev/null
  if [ $? != 0 ]; then
    ip rule add to 10.8.0.1 table $RT_TABLE
  fi
  ip rule |grep "from all to 10.8.1.1 lookup $RT_TABLE2" > /dev/null
  if [ $? != 0 ]; then
    ip rule add to 10.8.1.1 table $RT_TABLE2
  fi
}

add_vpn_gw() {
  ip route show table $RT_TABLE | grep "default via 10.8.0.1 dev tun0" > /dev/null
  if [ $? != 0 ]; then 
    ip route add default via 10.8.0.1 dev tun0 table $RT_TABLE
  fi
  ip route show table $RT_TABLE2 | grep "default via 10.8.1.1 dev tun1" > /dev/null
  if [ $? != 0 ]; then 
    ip route add default via 10.8.1.1 dev tun1 table $RT_TABLE2
  fi
}

masquerade_and_flush() {
  iptables -t nat -I POSTROUTING -o tun0 -j MASQUERADE
  iptables -t nat -I POSTROUTING -o tun1 -j MASQUERADE
  ip route flush cache
}

remove_route() {
  ip rule del from $address table $1
}


add_route() {
  ip rule add from $address table $1
}

# Main
case $mode in
  "4g")
    remove_route vpn
    remove_route vpn2
  ;;
  "$RT_TABLE")
    remove_route vpn
    remove_route vpn2
    add_route vpn 
  ;;
  "amazon")
    remove_route vpn
    remove_route vpn2
    add_route vpn2
  ;;
  *)
    usage
  ;;
esac

add_vpn_subnet
add_rule_to_vpn_gw
add_vpn_gw
masquerade_and_flush

exit 0
