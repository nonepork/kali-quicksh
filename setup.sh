#!/bin/bash

set -e

INSTALL_FONTS=false
REMOVE_XFCE=false

usage() {
  echo "Usage: $0 [OPTIONS]"
  echo "Options:"
  echo "--help               Show this help message"
  echo "--install-fonts      Install custom fonts (Iosevka and RobotoMono)"
  echo "--remove-xfce        Remove replaced XFCE components"
}

handle_options() {
  while [ $# -gt 0 ]; do
    case "$1" in
    --help)
      usage
      exit 0
      ;;
    --install-fonts)
      INSTALL_FONTS=true
      ;;
    --remove-xfce)
      REMOVE_XFCE=true
      ;;
    *)
      echo "Invawid option: $1" >&2
      usage
      exit 1
      ;;
    esac
    shift
  done
}

powerful_echo() {
  local type=$1
  local message=$2

  case $type in
  "info")
    echo -e "\n\e[1;36m┌─ INFO ─────────────────────────────────┐\e[0m"
    echo -e "\e[1;36m│\e[0m $message"
    echo -e "\e[1;36m└────────────────────────────────────────┘\e[0m\n"
    ;;
  "success")
    echo -e "\n\e[1;32m┌─ SUCCESS ──────────────────────────────┐\e[0m"
    echo -e "\e[1;32m│\e[0m $message"
    echo -e "\e[1;32m└────────────────────────────────────────┘\e[0m\n"
    ;;
  "error")
    echo -e "\n\e[1;31m┌─ ERROR ────────────────────────────────┐\e[0m"
    echo -e "\e[1;31m│\e[0m $message"
    echo -e "\e[1;31m└────────────────────────────────────────┘\e[0m\n"
    ;;
  "warning")
    echo -e "\n\e[1;33m┌─ WARNING ──────────────────────────────┐\e[0m"
    echo -e "\e[1;33m│\e[0m $message"
    echo -e "\e[1;33m└────────────────────────────────────────┘\e[0m\n"
    ;;
  esac
}

handle_options "$@"

# --- permission / environement check ---
if [ "$EUID" -ne 0 ]; then
  powerful_echo "error" "You nyeed to wun as woot (sudo ./setup.sh)"
  exit 1
fi

if ! grep -qi kali /etc/os-release; then
  powerful_echo "error" "This doesn't s-seem to be kawi winyux >w<"
  exit 1
fi

# get sudo user
USER_NAME="${SUDO_USER:-kali}"
USER_HOME=$(eval echo "~$USER_NAME")

clear
powerful_echo "info" "Wunnying as woot but configuwing fow user: $USER_NAME ($USER_HOME)"

# --- update n functions ---
apt update && apt upgrade -y

powerful_echo "info" "Installation starts, this may take a while, pwease wait >w<"

remove_xfce() {
  # INFO: This is bad, sorry.
  powerful_echo "warning" "Wemoving XFCE desktop meta packages and extras..."
  apt purge -y --allow-remove-essential kali-desktop-xfce kali-undercover qterminal mousepad
}

install_fonts() {
  powerful_echo "info" "Instawwing custom fonts..."
  FONT_DIR="$USER_HOME/.local/share/fonts"
  mkdir -p "$FONT_DIR"

  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Iosevka.zip -O /tmp/Iosevka.zip
  unzip -jo /tmp/Iosevka.zip "*.ttf" -d "$FONT_DIR"
  rm /tmp/Iosevka.zip

  wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/RobotoMono.zip -O /tmp/RobotoMono.zip
  unzip -jo /tmp/RobotoMono.zip "*.ttf" -d "$FONT_DIR"
  rm /tmp/RobotoMono.zip

  fc-cache -vf "$FONT_DIR"
}

# --- appearances ---
WALLPAPER_DIR="/usr/share/backgrounds"
WALLPAPER_PATH="$WALLPAPER_DIR/wallpaper.png"
wget -q https://raw.githubusercontent.com/nonepork/kali-quicksh/refs/heads/main/wallpaper.png -O "$WALLPAPER_PATH"
ln -sf $WALLPAPER_PATH /usr/share/desktop-base/kali-theme/login/background
# HACK: globally setting wallpaper for XFCE
sudo -u "$USER_NAME" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -n -t string -s "$WALLPAPER_PATH"
sudo -u "$USER_NAME" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor1/image-path -n -t string -s "$WALLPAPER_PATH"
sudo -u "$USER_NAME" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -n -t string -s "$WALLPAPER_PATH"
sudo -u "$USER_NAME" xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace1/last-image -n -t string -s "$WALLPAPER_PATH"

# wm/tools
apt remove -y vim
apt install -y i3 i3blocks feh imwheel seclists vim-gtk3 libreoffice libreoffice-gtk4 remmina ghidra gdb feroxbuster crackmapexec python3-pwntools alacritty tmux zoxide ripgrep subfinder ciphey steghide

sudo -u "$USER_NAME" pipx install git+https://github.com/brightio/penelope
sudo -u "$USER_NAME" pipx install search-that-hash

# --- configurating tools ---
mkdir -p "$USER_HOME/.config/i3/scripts"
mkdir -p "$USER_HOME/.config/alacritty"
mkdir -p "$USER_HOME/.config/tmux"
mkdir -p "$USER_HOME/.vim/undodir"

# fixing ownership and permissions
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/.config" "$USER_HOME/.vim"

# in case of pre existing config files, we will back them up
download_or_backup() {
  local file="$1"
  local url="$2"
  local dest="$USER_HOME/$file"

  if [ -f "$dest" ]; then
    powerful_echo "info" "Backing up existing $file to $file.bak >w<"
    mv "$dest" "$dest.bak"
  fi
  sudo -u "$USER_NAME" wget -q -O "$dest" "$url"
}

download_or_backup ".zshrc" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/.zshrc"
download_or_backup ".vimrc" "https://github.com/nonepork/configurations/raw/refs/heads/main/vim/_vimrc_quick"
download_or_backup ".config/tmux/tmux.conf" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/tmux/tmux.conf"
download_or_backup ".config/alacritty/alacritty.toml" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/alacritty/alacritty.toml"
download_or_backup ".config/i3/config" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/i3/config"
download_or_backup ".config/i3/blocks.conf" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/i3/blocks.conf"
download_or_backup ".config/i3/scripts/vpn-ip.sh" "https://github.com/nonepork/kali-quicksh/raw/refs/heads/main/config/i3/vpn-ip.sh"

chmod +x "$USER_HOME/.config/i3/scripts/vpn-ip.sh"

ALACRITTY_PATH=$(command -v alacritty)
if [ -z "$ALACRITTY_PATH" ]; then
  powerful_echo "warning" "I t-thought I instaww awacwitty?!?1"
else
  if ! update-alternatives --query x-terminal-emulator | grep -q "$ALACRITTY_PATH"; then
    update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$ALACRITTY_PATH" 50
  fi
  update-alternatives --set x-terminal-emulator "$ALACRITTY_PATH"
  powerful_echo "info" "Set alacritty as default tewminyaw"
fi

I3_PATH=$(command -v i3)
if [ -z "$I3_PATH" ]; then
  powerful_echo "warning" "I-I can't find i3!! Is it even instawwed? >_<"
else
  if ! update-alternatives --query x-session-manager | grep -q "$I3_PATH"; then
    update-alternatives --install /usr/bin/x-session-manager x-session-manager "$I3_PATH" 50
  fi
  update-alternatives --set x-session-manager "$I3_PATH"
  powerful_echo "info" "Set i3 as defauwt sesshion managew!"
fi

# --- removing unwanted stuff ---
# we are doing this lastly, otherwise it'll mess with WM and other configs
apt purge -y lxpolkit
if [ "$INSTALL_FONTS" = true ]; then
  install_fonts
fi
if [ "$REMOVE_XFCE" = true ]; then
  remove_xfce
fi

powerful_echo "success" "Setup compwete ^-^, remembew to weboot and waunch with i3"
powerful_echo "info" "If you installed fonts, remember to uncomment the font line in alacritty.toml and i3 config"
