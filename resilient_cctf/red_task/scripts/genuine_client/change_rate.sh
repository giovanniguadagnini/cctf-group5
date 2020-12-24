###############################
# Author: Guadagnini Giovanni #
###############################

#!/bin/bash

if [ "$#" -ne 2 ];
then 
    echo "Usage ./change_rate.sh <ip_genuine_client> <timeout>"
    exit 1
else
    ssh $1 "echo '$2' | sudo tee /home/cctf/scripts/genuine_client/rate.txt" 1> /dev/null
fi