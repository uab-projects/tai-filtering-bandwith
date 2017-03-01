#!/bin/bash
echo "Adding default balance weights 192.168.0.1->$1, 192.168.1.1->$2 to default route" 
cmd="ip route add default scope global nexthop via 192.168.0.1 dev eth0 weight $1 nexthop via 192.168.1.1 dev eth1 weight $2"
$cmd &> /dev/null
if [ $? -eq 2 ]; then
	# modify default
	echo "WARNING: Default entry already existed, modifying it..."
	ip route delete default
	$cmd
fi
echo "Balancing succesfully applied"

