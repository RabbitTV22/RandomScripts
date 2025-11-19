#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

if [ $logged_in -eq 1 ]; then
    clear
    read -p "Enter the first number: " first
    read -p "Enter the operation (+ - * / ^): " operation
    read -p "Enter the second number: " second
    if [ "$operation" = "^" ]; then
        counter=0
        sum=1
        while [ "$counter" -lt "$second" ]; do
            sum=$(( sum * first ))
            ((counter++))
        done
        echo
        echo "$first to the power of $second is $sum"
        echo
        read -p "Press Enter to return to main menu..."
        bash $main_menu
    elif [ "$operation" = "+" ] || [ "$operation" = "-" ] || [ "$operation" = "*" ] || [ "$operation" = "/" ]; then
        sum=$(echo "$first $operation $second" | bc -l)
        echo
        echo "$first $operation $second is equal to $sum"
        echo
        read -p "Press Enter to return to main menu..."
        bash $main_menu
    else  
        echo "You entered an invalid input."
        read -p "Press Enter to return to main menu..."
        bash $main_menu
    fi
fi
