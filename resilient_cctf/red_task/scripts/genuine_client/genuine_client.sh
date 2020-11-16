#!/bin/bash

N=1
TIME=10
SERVER=10.1.5.2

while true
do
   curl -s $SERVER/$((1 + $RANDOM % 10)).html & #> /dev/null &
   echo "[script] sent request $N"

   #Check if the rate file exists (it should be present if we are doing an attack)
   if [ -f "rate.txt" ]; then
      T=$(head -n 1 rate.txt)
      sleep $T
      echo "[script] stopped for $T sec"
   else
      #Send less packet possible until an attack is in place
      sleep $TIME 
      echo "[script] stopped for $TIME sec"
   fi

   N=$(($N+1))
   echo "---------------------------------------------"
done