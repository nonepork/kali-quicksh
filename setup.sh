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

# get sudo user
USER_NAME="${SUDO_USER:-kali}"
USER_HOME=$(eval echo "~$USER_NAME")

echo "Wunnying as woot but configuwing fow user: $USER_NAME ($USER_HOME)"

apt update && apt upgrade -y

# appearances
WALLPAPER_DIR="$USER_HOME/Pictures/wallpaper"
WALLPAPER_PATH="$WALLPAPER_DIR/wallpaper.png"
mkdir -p "$WALLPAPER_DIR"
wget -q https://raw.githubusercontent.com/nonepork/kali-quicksh/refs/heads/main/wallpaper.png -O "$WALLPAPER_PATH"
chown -R "$USER_NAME":"$USER_NAME" "$WALLPAPER_DIR"

# wm/tools
apt remove -y vim mousepad
apt install -y i3 i3blocks feh imwheel seclists vim-gtk3 libreoffice libreoffice-gtk4 remmina ghidra gdb feroxbuster crackmapexec python3-pwntools alacritty tmux zoxide

if ! sudo -u "$USER_NAME" pipx list | grep -q penelope; then
  sudo -u "$USER_NAME" pipx install git+https://github.com/brightio/penelope
fi

# configurating tools
mkdir -p "$USER_HOME/.config/i3/scripts"
mkdir -p "$USER_HOME/.config/alacritty"
mkdir -p "$USER_HOME/.config/tmux"
mkdir -p "$USER_HOME/.vim/undodir"

# in case of pre existing config files, we will back them up
download_or_backup() {
  local file="$1"
  local url="$2"
  local dest="$USER_HOME/$file"

  if [ -f "$dest" ]; then
    echo "Backing up existing $file to $file.bak"
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

# fixing ownership and permissions
chown -R "$USER_NAME":"$USER_NAME" "$USER_HOME/.config" "$USER_HOME/.vim"

echo "Setup compwete ^-^. remembew to wewoad youw i3 config westawt session."
