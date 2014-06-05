#!/bin/bash
#set -x

usage() { 
  echo "Usage: $0 IP_ADDRESS mode (mode:4g|vpn)" 1>&2; exit 1; 
}

if [ $# = 2 ]; then
  address=$1
  mode=$2
else
  usage
fi

RT_TABLE_PATH=/etc/iproute2/rt_tables
RT_TABLE="vpn"


remove_route() {
  ip rule del from $address table $RT_TABLE
}


add_route() {
  ip rule add from $address table $RT_TABLE
}

case $mode in
  "4g")
    remove_route
  ;;
  "vpn")
    remove_route
    add_route 
  ;;
  *)
    usage
  ;;
esac

exit 0
