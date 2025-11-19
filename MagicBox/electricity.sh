#!/bin/bash

read -p "Enter the count: " unit
price=0

if [ $unit -lt 51 ]; then
    echo "The price is $"$unit
elif [ $unit -lt 151 ]; then
    let price=(unit-50)*2+50
    echo "The price is $"$price
elif [ $unit -gt 150 ]; then
    let price=(unit-150)*3+250
    echo "The price is $"$price
fi