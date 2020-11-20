# CCTF-Group5

## Resilent CCTF
As blue team: the scripts will be used to protect an apache2 web server from DoS attack.  
As red team: the scripts will be used in order to try to make unreachable the server of the defeder team.

### Step to startup the machines
1) Download last updates: **git pull**  
2) Delete the folder in your deterlab machine (rm -rf resilient_cctf).  
3) Update PROJECT variable in /resilient_cctf/blue_task/startup.sh and /resilient_cctf/red_task/startup.sh files.  
4) Upload the everything to deterlab: **scp -r resilient_cctf otech2<id>@users.deterlab.net:.**  
5) Login in server or gateway then run: **chmod +x resilient_cctf -R; ./resilient_cctf/blue_task/startup.sh**  
6) Login in a client then run: **chmod +x resilient_cctf -R; ./resilient_cctf/red_task/startup.sh**  
7) You'll find everything in /home/cctf folder.  

#### Defense phase
1) Launch statistics script.
2) In case change snort rules and restart it with **sudo pkill snort; sudo snort --daq nfq -Q -c /home/cctf/snort/snort.conf -l /home/cctf/snort/alerts -D**  
3) Evaluate the traffic and setup a rule to block eventual SYN with a specific form **sudo iptables -I FORWARD 1 --match string --algo bm|kmp --from 30 --to 34 --hex-string '|ff ff|' -p tcp --dport 80 --syn --j DROP** (check for window = 65535), **sudo iptables -I FORWARD 1 --match string --algo bm --to 10 ! --hex-string '|4000|' -p  tcp --dport 80 --syn --j DROP** (check for DF bit not setted typical of flooder), **sudo iptables -I FORWARD 1 -m length --length 60 -p tcp --dport 80 --syn --j DROP**

#### Attack phase
1) Start **genuine_client.sh** (default timer = 10 second to give less point to defenders).  
2) Start the attack.  
3) Launch change_rate.sh with genuine_client ip and timeout in second to set a lower timeout.  
4) Evaluate how powerful is the attack.  
5) Stop attack.  
6) Reset the timeout to 10 using **./change_rate.sh genuine_client_ip 10**   

## Secure CCTF
As blue team: the script will be used to protect a small php application
As red team: the script will be used to attack a small php web application

### Step to startup the machines
1) Download last updates: **git pull**  
2) Delete the folder in your deterlab machine (rm -rf secure_cctf).  
3) Update PROJECT variable in /secure_cctf/blue_task/startup.sh and /secure_cctf/red_task/startup.sh files.  
4) Upload the everything to deterlab: **scp -r secure_cctf otech2<id>@users.deterlab.net:.**  
5) Login in server or gateway then run: **chmod +x secure_cctf -R; ./secure_cctf/blue_task/startup.sh**  
6) Login in a client then run: **chmod +x secure_cctf -R; ./secure_cctf/red_task/startup.sh**  
7) You'll find everything in /home/cctf folder.  

#### Defense phase

#### Attack phase