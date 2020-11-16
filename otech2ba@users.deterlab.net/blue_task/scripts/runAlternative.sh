#!/bin/bash

ETH=$(ip a | grep 10.1.5.2 | tail -c 5)
sudo python alternative_packets_stats.py -i $ETH
