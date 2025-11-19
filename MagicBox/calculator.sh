#!/bin/bash

logged_in=$(cat "/home/$USER/.cache/MagicBox/login")
main_menu=$(cat "/home/$USER/.cache/MagicBox/path")

if [ $logged_in -eq 1 ]; then
    clear
    read -p "Enter the first number: " first
    read -p "Enter the operation (+ - * / ^): " operation
    read -p "Enter the second number: " second
    if [ $operation == "^" ]; then
        counter=1
        sum=1
        while [ $counter -lt $second ]; do
            sum=$(( sum * first ))
            ((counter++))
        done
        echo $sum
    elif [ $operation == "+" ] || [ $operation == "-" ] || [ $operation == "*" ] || [ $operation == "/" ]; then
        sum=$(echo "$first $operation $second" | bc -l)
        echo $sum
    fi
fi
