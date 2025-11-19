#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

function return_menu() {
    read -p "Press Enter to return to main menu..."
    bash $main_menu
}

package_manager=0

if command -v apt-get >/dev/null 2>&1; then
    package_manager="apt-get"
elif command -v dnf >/dev/null 2>&1; then
    package_manager="dnf"
elif command -v pacman >/dev/null 2>&1; then
    package_manager="pacman"
fi


if [ "$logged_in" -eq 1 ]; then
    clear
    case $package_manager in
    apt-get)
        echo "Please put in your password to install the required packages."
        sudo apt-get install btop htop nmap
        return_menu
        ;;
    dnf)
        sudo dnf install btop htop nmap
        echo "Please put in your password to install the required packages."
        return_menu
        ;;
    pacman)
        sudo pacman -S top btop htop nmap
        echo "Please put in your password to install the required packages."
        return_menu
        ;;
    *)
        echo "Your system is not Debian, Red-hat, or Arch based. Dependencies will not install on your system."
        return_menu
    esac
fi
