#!/bin/bash

sudo tcpdump -i $(ip a | grep 10.1.1.3 | tail -c 5) -nn "tcp[tcpflags] & (tcp-syn) != 0"