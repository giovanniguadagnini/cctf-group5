#!/bin/bash

# Develop monitoring at the server that will let you automatically check 
# the content of HTTP requests you are getting and who is sending them.

#Get the right eth to monitor
SERVER_NET="10.1.5"
ETH=$(ip a | grep $SERVER_NET | tail -c 5)
TIME=10

if [ $# -eq 1 ];
then 
    TIME=$1
    sudo timeout $TIME tcpflow -p -c -i $ETH "dst 10.1.5.2 and port 80"
else
    sudo tcpflow -p -c -i $ETH "dst 10.1.5.2 and port 80"
fi
