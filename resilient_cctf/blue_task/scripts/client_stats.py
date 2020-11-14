# Extend your monitoring software so you can detect number of packets and
# bytes sent to the server by each client IP. Make sure the software monitors 
# the correct interface.

import os
import sys 
import time

if len(sys.argv) < 2:
    print("Usage python3 client_stats.py <time_amount> ")
    exit(1)

#Generate the filename
hour=time.time()
hour=str(hour)[0:str(hour).find(".")]
filename = "data_client_" + hour + ".txt"

#Start the data measuremetns 
os.system("sudo timeout " + sys.argv[1] + " tcpdump -i $(ip a | grep 10.1.5.2 | tail -c 5) -nn > " + filename )

#Open the source file
sourceFile = open(filename, "r")

#Get lines from source file
lines = sourceFile.readlines() 

client_packets_map = []
client_bytes_map = []

for line in lines:
    src = line[19 : line.find(' >')]
    print("SRC: " + src)
    dst = line[line.find('> ')+2 : line.find(': ')]
    print("DST: " + dst)
    if(line.find("length") != -1):
        size = int(line[line.find("length ") + 7 : ])
        print("SIZE: " + size)
    else
        size = 0
    print("------------------------------------------")
    if(dst.find("10.1.5.2") != -1):
        if !(SRC in client_packets_map):
            client_packets_map[SRC] = client_packets_map[SRC] + 1
            client_bytes_map[SRC] = client_bytes_map[SRC] + size
        else
            client_packets_map[SRC] = 1
            client_bytes_map[SRC] = size

print(client_packets_map)
print(client_bytes_map)

os.system("rm -rf *.txt")