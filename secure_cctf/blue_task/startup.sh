#!/bin/bash

### Machines names
PROJECT=".securecctf-g5.OffTech"
SERVER="server$PROJECT"
GATEWAY="gateway$PROJECT"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_servet.txt file."

### Page creation in /var/www/html
echo "[server] installation of lampp and iptables setup"
ssh $SERVER 1> /dev/null 2>>errors/startup_server.txt <<EOF
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
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24,10.1.5.3 -p tcp --sport 80 -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.5.2 | tail -c 5) -d 10.1.5.2 -s 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-request -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.5.2 | tail -c 5) -s 10.1.5.2 -d 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-reply -m hashlimit --hashlimit-name icmp --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
sudo apt-get update 
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password password @ThisIsASecurePassword|'
debconf-set-selections <<< 'mysql-server-5.7 mysql-server/root_password_again password @ThisIsASecurePassword|'
sudo apt-get install lamp-server^ -y
sudo apt-get install apache2-utils libapache2-mod-qos -y
sudo cp /proj/OffTech/cctf_secureserver/*.php /var/www/html
sudo rm /var/www/html/index.html
sudo bash
cat /proj/OffTech/cctf_secureserver/httpd.conf >> /etc/apache2/httpd.conf
exit
sudo /etc/init.d/apache2 restart
sudo mysql -u"root" -p"@ThisIsASecurePassword|" < /proj/OffTech/cctf_secureserver/setup.sql
sudo mysql -u"root" -p"@ThisIsASecurePassword|" < secure_cctf/blue_task/add_user.sql
cd secure_cctf/original_php_files/
chmod +x *.sh
sudo mv /var/www/html/process.php /var/www/html/process.php.old
sudo mv /var/www/html/index.php /var/www/html/index.php.old
sudo cp process_fixed.php /var/www/html/process.php
sudo cp index_fixed.php /var/www/html/index.php
if ! which tcpflow &> /dev/null
then
   sudo apt install tcpflow -y
fi
sudo cp /etc/apache2/mods-available/qos.conf /etc/apache2/mods-available/qos.conf.old
sudo bash
sudo echo '<IfModule qos_module>' > /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvRequestRate   120 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConn       100 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '    QS_SrvMaxConnClose  200 ' >> /etc/apache2/mods-available/qos.conf
sudo echo '</IfModule>' >> /etc/apache2/mods-available/qos.conf
exit
sudo sed -i.old "s/Timeout 300$/Timeout 1/" /etc/apache2/apache2.conf
EOF
echo "[server] lampp installed, process.php patched  and iptables configured"

echo "[gateway] Setting up iptables rules, uploading the scripts"
ssh $GATEWAY 1> /dev/null 2>>errors/startup_server.txt <<EOF
sudo iptables -F
sudo iptables -A INPUT -i lo -j ACCEPT
sudo iptables -A OUTPUT -o lo -j ACCEPT
sudo iptables -A INPUT -s 192.168.0.0/16 -j ACCEPT
sudo iptables -A OUTPUT -d 192.168.0.0/16 -j ACCEPT
sudo iptables -A FORWARD -p tcp -d 10.1.5.2 -s 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -p tcp -s 10.1.5.2 -d 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 --sport 80 -m state --state ESTABLISHED -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-request -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-request -o \$(ip a | grep 10.1.5.3 | tail -c 5) -d 10.1.5.2 -j ACCEPT
sudo iptables -A INPUT -p icmp --icmp-type echo-reply -i \$(ip a | grep 10.1.5.3 | tail -c 5) -s 10.1.5.2 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 80 -d 10.1.5.2 -o \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -p tcp --sport 80 -s 10.1.5.2 -i \$(ip a | grep 10.1.5.3 | tail -c 5) -j ACCEPT
sudo iptables -A INPUT -i \$(ip a | grep 10.1.1.3 | tail -c 5) -d 10.1.1.3 -s 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-request -m hashlimit --hashlimit-name icmp_gw --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A OUTPUT -o \$(ip a | grep 10.1.1.3 | tail -c 5) -s 10.1.1.3 -d 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp --icmp-type echo-reply -m hashlimit --hashlimit-name icmp_gw --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 -j ACCEPT
sudo iptables -A FORWARD -i \$(ip a | grep 10.1.1.3 | tail -c 5) -d 10.1.5.2 -s 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp -m hashlimit --hashlimit-name icmp_srv --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 --icmp-type echo-request -j ACCEPT
sudo iptables -A FORWARD -o \$(ip a | grep 10.1.1.3 | tail -c 5) -s 10.1.5.2 -d 10.1.1.0/24,10.1.2.0/24,10.1.3.0/24,10.1.4.0/24 -p icmp -m hashlimit --hashlimit-name icmp_srv --hashlimit-mode srcip --hashlimit 1/second --hashlimit-burst 5 --icmp-type echo-reply -j ACCEPT
sudo iptables -P INPUT DROP
sudo iptables -P OUTPUT DROP
sudo iptables -P FORWARD DROP
sudo bash
mkdir /home/cctf
chmod 777 /home/cctf
cp -r secure_cctf/blue_task/scripts /home/cctf
exit
EOF
echo "[gateway] Setted up iptables rules, created folder /home/cctf and uploaded scripts"