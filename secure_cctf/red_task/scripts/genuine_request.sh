#!/bin/bash

USER="gianni"
PASS="pinotto"

curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register"

while true
do
    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=10" &
    sleep 1
    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance" &
    sleep 1
    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=withdraw&amount=10" &
    sleep 1
    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance" &
    sleep 1
done