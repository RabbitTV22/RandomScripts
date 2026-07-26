#!/bin/bash

# This script will install and configure named
# Made by Alec Lachance Lapalme
# 25/07/2026


# check if ssh is installed and if not, install it
if [[ $(rpm -q bind 2> /dev/null) =~ .*not.* ]]; then
	echo "Installing named"
        sudo dnf install -y bind bind-utils
else 
	echo "Named already installed"
fi

#############
# Variables #
#############

SERVER_SUBNET="172.16.30.0/24"
SERVER_ALIAS_SUBNET="172.16.32.0/24"
CLIENT_SUBNET="172.16.31.0/24"
SERVER_IP="172.16.30.12"
CLIENT_IP="172.16.31.12"

ZONE_ROOT="blue.lab"
SERVER_NS_RECORD="dns1"

cp /etc/named.conf /etc/named.conf.bak

if [[ $(cat /etc/named.conf) =~ .*172\.16\..* ]]; then
	echo named.conf already configured.
else
	sed -i "s|127.0.0.1;|127.0.0.1; ${SERVER_IP};|" /etc/named.conf
	sed -i "s|localhost;|localhost; ${SERVER_SUBNET}; ${SERVER_ALIAS_SUBNET}; ${CLIENT_SUBNET};|" /etc/named.conf
	echo named.conf configured succesfully.
fi



if [[ $(cat /etc/named.conf) =~ .*${ZONE_ROOT}.* ]]; then
	echo Zone already exists. Skipping...
else
	cat >> /etc/named.conf <<EOF
zone "$ZONE_ROOT" IN {
       	type master;
       	file "/etc/named/fwd.$ZONE_ROOT";
       	allow-transfer { $CLIENT_IP; };
};
EOF
	echo Zone configured succesfully.
fi



if [[ $(cat /etc/named.conf) =~ .*in-addr.* ]]; then
	echo Reverse zone already exists. Skipping...
else
	cat >> /etc/named.conf <<EOF
zone "16.172.in-addr.arpa" IN {
       	type master;
       	file "/etc/named/reverse.16.172";
       	allow-transfer { $CLIENT_IP; };
};
EOF
	echo Reverse zone configured succesfully.
fi


if [ ! -f /etc/named/reverse.16.172 ]; then

echo "\$TTL 86400

\$ORIGIN 16.172.in-addr.arpa.

@ IN SOA $SERVER_NS_RECORD.$ZONE_ROOT. root.$ZONE_ROOT. (
        2000122401 ; Serial Number (use date + revision)
        28800 ; Refresh (8h)
        14400 ; Retry (4h)
        604800 ; Expire (1w)
        10800 ; Minimum TTL (3h)
)


@ IN NS $SERVER_NS_RECORD.$ZONE_ROOT." > /etc/named/reverse.16.172
fi


if [ ! -f /etc/named/fwd.$ZONE_ROOT ]; then

echo "\$TTL 86400

\$ORIGIN $ZONE_ROOT.

@ IN SOA $SERVER_NS_RECORD.$ZONE_ROOT. dnsadm.$ZONE_ROOT. (
        2000122401 ; Serial Number (use date + revision)
        28800 ; Refresh (8h)
        14400 ; Retry (4h)
        604800 ; Expire (1w)
        10800 ; Minimum TTL (3h)
)


$ZONE_ROOT. IN NS $SERVER_NS_RECORD.$ZONE_ROOT.

$SERVER_NS_RECORD IN A $SERVER_IP" > /etc/named/fwd.$ZONE_ROOT
fi

ADD_RECORD="Y"

while [ $ADD_RECORD != "N" ]; do

	read -p "What type of record do you want to add? [A, MX, PTR]: " RECORD_TYPE

	if [ $RECORD_TYPE == "MX" ]; then
		read -p "What subdomain do you want? (@ for root): " SUBDOMAIN
		read -p "What FQDN do you want this record to point to?: " IP

		echo "$SUBDOMAIN IN MX 10 $IP." >> /etc/named/fwd.$ZONE_ROOT
	elif [ $RECORD_TYPE != "PTR" ]; then

		read -p "What subdomain do you want?: " SUBDOMAIN
		read -p "What ip do you want this record to point to?: " IP

		echo "$SUBDOMAIN IN $RECORD_TYPE $IP" >> /etc/named/fwd.$ZONE_ROOT

	else
		read -p "Enter the last 2 octets of the ip you want to add in reverse: " OCTETS
		read -p "Enter the FQDN that you want this ip to point to: " FQDN

		echo "$OCTETS IN PTR $FQDN." >> /etc/named/reverse.16.172
	fi
	read -p "Add more records? [Y/N]: " ADD_RECORD
done


echo Zone files configured succesfully.


echo "search localdomain $ZONE_ROOT
nameserver $SERVER_IP
" > /etc/resolv.conf

systemctl enable --now named
systemctl restart named
echo Named service restarted.

echo Configured resolv.conf succesfully.
