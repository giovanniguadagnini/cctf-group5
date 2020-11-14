#!/bin/bash

N=1
TIME=1

if [ "$#" -eq 1 ];then
   TIME=$1
fi

while true
do
   curl -s 10.1.5.2/$((1 + $RANDOM % 10)).html > /dev/null &
   echo "sent request $N"
   sleep $TIME #Change in the different phases in order to give less points to defenders? 
   N=$(($N+1))
done