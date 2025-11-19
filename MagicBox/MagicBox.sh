#!/bin/bash

exec_path=$(realpath $0)
mkdir -p /home/$USER/.cache/MagicBox/
first_run=/home/$USER/.cache/MagicBox/first_run

if [ ! -f $first_run ] || [ $(cat $first_run) -ne 1 ]; then
    mkdir -p /home/$USER/.MagicBox
    wget -O /home/$USER/.MagicBox/dependencies.sh https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/MagicBox/dependencies.sh
    wget -O /home/$USER/.MagicBox/sysinfo.sh https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/MagicBox/sysinfo.sh
    wget -O /home/$USER/.MagicBox/inum.sh https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/MagicBox/inum.sh
    wget -O /home/$USER/.MagicBox/nmap.sh https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/MagicBox/nmap.sh
    wget -O /home/$USER/.MagicBox/calculator.sh https://raw.githubusercontent.com/RabbitTV22/RandomScripts/refs/heads/main/MagicBox/calculator.sh
    echo 1 > /home/$USER/.cache/MagicBox/first_run
fi
rm /home/$USER/.cache/MagicBox/path
echo $exec_path > /home/$USER/.cache/MagicBox/path


declare -A users

users=(
    ["alec"]="2222"
    ["user1"]="1234"
    ["tim"]="jim"
)

function welcome() {
    if [ $logged_in -eq 1 ]; then 
        mkdir -p /home/$USER/.cache/MagicBox/
        echo $logged_in > /home/$USER/.cache/MagicBox/login
        echo "*************************************"
        echo "Welcome to the Magic Box!"
        echo "Type the number corresponding to"
        echo "what you want to do."
        echo ""
        echo "1 - Install dependencies"
        echo "2 - Check system info"
        echo "3 - Check processes"
        echo "4 - Check current date"
        echo "5 - Clear the screen"
        echo "6 - Check inode number of a file"
        echo "7 - IP scanner"
        echo "8 - Simple calculator"
        echo "9 - Log Out (quit)"
        echo ""
        read -p "Enter your choice: " input
        echo $input > /home/$USER/.cache/MagicBox/choice
        choice
    fi
}

function choice() {
case $input in 
    1)
        bash /home/$USER/.MagicBox/dependencies.sh
        ;;
    2)
        bash /home/$USER/.MagicBox/sysinfo.sh
        ;;
    3)
        echo "Which top program to use?"
        echo "1 - top (default)"
        echo "2 - htop"
        echo "3 - btop"
        read top
        case $top in 
        2)
            htop
            ;;
        3) 
            btop
            ;;
        *)
            top
            ;;
        esac
        clear
        welcome
        ;;
    4)
        echo ""
        echo "The date today is:" $(date)
        echo ""
        read -p "Press Enter to return to main menu..."
        clear
        welcome
        ;;
    5)
        clear
        read -p "Enter your choice: " input
        choice
        ;;
    6)
        bash /home/$USER/.MagicBox/inum.sh
        ;;
    7)
        bash /home/$USER/.MagicBox/nmap.sh
        ;;
    8)
        bash /home/$USER/.MagicBox/calculator.sh
        ;;
    9)
        echo 0 > /home/$USER/.cache/MagicBox/login
        echo "*************************************"
        exit
        ;;
    *)
        clear
        echo "Invalid input. Try again."
        welcome
esac
}

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")

clear
if [ "$logged_in" = 1 ]; then
    welcome
else
    echo "*************************************"
    read -p "Enter your username: " username
    read -s -p "Enter your password: " password
    echo
    if [[ -v users["$username"] ]]; then
        if [[ "${users[$username]}" == "$password" ]]; then
            echo "Successfully logged in!"
            logged_in=1
            welcome
        else
            echo "Wrong username or password." #wrong pass
            echo "*************************************"
        fi
    else
        echo "Wrong username or password." #wrong user
        echo "*************************************"
    fi
fi
