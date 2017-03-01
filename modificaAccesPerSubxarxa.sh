#!/bin/bash
#========================================================================
# SCRIPT CONSTANTS
#========================================================================
ACCEPT_STRING="activar"
DENY_STRING="desactivar"

#========================================================================
# RULE NUMBER IDENTIFICATION
#========================================================================
function getRuleByNet {
	local line_num
	line_num=$(iptables -t nat -L POSTROUTING | grep -n "$1" | cut -f1 -d:)
	if [ "$line_num" == "" ]; then
		echo ""
	else
		line_num=$(($line_num - 2))
		echo $line_num
	fi
}
rule=$(getRuleByNet "$2")

#========================================================================
# DENY / ACCEPT INTERNET ACCESS
#========================================================================
if [ "$1" = "$DENY_STRING" ]; then
	if [ "$rule" == "" ]; then
		echo "Error: network does not exist to deny access ($2)"
	else
		iptables -t nat -D POSTROUTING $rule
		echo "Network $2 denied succesfully"
	fi
elif [ "$1" = "$ACCEPT_STRING" ]; then
	if [ "$rule" == "" ]; then
		iptables -t nat -A POSTROUTING --source "$2" -j MASQUERADE
		echo "Network $2 allowed successfully"
	else
		echo "Error: network is already allowed($2, rule $rule)"
	fi
else
	echo "Error: parameter invalid ($2). Accepted params: $ACCEPT_STRING / $DENY_STRING"
fi

