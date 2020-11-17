# Extend your monitoring software so you can detect number of packets and
# bytes sent to the server by each client IP. Make sure the software monitors 
# the correct interface.

import os
import sys 
import time

if len(sys.argv) < 2:
    print("Usage python3 client_stats.py <time_amount> ")
    exit(1)

print("Don't use time_amount value too big or you could waste a lot of time in analyzing a big amount of data!")

#Generate the filename
hour=time.time()
hour=str(hour)[0:str(hour).find(".")]
filename = "data_client_" + hour + ".txt"

print("TCPDUMP process started")
#Start the data measuremetns 
os.system("sudo timeout " + sys.argv[1] + " tcpdump -i $(ip a | grep 10.1.5.2 | tail -c 5) -nn > " + filename + " 2> /dev/null")
print("TCPDUMP automatically stopped")

#Open the source file
sourceFile = open(filename, "r")

#Get lines from source file
lines = sourceFile.readlines() 

client_packets_map = {}
client_bytes_map = {}

for line in lines:
    if(line.find("ARP") == -1):
        #print(line)
        src = line[19 : line.find(' >')]
        src = src[0 : src.rfind(".")]
        #print("SRC: " + src)
        dst = line[line.find('> ')+2 : line.find(': ')]
        dst = dst[0 : dst.rfind(".")]
        #print("DST: " + dst)
        if(line.find("length") != -1):
            size = line[line.find("length ") + 7 : ]
            if(size.find(" ") != -1):
                size=size[0 : size.find(" ") - 1]
            size = int(size)
            #print("SIZE: " + str(size))
        else:
            size = 0
        #print("------------------------------------------")
        if(dst.find("10.1.5.2") != -1):
            if (src in client_packets_map.keys()):
                client_packets_map[src] = client_packets_map[src] + 1
                client_bytes_map[src] = client_bytes_map[src] + size
            else:
                client_packets_map[src] = 1
                client_bytes_map[src] = size

for key in client_packets_map:
    if(key in client_bytes_map.keys()):
        print(key + " packets: " + str(client_packets_map[key]) + ", bytes: " + str(client_bytes_map[key]))
    else:
        print(key + " packets: " + str(client_packets_map[key]))

os.system("mv " + filename + " " + filename + ".old")