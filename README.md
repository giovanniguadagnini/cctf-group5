# CCTF-Group5

## Resilent CCTF
As blue team: the scripts will be used to protect an apache2 web server from DoS attack.  
As red team: the scripts will be used in order to try to make unreachable the server of the defeder team.

### Step to startup the services and clients
1) Download last updates: **git pull**  
2) Delete the folder in your deterlab machine (rm -rf resilient_cctf).  
3) Update PROJECT variable in /resilient_cctf/blue_task/startup.sh and /resilient_cctf/red_task/startup.sh files.  
4) Upload the everything to deterlab: **scp -r resilient_cctf otech2<id>@users.deterlab.net:.**  
5) Login in server or gateway then run: **chmod +x resilient_cctf -R; ./resilient_cctf/blue_task/startup.sh**  
6) Login in client1/2/3 then run: **chmod +x resilient_cctf -R; ./resilient_cctf/red_task/startup.sh**  
7) You'll find everything in /home/cctf folder.  

## Secure CCTF
