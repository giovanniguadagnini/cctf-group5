###############################
# Author: Guadagnini Giovanni #
###############################

#!/bin/bash

if [ $# -ne 3 ];then
    echo "Usage: ./connect_to_client.sh <deterlab_user> <client1|2|3.experiment_name> <port>";
    exit 0
fi

ssh -J $1@users.deterlab.net -D 127.0.0.1:$3 $1@$2.OffTech -N -f 1> /dev/null 

google-chrome --proxy-server=socks://localhost:$3 1> /dev/null 