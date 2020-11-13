#!/bin/bash

#Develop monitoring at the server that will let you automatically check the content of HTTP requests you are getting and who is sending them.

#Variables
SERVER=10.5.5.2

#Get the right eth to monitor
ETH=$(ip -brief -4 addr show | grep 10.1.5.2 | cut -c1-4)

sudo tcpflow -p -c -i $ETH port 80 -e http | awk '/GET/||/POST/||/HEAD/{ print $0} /Content-Type/{getline;getline;print; system("")}' > milestone1.txt

