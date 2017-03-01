#!/bin/bash
subnet=$1
ip_index_host=10
ip_index_router=1
if [ $# -eq 0 ] ; then
	echo "Must specify subnet"
	exit
fi

function sumIP {
	echo $(echo $subnet | awk -F "." '{print $1"."$2"."$3}').$(($(echo $subnet | cut -d "/" -f 1 | cut -d '.' -f 4)+$1))
}
subnet_cidr=$(echo $subnet | cut -d "/" -f 2)
ip_host=$(sumIP $ip_index_host)
ip_router=$(sumIP $ip_index_router)
ip address add $ip_host/$subnet_cidr dev eth0
ip route add default via $ip_router
