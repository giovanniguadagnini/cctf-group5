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
2) Evaluate the traffic and setup a rule to block eventual SYN with a specific form **sudo iptables -I FORWARD 1 --match string --algo bm|kmp --from 30 --to 34 --hex-string '|ff ff|' -p tcp --dport 80 --syn --j DROP** (check for window = 65535), **sudo iptables -I FORWARD 1 --match string --algo bm --to 10 ! --hex-string '|4000|' -p  tcp --dport 80 --syn --j DROP** (check for DF bit not setted typical of flooder), **sudo iptables -I FORWARD 1 -m length --length 60 -p tcp --dport 80 --syn --j DROP**

#### Attack phase
1) Start **genuine_client.sh** (default timer = 10 second to give less point to defenders).  
2) Start the attack.  
3) Launch change_rate.sh with genuine_client ip and timeout in second to set a lower timeout.  
4) Evaluate how powerful is the attack.  
5) Stop attack.  
6) Reset the timeout to 10 using **./change_rate.sh genuine_client_ip 10**   

## Secure CCTF
As blue team: the script will be used to protect a small php application.  
As red team: the script will be used to attack a small php web application.  

### Step to startup the machines
1) Download last updates: **git pull**  
2) Delete the folder in your deterlab machine (rm -rf secure_cctf).  
3) Update PROJECT variable in /secure_cctf/blue_task/startup.sh and /secure_cctf/red_task/startup.sh files.  
4) Upload the everything to deterlab: **scp -r secure_cctf otech2<id>@users.deterlab.net:.**  
5) Login in server or gateway then run: **chmod +x secure_cctf -R; ./secure_cctf/blue_task/startup.sh**  
6) Login in a client then run: **chmod +x secure_cctf -R; ./secure_cctf/red_task/startup.sh**  
7) You'll find everything in /home/cctf folder.  

#### Defense phase
1) Evaluate the traffic reaching the server with the traffic analysis script and also execute check_consistency_db.sh to immmediately know if there are problems.  
2) Start the scripts to evaluate the traffic (**run_traffic_monitor.sh**, **packet_inspection.sh**, **monitor_server.sh**) to evaluate the situation.  
3) In case they are using slow_loris check the rules used for resilient_cctf and try to block the packets (in any case mod_qos should fix this problem) (Evaluate if use **sudo sed -i.old "s/Timeout 300$/Timeout 10/" /etc/apache2/apache2.conf**).  

#### Attack phase
1) Run **sqlmap_check.sh** to know if the adversary webserver has injection problems.  
2) Run **attack.py** and evaluate the output messages of the page, the script will automatically test some strange payloads and provide the output.  
3) Evaluate if the balance page grows a lot with a lot of transfers in that case, start **basic_attack.sh** (1 option to fill the table).  
4) Open the connection with the server through the client and visit the page using **connect_to_client.sh**.  
5) Start **genuine_requests.sh** (Pay attention to the number of requests, may give to the adversay a lot of points). **ATTENTION** user and password of basic_attack.sh and genuine_requests.sh are the same.  