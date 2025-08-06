#!/bin/bash

set -e

# Permission / Environement check
if [ "$EUID" -ne 0 ]; then
  echo "You nyeed to wun as woot (sudo ./setup.sh)"
  exit 1
fi

if ! grep -qi kali /etc/os-release; then
  echo "This doesn't s-seem to be kawi winyux >w<"
  exit 1
fi

apt update && apt upgrade -y
