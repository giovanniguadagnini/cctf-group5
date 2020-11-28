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
echo "[client$c] Folder creation and upload operations"

ssh $CLIENT$c$PROJECT 1> /dev/null 2>errors/startup_client.txt <<EOF
sudo bash
mkdir /home/cctf
chmod 777 /home/cctf
cp -r secure_cctf/red_task/scripts /home/cctf
exit
EOF

echo "[client$c] Created folder /home/cctf and uploaded script"

done