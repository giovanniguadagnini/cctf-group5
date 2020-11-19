#!/bin/bash

### Machines names
PROJECT=".testctf5.OffTech"
SERVER="server$PROJECT"
GATEWAY="gateway$PROJECT"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_servet.txt file."

### Page creation in /var/www/html
echo "[server] upload of all the scripts"
ssh $SERVER 1> /dev/null 2>>errors/startup_server.txt <<EOF
mkdir /home/cctf
chmod 777 /home/cctf
cp -r resilient_cctf/blue_task/scripts /home/cctf
sudo chmod +x /home/cctf -R
exit
EOF
echo "[server] created folder /home/cctf and uploaded the scripts"

### Install the server in the server machine and change the port 
echo "[server] Installation of the apache2 webserver, creation of webpages ..."
ssh $SERVER 1> /dev/null 2>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A INPUT -f -j DROP
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.3 -i \$(ip a | grep 10.1.5.2 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.3 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.3 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.5.3 -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --sport 80 -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.2 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-request -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.5.2 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-reply -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
if ! which apache2 &> /dev/null
then
   sudo apt-get update 
   sudo apt-get install apache2 apache2-utils libapache2-mod-qos -y
fi
sudo bash
for (( c=1; c<11; c++ ))
do  
   echo "<html><body><h1>Page \$c</h1></body></html>" > /var/www/html/\$c.html
done
rm /var/www/html/index.html
sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=100000
if ! which tcpflow &> /dev/null
then
   sudo apt install tcpflow -y
fi
sudo cp /etc/apache2/mods-available/qos.conf /etc/apache2/mods-available/qos.conf.old
sudo echo '<IfModule qos_module>' > /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvRequestRate   120 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConn       100 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConnClose  200 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '</IfModule>' >> /etc/apache2/mods-available/qos.conf
sed -i .old "s/Timeout 300$/Timeout 1/" /etc/apache2/apache2.conf
sudo service apache2 restart
EOF
echo "[server] Web server apache2 installed, html pages created in /var/www/html, and basic iptables rules enabled"

### Iptables rules
echo "[gateway] Setting up iptables rules, uploading the scripts, starting snort"
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -f -j DROP
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -p tcp -s 10.1.5.2 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --sport 80 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -f -j DROP
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.3 | tail -c 5) -s 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 10.1.5.2 -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 80 -s 10.1.5.2 -i $(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.1.3 | tail -c 5) -d 10.1.1.3 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-request -m hashlimit --hashlimit-name icmp_gw --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.1.3 | tail -c 5) -s 10.1.1.3 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-reply -m hashlimit --hashlimit-name icmp_gw --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A FORWARD -i \$(ip a | grep 10.1.1.3 | tail -c 5) -d 10.1.5.2 -s 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp -m hashlimit --hashlimit-name icmp_srv --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 --icmp-type echo-request -j ACCEPT
sudo iptables -A FORWARD -o \$(ip a | grep 10.1.1.3 | tail -c 5) -s 10.1.5.2 -d 10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp -m hashlimit --hashlimit-name icmp_srv --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 --icmp-type echo-reply -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
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
exit
EOF
echo "[gateway] Setted up iptables rules, created folder /home/cctf and uploaded scripts"

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
