#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

if [ $logged_in -eq 1 ]; then
clear
read -p "Enter the path of the file you want to check for the inode number: " file
if [ -f $file ]; then 
    inode=$(ls -i $file | awk '{print $1}')
    echo "The inode number of file $file is" $inode
    read -p "Press Enter to return to main menu..."
    bash $main_menu
else 
    read -p "The file path provided is invalid. Press Enter to return to main menu..."
    bash $main_menu
fi
fi
