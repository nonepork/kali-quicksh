#!/bin/bash

set -e

# --- permission / environement check ---
if [ "$EUID" -ne 0 ]; then
	echo "You nyeed to wun as woot (sudo ./setup.sh)"
	exit 1
fi

if ! grep -qi kali /etc/os-release; then
	echo "This doesn't s-seem to be kawi winyux >w<"
	exit 1
fi

echo "Wemoving XFCE desktop meta packages and extras..."
apt purge -y --allow-remove-essential kali-desktop-xfce kali-undercover qterminal mousepad
apt autoremove --purge -y
apt install -y thunar xfce4-screensaver lightdm lightdm-gtk-greeter # Just in case
