#!/bin/bash
interfaces=( eth0 eth1 )

if [ $# -eq 0 ]; then
	echo "- no parameteres specified -"
	echo "  usage: $0 new_rate subnet"
	exit
fi

realm=$(ip r s | grep $2 | awk -F "realm " '{print $2}' | cut -d " " -f 1)

for if in "${interfaces[@]}"; do
	queue=$(tc filter show dev $if | grep $realm | awk -F "flowid " '{print $2}' | cut -d " " -f 1)
	band=$(($(echo $queue | cut -d ":" -f 2)*10))
	tc qdisc change dev $if parent $queue handle $band: tbf rate $1 latency 50ms burst 1540
done

echo " DONE - $2 subnet bandwidth changed to $1"