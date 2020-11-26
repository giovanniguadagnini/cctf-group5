#!/bin/bash

# Develop monitoring software on the gateway machine that will 
# let you automatically check if server is getting slow.

#Variables
REQUESTS=5
SERVER=10.1.5.2

if [ $# -eq 0 ] || [ $# -gt 2 ];
then
    echo "Usage ./monitor_server.sh <modality> <n_requests>(not mandatory)"
    echo "1) Simple ping test. "
    echo "2) Simulate genuine requests. "
    echo "3) Both test. "
    exit 1
fi

#Check if the user setted the number of requests, in case assign the value
if [ $# -eq 2 ];
then 
REQUESTS=$2
fi

while true 
do
if [ "$1" == "1" ] || [ "$1" == "3" ];
then
echo "Start ping test (press ^C to interrupt)"
sudo ping -i 0.1 $SERVER -c $REQUESTS
fi

if [ "$1" == "2" ] || [ "$1" == "3" ];
then
echo "Start http server test"
for ((i=0; i<$REQUESTS; i++))
do
curl -w "time_total: %{time_total}s\n" -o /dev/null -s $SERVER/1.html 
done
fi

sleep 5

done