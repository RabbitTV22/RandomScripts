#!/bin/bash

apt update -y

apt upgrade -y

#useradd -m alec

clear

#passwd alec

apt install git sudo curl vim -y

echo "alec    ALL=(ALL:ALL) ALL" > /etc/sudoers.d/alec

int=$(ls /sys/class/net | grep en)

clear

read -p "What IP do you want to set? Type \"0\" to keep using DHCP: " addr

if [ "$addr" != "0" ]; then

read -p "What netmask will you use? (ie. 255.255.255.0): " mask

read -p "What default gateway will you use?: " gateway

sed -i "s/iface $int inet dhcp//" /etc/network/interfaces

cat >> /etc/network/interfaces <<EOF
iface $int inet static
        address $addr
        netmask $mask
        gateway $gateway
        dns-nameservers 9.9.9.9

EOF

systemctl restart networking

fi
echo "nameserver 9.9.9.9" > /etc/resolv.conf
