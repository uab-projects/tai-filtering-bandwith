#!/bin/bash
# CONFIGURATIONS
interfaces=( eth0 eth1 )
networks=( 192.168.2.0/27 192.168.2.32/27 192.168.2.64/27 192.168.2.96/27 192.168.2.128/27 192.168.2.160/27 192.168.2.192/27 192.168.2.224/27 )
bands_per_interface=8
mark_start=10
mark_increment=10

echo "=================== MARK CLASSIFYING ==================="
echo "Classifying networks with iptables (mark_start=$mark_start,mark_increment=$mark_increment)"
iptables -t mangle -F
iptables -t mangle -X
mark=$mark_start
for network in "${networks[@]}"; do
	cmd="iptables -t mangle -A PREROUTING -s $network -j MARK --set-mark $mark"
	mark=$(($mark + $mark_increment))
	echo $cmd
	$cmd
done
echo "==================== TC FILTERING ======================"
echo "Creating mapping rules using previous classification"

for if in "${interfaces[@]}"; do
	echo "------------------------------------------------"
	echo " INTERFACE $if"
	echo "------------------------------------------------"	
	tc filter show dev $if | awk -F "pref " '{print $2}' | cut -d " " -f 1 |\
	sort -u | while read -r pref; do
		cmd="tc filter del dev $if pref $pref"
		$cmd
	done
	mark=$mark_start
	cmd="tc filter add dev $if parent 1: handle $mark fw flowid 1:1"
	echo $cmd
	for i in `seq 2 $bands_per_interface`; do
		mark=$(($mark + $mark_increment))
		cmd="tc filter add dev $if parent 1: handle $mark fw flowid 1:${i}"
		echo $cmd
		$cmd
	done
	echo "Created mapping rules for interface $if done"
done
echo "======================== DONE ==========================="
