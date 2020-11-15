#!/bin/bash

TIME=10
if [ $# -eq 1 ];
then
    TIME=$1
fi

while :
do
sudo python client_stats.py $TIME 
sleep 1
sudo python packet_stats.py $TIME
sleep $TIME + 5
rm -rf *.txt.old
echo "--------------------------------------------"
done