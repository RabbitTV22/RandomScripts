#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

if [ $logged_in -eq 1 ]; then
    clear
    echo "************** System Info *****************"
    echo 
    echo "Hostname:" $(hostname)
    echo "Username:" $USER
    echo "Linux Distro:" $(lsb_release -a | grep "Description:" | awk '{print $2, $3, $4, $5, $6, $7, $8, $9, $10}')
    echo "Kernel Version:" $(cat /proc/version | awk '{print $3}')
    echo "IPv4 Address:" $(nmcli | grep "inet4" | awk '{print $2}' | head -1)
    echo "IPv6 Address:" $(nmcli | grep "inet6" | awk '{print $2}' | head -1)
    echo "DNS Server(s):" $(nmcli | grep "servers" | awk '{print $2}')
    echo "MAC Address:" $(nmcli | grep "ethernet" | awk '{print $3}')
    echo "Default Gateway:" $(nmcli | grep "route4" | awk '{print $4}' | tail -1)
    echo
    read -p "Press Enter to return to main menu..."
    bash $main_menu
fi
