#!/bin/bash
networks=( 192.168.2.33/27 192.168.2.65/27 192.168.2.97/27 192.168.2.129/27 192.168.2.161/27 192.168.2.193/27 192.168.2.225/27 )

for if in `seq 2 8`; do
	ip address add ${networks[$(($if - 2))]} dev eth${if} scope link
done