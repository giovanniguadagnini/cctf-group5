#!/bin/bash

#Simple overdraft, we create a new user, deposit X amount inside its account
#Then try to withdraw X + 10 from his account

USER="ovUser"
PASS="ovPass"

#Create Account
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register" &
sleep 1

#Deposit X onside its account
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=100" &
sleep 1

#Try to withdraw X + 100 amount
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=withdraw&amount=200" &
sleep 1

#Display Balance
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance"

