#!/bin/bash

# This script will install and configure postfix
# Made by Alec Lachance Lapalme
# 03/07/2026


# check if postfix is installed and if not, install it
if [[ $(rpm -q postfix 2> /dev/null) =~ .*not.* ]]; then
        echo "Installing postfix"
        sudo dnf install -y mailx sendmail postfix
else 
        echo "Postfix already installed"
fi

#############
# Variables #
#############

SERVER_SUBNET="172.16.30.0/24"
SERVER_ALIAS_SUBNET="172.16.32.0/24"
CLIENT_SUBNET="172.16.31.0/24"
CONFIG_FILE="/etc/postfix/main.cf"
DOMAIN="blue.lab"

ALIAS_USER="labfinal"
ALIAS_TO="foo"

if [ -f "$CONFIG_FILE.bak" ]; then 
        echo There is already a backup.
else
        cp "$CONFIG_FILE" "$CONFIG_FILE.bak"
fi



read -p "Do you want the script to do the configuration on $CONFIG_FILE?: " DO_CONFIG

if [[ $DO_CONFIG =~ ^[Yy]$ ]]; then
        sed -i "s/#myhostname = host.domain.tld/myhostname = mail.$DOMAIN/" $CONFIG_FILE
        sed -i "s/#mydomain = domain.tld/mydomain = $DOMAIN/" $CONFIG_FILE
        sed -i "s/#myorigin = \$mydomain/myorigin = \$mydomain/" $CONFIG_FILE
        sed -i "s/inet_interfaces = localhost/inet_interfaces = all/" $CONFIG_FILE
        sed -i "s/mydestination = \$myhostname, localhost.\$mydomain, localhost/mydestination = \$myhostname, localhost.\$mydomain, localhost, \$mydomain/" $CONFIG_FILE
        sed -i "s|#mynetworks = 168.100.189.0/28, 127.0.0.0/8|mynetworks = 172.16.0.0/16, 127.0.0.0/8|" $CONFIG_FILE
        sed -i "s/# ADDRESS REDIRECTION (VIRTUAL DOMAIN)/masquerade_domains = $DOMAIN/" $CONFIG_FILE
        sed -i "s|#home_mailbox = Maildir/|home_mailbox = Maildir/|" $CONFIG_FILE
	echo Postfix configured succesfully.

fi

if [[ $(cat /etc/aliases) =~ .*${ALIAS_USER}.* ]]; then
	echo Alias already in /etc/aliases
else
        echo "$ALIAS_USER: $ALIAS_TO" >> /etc/aliases
        postalias /etc/aliases
fi

echo
systemctl enable --now postfix
systemctl restart postfix
echo Postfix service restarted.

