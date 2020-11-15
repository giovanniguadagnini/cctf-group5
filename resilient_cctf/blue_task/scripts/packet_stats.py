# Extend your monitoring software so you can automatically get statistics on 
# number of packets and bytes sent to the server in TCP data, TCP SYN, UDP 
# and ICMP and Total categories so you can diagnose various DDoS attacks. 
# Make sure the software monitors the correct interface.

import os
import sys 
import time

if len(sys.argv) < 2:
    print("Usage python3 packets_stats.py <time_amount> ")
    exit(1)

print("Don't use time_amount value too big or you could waste a lot of time in analyzing a big amount of data!")

#Generate the filename
hour=time.time()
hour=str(hour)[0:str(hour).find(".")]
filename = "data_server_" + hour + ".txt"

print("TCPDUMP process started")
#Start the data measuremetns 
os.system("sudo timeout " + sys.argv[1] + " tcpdump -i $(ip a | grep 10.1.5.2 | tail -c 5) -nn > " + filename + " 2> /dev/null")
print("TCPDUMP automatically stopped")

#Open the source file
sourceFile = open(filename, "r")

#Get lines from source file
lines = sourceFile.readlines() 

packets_number = 0
tcp_syn_packets = 0
udp_syn_packets = 0
bytes_sent = 0

for line in lines:
    src = line[19 : line.find(' >')]
    #print("SRC: " + src)
    dst = line[line.find('> ')+2 : line.find(': ')]
    #print("DST: " + dst)
    if(dst.find("10.1.5.2") != -1):
        packets_number = packets_number + 1
    if(line.find("[S]") != -1):
        tcp_syn_packets = tcp_syn_packets + 1
    if(line.find("length") != -1):
        size = line[line.find("length ") + 7 : ]
        if(size.find(" ") != -1):
            size=size[0 : size.find(" ") - 1]
        size = int(size)
        #print("SIZE: " + str(size))
    else:
        size = 0
    bytes_sent = bytes_sent + size

print("Packet sent to server: " + str(packets_number))
print("Bytes sent to server: " + str(bytes_sent))
print("TCP SYN packet received: " + str(tcp_syn_packets))

os.system("mv " + filename + " " + filename + ".old")