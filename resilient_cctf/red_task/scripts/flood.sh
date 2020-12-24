###############################
# Author: Guadagnini Giovanni #
###############################

#!/bin/bash

if [ "$#" -ne 6 ];then
    echo "Usage: ./flood.sh <destination_ip> <destination_port> <source_ip> <source_mask> <protocol> <highrate>";
    exit 0
fi

sudo flooder --dst $1 --highrate $6 --dportmin $2 --dportmax $2 --proto $5 --src $3 --srcmask $4