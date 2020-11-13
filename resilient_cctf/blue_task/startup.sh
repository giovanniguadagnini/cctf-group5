#!/bin/bash

### Machines names
PROJECT=".CCTF-g5.OffTech"
SERVER="server$PROJECT"
GATEWAY="gateway$PROJECT"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_servet.txt file."

### Install the server in the server machine and change the port 
echo "[server] Installation of the apache2 webserver ..."
ssh $SERVER 1> /dev/null 2>errors/startup_server.txt <<EOF
if ! which apache2 &> /dev/null
then
   sudo apt-get update 
   sudo apt-get install apache2 -y
fi
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=10000
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 10.1.5.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -d 10.1.5.0/24 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 22 -s 10.1.5.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 22 -d 10.1.5.0/24 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.0/24 -i \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -p tcp --sport 80 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
EOF
echo "[server] Web server apache2 installed and basic iptables rules enabled"

### Page creation in /var/www/html
echo "[server] creation of webpages and upload of all scripts"
ssh $SERVER 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo bash
for (( c=1; c<11; c++ ))
do  
   echo "<html><head><title>Page \$c</title></head><body><h1>Page \$c</h1></body></html>" > /var/www/html/\$c.html
done
rm /var/www/html/index.html
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient-cctf/blue_task/scripts /home/cctf
exit
EOF
echo "[server] Html pages created in /var/www/html, created folder /home/cctf and uploaded scripts"

#Snort installation copied from /share/education/SecuringLegacySystems_JHU/Snort/SnortInstall.sh
echo "[gateway] Snort installation please wait."
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo cp /share/education/SecuringLegacySystems_JHU/Snort/iptablesload /etc/network/if-pre-up.d/
sudo chmod +x /etc/network/if-pre-up.d/iptablesload
sudo iptables -P FORWARD DROP

sudo apt-get install flex bison libpcre3-dev libnetfilter-queue-dev libnetfilter-queue1 -y
cd /usr/local
sudo tar -xvzf /share/education/SecuringLegacySystems_JHU/Snort/libpcap-1.0.0.tar.gz
cd libpcap-1.0.0
sudo ./configure && sudo make && sudo make install
cd ..
sudo tar -zxvf /share/education/SecuringLegacySystems_JHU/Snort/libdnet-1.11.tar.gz
cd libdnet-1.11
sudo ./configure && sudo make && sudo make install
cd ..
sudo tar -xvzf /share/education/SecuringLegacySystems_JHU/Snort/daq-0.6.2.tar.gz
cd daq-0.6.2
sudo ./configure && sudo make && sudo make install
cd ..

sudo cp /usr/local/lib/libdnet.1* /usr/lib/ -r
sudo ldconfig

sudo tar -zxvf /share/education/SecuringLegacySystems_JHU/Snort/snort-2.9.2.2.tar.gz
cd snort-2.9.2.2
sudo ./configure --enable-targetbased --enable-dynamicplugin --enable-perfprofiling --enable-react && sudo make && sudo make install
EOF
echo "[gateway] Snort installed successfully!"

### Iptables rules
echo "[gateway] Setting up iptables rules, uploading the scripts, starting snort"
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -s 10.1.5.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -d 10.1.5.0/24 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 22 -s 10.1.5.0/24 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 22 -d 10.1.5.0/24 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 --dport 80 -m state --state NEW,ESTABLISHED -j NFQUEUE
sudo iptables -A FORWARD -p tcp -s 10.1.5.2 --sport 80 -m state --state ESTABLISHED -j NFQUEUE
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.0/24 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
sudo bash
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient-cctf/blue_task/scripts /home/cctf
mkdir /home/cctf/snort
chmod 777 /home/cctf/snort
mkdir /home/cctf/snort/alerts
chmod 777 /home/cctf/snort/alerts
echo 'alert tcp any any -> 10.1.5.2 80 (sid:1000001; msg:"test";)' > /home/cctf/snort/snort.conf
echo 'config policy_mode:inline' >> /home/cctf/snort/snort.conf
sudo snort --daq nfq -Q -c /home/cctf/snort/snort.conf -l /home/cctf/snort/alerts -D 
exit
EOF
echo "[gateway] Enabled iptables rules in gateway machine, created folder /home/cctf and uploaded scripts"