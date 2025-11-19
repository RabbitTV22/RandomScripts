#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

function return_menu() {
    read -p "Press Enter to return to main menu..."
    bash $main_menu
}

function manual() {
    read -p "Enter the host to scan (can only scan /24). Or enter a single IP " ip
    if [[ "$ip" == *.0 ]]; then
        for i in {1..255}; do
            network=${ip%.*}
            address=$network.$i
            echo "Scanning $address"
            if ping -c 1 -W 1 $address &>/dev/null; then
                echo "Host $address is UP"
            else 
                echo "Host $address is DOWN"
            fi
        done
        return_menu
    else
        if ping -c 1 -W 1 $ip &>/dev/null; then
            echo
            echo "Host $ip is UP"
            echo
        else
            echo
            echo "Host $ip is DOWN"
            echo
        fi
    fi
}

function nmap() {
    read -p "Enter the host to scan (ex. 192.168.1.0/24). Or enter a single IP " ip
    echo
    sudo nmap -sn $ip
    echo
    return_menu
}

if [ $logged_in -eq 1 ]; then
clear
    echo "How do you want to scan?"
    echo "1 - nmap (default)"
    echo "2 - Manual"
    read scan
    if [ $scan -eq 2 ]; then
        manual
    else    
        nmap
    fi
        return_menu
fi
