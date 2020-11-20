#!/bin/bash

### Machines names
PROJECT=".securecctf-g5.OffTech"
CLIENT="client"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_client.txt file."

for (( c=1; c<4; c++ ))
do  
echo "[client$c] "

ssh $CLIENT$c$PROJECT 1> /dev/null 2>errors/startup_client.txt <<EOF

EOF

echo "[client$c] "

done