#!/usr/bin/python3

import os
import requests

curl_header = {
    "Host" : "10.1.5.2",
    "User-Agent" : "curl.7.72.0",
    "Connection": "Keep-Alive",
    "Cache-Control": "no-cache",
    "Accept": "*/*"
}

payloads = ["", "!)()&//(&/(/(/)))", "1.2", "1,2" "-2147483647", "0.44e10", "-0.44e10", "0.44b2", "-0.44b2", "1&asd()", "abcdefghil", "11aa", "123a321", "now()", "~2147483647", "SIGN(2147483647)", "9223372036854775807", "9223372036854775808", "-9223372036854775807", "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa", "!£$%$&/()/$", "&&&&&&&&&&&&&&&&"]

errors = []

user = "JJJJJJJJ"
password = "YYYYYYYYYY"

def registerUser():
    request_url = "http://10.1.5.2/process.php?user={}&pass={}&drop=".format(user, password, "register")
    r = requests.get(request_url, headers=curl_header)

    print("User registered ({}):\n{}".format(r.status_code, r.text))

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

    if(r.status_code != 200):
        print("The request ({}) generated an error in the webserver.\n".format(payload))
        errors.append("field: {}, payload: {}, action {}, status {}".format(fieldToAttack, payload, action, r.status_code))

    print("Response ({}):\n{}".format(r.status_code, r.text))
    print("---------------------------------------")


def main():
    registerUser()
    for payload in payloads:
        sendRequest("amount", payload, "deposit")
        sendRequest("amount", payload, "withdraw")
        sendRequest("amount", payload, "balance")
        sendRequest("amount", payload, "register")
    
    for payload in payloads:
        sendRequest("drop", payload, "deposit")
        sendRequest("drop", payload, "withdraw")
        sendRequest("drop", payload, "balance")
        sendRequest("drop", payload, "register")

    for payload in payloads:
        sendRequest("user", payload, "deposit")
        sendRequest("user", payload, "withdraw")
        sendRequest("user", payload, "balance")
        sendRequest("user", payload, "register")

    for payload in payloads:
        sendRequest("user", payload, "register")
        sendRequest("password", payload, "register")

    if(len(errors) > 0):
        for e in errors:
            print(e)

if __name__ == "__main__":
    main()