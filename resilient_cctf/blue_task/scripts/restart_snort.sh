#!/bin/bash

sudo pkill snort 1>/dev/null 
echo "snort process killed"
sudo snort --daq nfq -Q -c /home/cctf/snort/snort.conf -l /home/cctf/snort/alerts -D 
echo "snort process started"
ps aux | grep snort
