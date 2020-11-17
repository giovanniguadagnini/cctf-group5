#!/bin/bash

### Machines names
PROJECT=".testctf1.OffTech"
CLIENT="client"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_client.txt file."

for (( c=1; c<4; c++ ))
do  
echo "[client$c] setting up home folder and uploading scripts"

ssh $CLIENT$c$PROJECT 1> /dev/null 2>errors/startup_client.txt <<EOF
sudo bash
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient_cctf/red_task/scripts /home/cctf
exit
if ! which flooder &> /dev/null
then
   /share/education/TCPSYNFlood_USC_ISI/install-flooder
fi
sudo apt install -y hping3
cp -r resilient_cctf/red_task/lib /home/cctf
CURRENT=\$(pwd)
cd /home/cctf/lib
tar -xzf scapy-2.4.4.tar.gz
cd \$CURRENT
sudo mv /home/cctf/lib/scapy-2.4.4/ /home/cctf/scripts/scapy
sudo mv /home/cctf/scripts/junk_traffic.py /home/cctf/scripts/scapy/
sudo mv /home/cctf/scripts/HTTPflood.py /home/cctf/scripts/scapy/

sudo iptables -F
sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -d 10.1.5.2 -j DROP
sudo chmod +x /home/cctf -R
EOF

echo "[client$c] /home/cctf folder created, flooder installed, script uploaded"

done