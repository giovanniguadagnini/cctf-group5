#!/bin/bash

USER="marco"
PASS="polo"

if [ $# -eq 0 ] || [ $# -gt 2 ];
then
    echo "Usage ./monitor_server.sh <modality> <n_requests>(not mandatory)"
    echo "1) Use the requests to insert a lot of records. "
    echo "2) Keep requesting for the balance (can slow down if the adversary have not modified the php page). "
    exit 1
fi

#Check if the user setted the number of requests, in case assign the value
if [ "$1" == "1" ];
then 
curl -sS '10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register'
COUNT=1
while true
do
    curl -sS '10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=10' &
    sleep 1
    curl -sS '10.1.5.2/process.php?user=$USER&pass=$PASS&drop=withdraw&amount=10' &
    sleep 1
    COUNT=$((COUNT+2))
    echo "$COUNT operation requested"
done

fi

if [ "$1" == "2" ];
then 

while true
do
    curl -sS '10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance' &
    sleep 1
done
fi