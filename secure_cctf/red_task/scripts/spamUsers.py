#!/usr/bin/python
import requests
import random
import string
from time import sleep
import sys

beg_req = "http://10.1.5.2/process.php"

def create_user(username, password):
    params = (
        ('user', username),
        ('pass', password),
        ('drop', 'register'),
    )
    response = requests.get(beg_req, params=params)
    print(response.text)

def main():
    if len(sys.argv) != 2:
        print("Usage: spam_Users waitTime | waitTime in seconds, for example 0.05 is 50 milliseconds")
        exit(-1)
    while (1):
        #create a random username + password combo, register them, sleep time is adjustable
        username = ''.join(random.choice(string.ascii_lowercase) for i in range(10))
        password = ''.join(random.choice(string.ascii_lowercase) for i in range(10))
        create_user(username, password)
        sleep(int(sys.argv[1]))

main()
