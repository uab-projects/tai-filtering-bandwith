#!/bin/bash
interfaces=( eth0 eth1 )
bands_per_interface=8
for if in "${interfaces[@]}"; do
	tc qdisc change dev $if root handle 1: prio bands $bands_per_interface priomap 0 2 2 2 1 2 0 0 1 1 1 1 1 1 1 1
done