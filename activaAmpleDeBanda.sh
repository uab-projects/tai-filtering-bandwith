#!/bin/bash
# CONFIGURATIONS
interfaces=( eth0 eth1 )
networks=( 192.168.2.0/27 192.168.2.32/27 192.168.2.64/27 192.168.2.96/27 192.168.2.128/27 192.168.2.160/27 192.168.2.192/27 192.168.2.224/27 )
bands_per_interface=8
realm_start=10
realm_increment=10
realm_dev=eth2

# welcome message
echo "====================== QUEUE DISCIPLINES ======================"
echo "Creating queue disciplines (bands=$bands_per_interface)"
# loop interfaces
for if in "${interfaces[@]}"; do
	# set bands
	echo "-----------------------------------------------"
	echo "INTERFACE $if"
	echo "-----------------------------------------------"
	echo " Creating prio bands..."
	tc qdisc del dev $if root
	tc qdisc add dev $if root handle 1: prio bands $bands_per_interface
	# set limitation
	# first band
	echo " Creating unlimited sfq band..."
	tc qdisc add dev $if parent 1:1 handle 10: sfq
	# other bands
	echo " Creating limited bands..."
	for i in `seq 2 $bands_per_interface`; do
		rate=$(($i - 1))0kbit
		tc qdisc add dev $if parent 1:$i handle ${i}0: tbf rate $rate latency 50ms burst 1540
	done
done
echo "=================== REALM CLASSIFYING =================="
echo "Classifying networks with realm value (start=$realm_start,increment=$realm_increment)"
realm=$realm_start
for network in "${networks[@]}"; do
	cmd="ip route add $network dev $realm_dev realm $realm"
	$cmd &> /dev/null
	echo $cmd
	if [ $? -eq 2 ]; then
		ip route del $network dev $realm_dev
		$cmd
	fi
	realm=$(($realm + $realm_increment))
done
echo "==================== TC FILTERING ======================"
echo "Creating mapping rules using previous classification"
for if in "${interfaces[@]}"; do
	echo "------------------------------------------------"
	echo " INTERFACE $if"
	echo "------------------------------------------------"
	realm=$realm_start
	tc filter add dev $if route from $realm flowid 1:1
	for i in `seq 2 $bands_per_interface`; do
		realm=$(($realm + $realm_increment))
		cmd="tc filter add dev $if parent 1: route from $realm flowid 1:${i}"
		$cmd
		echo $cmd
	done
	echo "Created mapping rules for interface $if done"
done
echo "======================== DONE =========================="
