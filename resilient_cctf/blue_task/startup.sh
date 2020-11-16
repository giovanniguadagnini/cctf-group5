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

### Page creation in /var/www/html
echo "[server] creation of webpages and upload of all scripts"
ssh $SERVER 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo bash
for (( c=1; c<11; c++ ))
do  
   echo "<html><body><h1>Page \$c</h1></body></html>" > /var/www/html/\$c.html
done
rm /var/www/html/index.html
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient_cctf/blue_task/scripts /home/cctf
exit
EOF
echo "[server] Html pages created in /var/www/html, created folder /home/cctf and uploaded scripts"

### Install the server in the server machine and change the port 
echo "[server] Installation of the apache2 webserver ..."
ssh $SERVER 1> /dev/null 2>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.3 -i \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.3 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.3 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.5.3 -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --sport 80 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
if ! which apache2 &> /dev/null
then
   sudo apt-get update 
   sudo apt-get install apache2 apache2-utils libapache2-mod-qos -y
fi
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=100000
if ! which tcpflow &> /dev/null
then
   sudo apt install tcpflow -y
fi
sudo cp /etc/apache2/mods-available/qos.conf /etc/apache2/mods-available/qos.conf.old
sudo echo '<IfModule qos_module>' > /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvRequestRate   120 # minimum request rate (bytes/sec at request reading):' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConn       100 # limits the connections for this virtual host:' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConnClose  200 # allows keep-alive support till the server reaches 200 connections:' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConnPerIP  10 # allows max 50 connections from a single ip address:' >> /etc/apache2/mods-available/qos.conf
sudo echo '</IfModule>' >> /etc/apache2/mods-available/qos.conf
sed -i .old "s/Timeout 300$/Timeout 10/" /etc/apache2/apache2.conf
sudo service apache2 restart
EOF
echo "[server] Web server apache2 installed and basic iptables rules enabled"

#Snort installation copied from /share/education/SecuringLegacySystems_JHU/Snort/SnortInstall.sh
echo "[gateway] Snort installation please wait."
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -p tcp -s 10.1.5.2 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --sport 80 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.3 | tail -c 5) -s 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 10.1.5.2 -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 80 -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

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

sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --dport 80 -m state --state NEW,ESTABLISHED -j NFQUEUE
sudo iptables -A FORWARD -p tcp -s 10.1.5.2 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --sport 80 -m state --state ESTABLISHED -j NFQUEUE
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.3 | tail -c 5) -s 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 10.1.5.2 -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 80 -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
EOF
echo "[gateway] Snort installed successfully!"

### Iptables rules
echo "[gateway] Setting up iptables rules, uploading the scripts, starting snort"
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
if ! which tcpflow &> /dev/null
then
   sudo apt update
   sudo apt install tcpflow -y
fi
sudo bash
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient_cctf/blue_task/scripts /home/cctf
mkdir /home/cctf/snort
chmod 777 /home/cctf/snort
mkdir /home/cctf/snort/alerts
chmod 777 /home/cctf/snort/alerts
echo 'drop tcp any any -> 10.1.5.2 80 (msg:"Flooder SYN detected and blocked" sid:1000001; msg:"test"; flags: S; fragbits: !D;)' > /home/cctf/snort/snort.conf
echo 'event_filter gen_id 1, sig_id 1000001, track by_src, count 1, seconds 10, type limit' >> /home/cctf/snort/snort.conf
echo '#alert tcp any any -> 10.1.5.2 80 (msg: "TPC SYN detected"; sid: 1000003; rev: 1; flags:S;)' >> /home/cctf/snort/snort.conf
echo '#rate_filter gen_id 1, sig_id 1000003, track by_src, count 50, seconds 1, new_action drop, timeout 10' >> /home/cctf/snort/snort.conf
echo '#event_filter gen_id 1, sig_id 1000003, track by_src, count 1, seconds 10, type limit' >> /home/cctf/snort/snort.conf
echo '#drop tcp any any -> 10.1.5.2 80 (msg: "Detected junk traffic"; sid: 1000005;  pcre:"/.-. /";)' >> /home/cctf/snort/snort.conf
echo '#event_filter gen_id 1, sig_id 1000005, track by_src, count 5, seconds 10, type limit' >> /home/cctf/snort/snort.conf
echo '#alert tcp any any -> 10.1.5.2 80 (msg: "TCP SYN flood attack detected"; sid: 1000004; rev: 1; flags:S; detection_filter: track by_src, count 100, seconds 1;)' >> /home/cctf/snort/snort.conf
echo '#event_filter gen_id 1, sig_id 1000004, track by_src, count 1, seconds 10, type limit' >> /home/cctf/snort/snort.conf
echo 'config policy_mode:inline' >> /home/cctf/snort/snort.conf
sudo snort --daq nfq -Q -c /home/cctf/snort/snort.conf -l /home/cctf/snort/alerts -D 
exit
EOF
echo "[gateway] Enabled iptables rules in gateway machine, created folder /home/cctf and uploaded scripts"

echo "[gateway] Setting up Scapy and alternative client stat collection"
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
cp -r resilient_cctf/red_task/lib /home/cctf
sudo bash
cd /home/cctf/lib
tar -xzf scapy-2.4.4.tar.gz
sudo mv /home/cctf/lib/scapy-2.4.4/ /home/cctf/scripts/scapy
sudo apt-get install python-scapy
exit
EOF
echo "[gateway] Set up of Scapy and alternative client stat collection done"
