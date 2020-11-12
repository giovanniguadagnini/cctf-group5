#!/bin/bash

while true
do
   curl -s 10.1.5.2/$((1 + $RANDOM % 10)).html > /dev/null &
   sleep 10 #Change in the different phases in order to give less points to defenders? 
done