#!/bin/bash

echo "Update package cache..."
dnf check-update

echo "Upgrade packages..."
sudo dnf upgrade

echo "Install Brew..."
# https://brew.sh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"