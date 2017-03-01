#!/bin/bash
# constants
SUBNET_MAX_CIDR=32

# configurations
ip_base=192.168.2.0
subnet_cidr=27
subnet_num=8


# auxiliar variables
subnet_range=$(($SUBNET_MAX_CIDR - $subnet_cidr))

# auxiliar functions
# ip2dec
# converts an IP as a string to an integer
ip2dec () {
    local a b c d ip=$@
    IFS=. read -r a b c d <<< "$ip"
    printf '%d\n' "$((a * 256 ** 3 + b * 256 ** 2 + c * 256 + d))"
}
# dec2ip
# converts an IP as an integer to a dotted quad string
dec2ip () {
    local ip dec=$@
    for e in {3..0}
    do
        ((octet = dec / (256 ** e) ))
        ((dec -= octet * 256 ** e))
        ip+=$delim$octet
        delim=.
    done
    printf '%s\n' "$ip"
}

# loop and masquerade
ip=$ip_base
for i in `seq 1 $subnet_num`
do
	# add rule
	iptables -t nat -A POSTROUTING --source $ip/$subnet_cidr -j MASQUERADE
	echo "Afegint xarxa $ip/$subnet_cidr a les regles d'emmascarament"
	# next ip
	ip=$(ip2dec $ip_base)
	ip=$(($ip + $(echo "$i*2^${subnet_range}" | bc)))
	ip=$(dec2ip $ip)
done

