#!/bin/bash

set -e

# permission / environement check
if [ "$EUID" -ne 0 ]; then
  echo "You nyeed to wun as woot (sudo ./setup.sh)"
  exit 1
fi

if ! grep -qi kali /etc/os-release; then
  echo "This doesn't s-seem to be kawi winyux >w<"
  exit 1
fi

apt update && apt upgrade -y

# appearances
WALLPAPER_PATH="/home/kali/Pictures/wallpaper/wallpaper.png"
mkdir -p ~/Pictures/wallpaper/
wget https://raw.githubusercontent.com/nonepork/kali-quicksh/refs/heads/main/wallpaper.png -O $WALLPAPER_PATH

# wm/tools
apt remove -y vim mousepad
apt install -y i3 feh imwheel seclists vim-gtk3 libreoffice libreoffice-gtk4 remmina ghidra gdb feroxbuster crackmapexec python3-pwntools alacritty tmux zoxide
pipx install git+https://github.com/brightio/penelope

# configurating tools
mkdir -p /home/kali/.config/i3
mkdir -p /home/kali/.config/i3/scripts
mkdir -p /home/kali/.config/alacritty
mkdir -p /home/kali/.vim/undodir
