from scapy.all import *
import random as random
import sys

if __name__ == "__main__":

    while True:

        source = "10.1.{}.2".format(random.randint(2,3))
        # source = "10.1.5.2" #Router
        
        getStr = 'GET /{}.html HTTP/1.1\r\nHost: 10.1.5.2\r\nUser-Agent: curl/7.58.0\r\nAccept: */*\r\n\r\n'.format(random.randint(1,9))

        packet = IP(src=source, dst="10.1.5.2")/TCP(seq=random.randint(41058789,3209640057), sport=random.randint(10000,60000), dport=80, window=64240)
        send(packet)

        if len(sys.argv)>1 and sys.argv[1]=="-v":
            print("Sent request from {}".format(source))