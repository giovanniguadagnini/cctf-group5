#!/bin/bash

###############################
# Author: Piva Davide         #
###############################

sudo iptables -F
sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -d 10.1.5.2 -j DROP