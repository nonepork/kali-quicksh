#!/bin/bash

VPN_IF="tun0"
IP=$(ip -4 addr show "$VPN_IF" 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')

if [ -n "$IP" ]; then
	echo "$IP"
else
	echo "Disconnected"
fi
