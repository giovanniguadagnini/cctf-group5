#!/bin/bash

USER="marco"
PASS="polo"
MAX_REQUEST=100

if [ $# -eq 0 ] || [ $# -gt 2 ];
then
    echo "Usage ./monitor_server.sh <modality> <n_requests> (not mandatory for 2)"
    echo "1) Use the requests to insert a lot of records. "
    echo "2) Keep requesting for the balance (can slow down if the adversary have not modified the php page). "
    exit 1
fi

if [ $# -eq 2 ];
then
    MAX_REQUEST=$2
fi

# Check if the user setted the number of requests, in case assign the value
if [ "$1" == "1" ];
then 
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register"
COUNT=1
while true
do
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=2147483647" &
    sleep 1
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=withdraw&amount=2147483647" &
    sleep 1
    COUNT=$((COUNT+2))
    echo "$COUNT operation requested"
done

fi

if [ "$1" == "2" ];
then 
COUNT=1
while true
do
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance" & 
    COUNT=$((COUNT+1))
    echo "$COUNT operation balance requested"
    if [ $COUNT -eq $MAX_REQUEST ];
    then
        break
    fi
done
fi