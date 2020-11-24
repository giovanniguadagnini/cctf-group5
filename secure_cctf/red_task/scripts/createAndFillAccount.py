#!/usr/bin/python
import requests
import random
import string
from time import sleep

username = "legitU"
password = "legitP"

beg_req = "http://10.1.5.2/process.php"

def fill_transaction_history():
    types = ["deposit", "withdraw"]
    amount = random.randint(100, 100000)
    drop = random.choice(types)
    params = (
        ('user', username),
        ('pass', password),
        ('drop', drop),
        ('amount', amount),
    )
    response = requests.get(beg_req, params=params)
    print(response.text)



def create_user():

    params = (
        ('user', username),
        ('pass', password),
        ('drop', 'register'),
    )
    response = requests.get(beg_req, params=params)
    print(response.text)

def main():
    global username
    global password
    append_rand = ''.join(random.choice(string.ascii_lowercase) for i in range(10))
    username += append_rand
    password += append_rand
    create_user()
    print("Username is {}, password is {}".format(username, password))
    for i in range(40):
        #40 transaction to add to history, but not too fast, just in case it could be considered DOS
        fill_transaction_history()
        sleep(0.05)

main()
