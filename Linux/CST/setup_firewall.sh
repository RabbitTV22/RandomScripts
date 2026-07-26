#!/bin/bash

# Create and deploy firewall rules for ssh
# made by Alec Lachance Lapalme
# 23/05/2026

#############
# Variables #
#############
CLIENT_SUBNET="172.16.31.0/24"
SERVER_SUBNET="172.16.30.0/24"
HOST_IP="172.16.0.1"
SERVER_ALIAS_NETWORK="172.16.32.0/24"


# Flush iptables
sudo iptables -F

# set the default policy to be permissive
sudo iptables -P INPUT REJECT
sudo iptables -P FORWARD REJECT
sudo iptables -P OUTPUT ACCEPT

echo "Applying firewall rules..."

# accept incoming ssh traffic for subnet users (172.16.31.0/24)
sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp --dport 22 -j ACCEPT

# allow ssh traffic from the host pc (used to ssh into vms)
sudo iptables -A INPUT -s $HOST_IP -p tcp --dport 22 -j ACCEPT

# deny incoming ssh traffic from all other users
sudo iptables -A INPUT -p tcp --dport 22 -j REJECT

# DNS
sudo iptables -A INPUT -s $CLIENT_SUBNET -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -s $SERVER_SUBNET -p udp --dport 53 -j REJECT
sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p udp --dport 53 -j REJECT
sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp --dport 53 -j ACCEPT
sudo iptables -A INPUT -s $SERVER_SUBNET -p tcp --dport 53 -j REJECT
sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p tcp --dport 53 -j REJECT

# HTTP and HTTPS
sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp -m multiport --dport 80,443 -j ACCEPT
sudo iptables -A INPUT -s $SERVER_SUBNET -p tcp -m multiport --dport 80,443 -j REJECT
sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p tcp -m multiport --dport 80,443 -j REJECT

# SMTP
sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp --dport 25 -j ACCEPT
sudo iptables -A INPUT -s $SERVER_SUBNET -p tcp --dport 25 -j REJECT
sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p tcp --dport 25 -j REJECT

# IMAP
sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp -m multiport --dport 143,993 -j ACCEPT
sudo iptables -A INPUT -s $SERVER_SUBNET -p tcp -m multiport --dport 143,993 -j REJECT
sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p tcp -m multiport --dport 143,993 -j REJECT

# LDAP
#sudo iptables -A INPUT -s $CLIENT_SUBNET -p tcp --dport 389 -j ACCEPT
#sudo iptables -A INPUT -s $SERVER_ALIAS_NETWORK -p tcp --dport 389 -j REJECT
#sudo iptables -A INPUT -s $SERVER_SUBNET -p tcp --dport 389 -j REJECT

echo "Done applying rules"


echo
echo
echo


sudo iptables -L -n --line-numbers
