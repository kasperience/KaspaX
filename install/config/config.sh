#!/bin/bash

# Copy over Kaspa Linux configs
cp -R ~/.local/share/kaspa-linux/config/* ~/.config/

# Use default bashrc from Kaspa Linux
cp ~/.local/share/kaspa-linux/default/bashrc ~/.bashrc

# Ensure application directory exists for update-desktop-database
mkdir -p ~/.local/share/applications

# If bare install, allow a way for its exclusions to not get added in updates
if [ -n "$KASPA_LINUX_BARE" ]; then
  mkdir -p ~/.local/state/kaspa-linux
  touch ~/.local/state/kaspa-linux/bare.mode
fi

# Setup GPG configuration with multiple keyservers for better reliability
sudo mkdir -p /etc/gnupg
sudo cp ~/.local/share/kaspa-linux/default/gpg/dirmngr.conf /etc/gnupg/
sudo chmod 644 /etc/gnupg/dirmngr.conf
sudo gpgconf --kill dirmngr || true
sudo gpgconf --launch dirmngr || true

# Increase lockout limit to 10 and decrease timeout to 2 minutes
sudo sed -i 's|^\(auth\s\+required\s\+pam_faillock.so\)\s\+preauth.*$|\1 preauth silent deny=10 unlock_time=120|' "/etc/pam.d/system-auth"
sudo sed -i 's|^\(auth\s\+\[default=die\]\s\+pam_faillock.so\)\s\+authfail.*$|\1 authfail deny=10 unlock_time=120|' "/etc/pam.d/system-auth"

# Set common git aliases
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global pull.rebase true
git config --global init.defaultBranch master

# Set identification from install inputs
if [[ -n "${KASPA_LINUX_USER_NAME//[[:space:]]/}" ]]; then
  git config --global user.name "$KASPA_LINUX_USER_NAME"
fi

if [[ -n "${KASPA_LINUX_USER_EMAIL//[[:space:]]/}" ]]; then
  git config --global user.email "$KASPA_LINUX_USER_EMAIL"
fi

# Set default XCompose that is triggered with CapsLock
tee ~/.XCompose >/dev/null <<EOF
include "%H/.local/share/kaspa-linux/default/xcompose"

# Identification
<Multi_key> <space> <n> : "$KASPA_LINUX_USER_NAME"
<Multi_key> <space> <e> : "$KASPA_LINUX_USER_EMAIL"
EOF
