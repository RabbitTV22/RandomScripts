#!/bin/bash

# This script will install and configure ssh
# Made by Alec Lachance Lapalme
# 23/05/2026


# check if ssh is installed and if not, install it
if [[ $(rpm -q openssh 2> /dev/null) =~ .*not.* ]]; then
	echo "Installing SSH"
        sudo dnf install -y openssh-server openssh-clients
else 
	echo "SSH already installed"
fi

#############
# Variables #
#############

PASS_USER="lab"
KEY_USER="foo"

# Create key user
id $KEY_USER &>/dev/null || useradd -m $KEY_USER

passwd $KEY_USER

if [[ $(cat /etc/ssh/sshd_config) =~ .*AllowUsers.* ]]; then
	echo sshd already has allow users
else
	echo "AllowUsers admin root alec" >> /etc/ssh/sshd_config
fi


# enable key based auth
sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
echo Enabled pubkey auth

# restart sshd
systemctl restart sshd
echo SSH daemon restarted.


