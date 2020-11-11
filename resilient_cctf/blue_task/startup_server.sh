#!/bin/bash

### Machines names
PROJECT=""
SERVER="server$PROJECT"
GATEWAY="gateway$PROJECT"

### Install the server in the server machine and change the port 
echo "[server] Installation of the apache2 webserver"
ssh $SERVER 1> /dev/null 2>errors.txt <<EOF
if ! which apache2 &> /dev/null
then
   sudo apt-get update 
   sudo apt-get install apache2
fi

sed -i.old "s/Listen 80$/Listen 8080/" /etc/apache2/ports.conf
sed -i.old "s/<VirtualHost *:80>$/<VirtualHost *:8080>/" /etc/apache2/sites-enabled/000-default.conf
sudo systemctl restart apache2

sudo sysctl -w net.ipv4.tcp_syncookies=1
sudo sysctl -w net.ipv4.tcp_max_syn_backlog=10000

sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -p tcp --sport 80 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
EOF
echo "[server] Web server apache2 installed and listening port changed"

### Page creation in /var/www/html
ssh $SERVER 1> /dev/null 2>>errors.txt <<EOF
sudo bash
for (( c=1; c<11; c++ ))
do  
   echo "<html><head><title>Page $c</title></head><body><h1>Page $c</h1></body></html>" > /var/www/html/$c.html
done
rm /var/www/html/index.html
exit
EOF
echo "[server] Html pages created in /var/www/html"

### Iptables rules
ssh $GATEWAY 1> /dev/null 2>>errors.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP

sudo bash 
echo 1 > /proc/sys/net/ipv4/ip_forward
exit
EOF
echo "[gateway] Enabled iptables rules in gateway machine"