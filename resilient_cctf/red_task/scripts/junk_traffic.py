###############################
# Author: Piva Davide         #
###############################

from scapy.all import *
import random as random
import time as time

SERVER_IP = "10.1.5.2"
GATEWAY_IP = "10.1.5.3"
ROUTER_IP = "10.1.1.2"
LEGITIMATE_IP = "10.1.4.2"

if __name__ == "__main__":

    while True:
        choice = random.randint(0,5)
        packet = None

        if choice == 0:
            # TTL time exceed: produce ICMP packet router->server
            packet = IP(src=SERVER_IP, dst=SERVER_IP, ttl=1)/TCP(sport=22, dport=22)
            del(packet.getlayer(IP).chksum)
        elif choice == 1:
            # SSH connection between gateway and server
            packet = IP(src=GATEWAY_IP, dst=SERVER_IP)/TCP(sport=22, dport=22)
        elif choice == 2:
            # HTTP traffic from the gateway
            packet = IP(src=GATEWAY_IP, dst=SERVER_IP)/TCP(sport=random.randint(10000, 60000), dport=80)
        elif choice == 3:
            # HTTP traffic coming from the router
            packet = IP(src=ROUTER_IP, dst=SERVER_IP)/TCP(sport=random.randint(10000, 60000), dport=80)
        elif choice == 4:
            # ACK packet from the legitimate client
            packet = IP(src=SERVER_IP, dst=LEGITIMATE_IP)/TCP(sport=80, dport=random.randint(10000, 60000))
        elif choice == 5:
            # SSH connection between server and gateway
            packet = IP(src=SERVER_IP, dst=GATEWAY_IP)/TCP(sport=22, dport=22)

        if packet != None:
            send(packet)
        else:
            print("ERROR: packet not crafted correctly (skipped)")

        wait = random.uniform(0.3, 1.5)
        time.sleep(wait)