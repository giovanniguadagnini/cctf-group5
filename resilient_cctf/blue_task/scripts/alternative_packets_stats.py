#usr/bin/env python

# Code and method inspired by https://www.thepythoncode.com/code/sniff-http-packets-scapy-python
# Please see the comments for further informations

from scapy.all import *
import pickle
import subprocess

#number_XXX represent the number of packet received from this current "protocol" or flag
#length_XXX represent the total number of byte received from this procol since the launch of our program 
number_udp = 0
number_tcp_syn = 0
number_tcp_data = 0
number_icmp = 0
length_udp = 0
length_tcp_syn = 0
length_tcp_data = 0
length_icmp = 0

# Where we store some general informations concerning the clients of our server
list_clients = dict()

# The total packet counter
number_packet = 0

oldTime = time.time()


def sniff_packets(iface=None):
    """
    Sniff 80 port packets with `iface`, if None (default), then the
    Scapy's default interface is used
    """
    if iface:
        # port 80 for http (generally)
        # `process_packet` is the callback
        sniff(filter="icmp or tcp or udp",lfilter= lambda pkt: pkt[Ether].src != Ether().src, prn=process_packet,iface=iface, store=False) #lfilter= lambda pkt: pkt[Ether].src != Ether().src,
    else:
        # sniff with default interface
        sniff(prn=process_packet, store=False)

# Every time a packet is detected (sniffed) by scapy, this function will be executed
def process_packet(packet):
    global number_udp
    global number_tcp_syn
    global number_tcp_data
    global number_icmp
    global length_udp
    global length_tcp_syn
    global length_tcp_data
    global length_icmp
    global list_clients
    global number_packet
    global oldTime
    
    # If the packet is on the IP layer, IE we want to analyze it
    if packet.haslayer(IP):
        #Get its address
        ip = packet[IP].src
        #Search into our dictionnary if it is already there, otherwise add it
        if not ip in list_clients:
            list_clients[ip] = (0,0)
        (x,y) = list_clients[ip]
        #X represent the number of time this ip as sent us a packet, increase it by one
        #Y represent the toal length of those packets, increase it by the length of the current packet
        x += 1
        y += len(packet)
        list_clients[ip] = (x,y)

        # Same reasonning for the four following if:
        # We check which layer the current packet is, and if necessary the flags
        # After identifying what type of packets we are analysing, update and print the corresponding info

        if packet.haslayer(ICMP):
            number_icmp += 1
            length_icmp += len(packet)
            #print("ICMP packet received from: " + str(ip) + ". This is the " + str(x) + " from this address");

        if packet.haslayer(UDP):
            number_udp += 1
            length_udp += len(packet)
            #print("UDP packet received from: " + str(ip) + ". This is the " + str(x) + " from this address");

        if packet.haslayer(TCP):
            #Flag S == Syn packet
            if packet[TCP].flags & 0x02:
                number_tcp_syn += 1
                length_tcp_syn += len(packet)
                #print("SYN packet received from: " + str(ip) + ". This is the " + str(x) + " from this address");
            #If not flag SYN, FIN or RST, then it is a data packet
            if not packet[TCP].flags & 0x02 and not packet[TCP].flags & 0x01  and not packet[TCP].flags & 0x04:
                #print(packet[TCP].flags)
                number_tcp_data += 1
                length_tcp_data += len(packet)
                #print("DATA packet received from: " + str(ip) + ". This is the " + str(x) + " from this address");

        number_packet += 1
        #Every five seconds, print a report, reset all necessary variables
        if (time.time() - oldTime) > 5:
            print ("Report:")
            print ("We have received {:d} packets in the last five seconds".format(number_packet))
            print ("{:d} SYN packets , total length {:d}".format(number_tcp_syn, length_tcp_syn))
            print ("{:d} DATA packets , total length {:d}".format(number_tcp_data, length_tcp_data))
            print ("{:d} UDP packets , total length {:d}".format(number_udp, length_udp))

            print ("Packets received come from:")
            for key, value in list_clients.iteritems() :
                print("Source: {}, nb packets: {:d}, length packets: {:d}".format(key, value[0], value[1]))
            print("")
            #RESET DICTIONNARY
            list_clients = dict()
                #print (key, value)
            #print ("See clients_info for detailed dump")
            #pickle.dump(list_clients,open("clients_info","wb"))
            oldTime = time.time()
            number_tcp_syn = length_tcp_syn = number_tcp_data = length_tcp_data = number_udp = length_udp = number_packet = 0


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--iface", help="Interface to use, default is scapy's default interface")
    args = parser.parse_args()
    iface = args.iface
    sniff_packets(iface)
