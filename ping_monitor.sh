#!/bin/bash
NAME="PingMonitor"
HOSTS="8.8.8.8 192.228.79.201 199.7.83.42 8.8.4.4"
ROUTER="192.168.1.254"
COUNT=2
PING_ARGS="-w 2 -W 2 -c $COUNT"
ROUTER_PASS=`cat /etc/router_pass`


function log() {
	logger -t $NAME ${@}
}


count=$(ping $PING_ARGS $ROUTER | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
if [ $count -eq 0 ]; then
	log "WARN  - ping to 4g router failed, maybe it is rebooting"
	exit 1
else
	log "INFO  - 4g router is alive"
fi


count=0
for myHost in $HOSTS; do
	local_count=$(ping $PING_ARGS $myHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')	
	if [ $local_count -eq 0 ]; then
		log "WARN  - ping to $myHost failed"
	else
		log "INFO  - ping to $myHost succeded"
	fi
	count=$(($count + $local_count))
done


if [ $count -eq 0 ]; then
	log "ERROR - ping to all host failed"
	log "INFO  - rebooting 4g router"
    	curl -u admin:`echo $ROUTER_PASS` "http://192.168.1.254/uir/rebo.htm" > /dev/null
    	curl -u admin:`echo $ROUTER_PASS` "http://192.168.1.254/uir/rebo.htm" > /dev/null
    	log "INFO  - 4g router rebooted"
	exit 2
fi


if [ $count == 8 ]; then
	log "INFO  - ping to fixed hosts succeded"
else
	log "WARN  - ping to fixed hosts mostly succeded"
fi

exit 0
