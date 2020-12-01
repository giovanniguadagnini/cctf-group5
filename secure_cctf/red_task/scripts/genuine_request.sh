#!/bin/bash

USER="marco"
PASS="polo"

curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register"

REQUESTS=1

while true
do
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=2147483647" &
    sleep 1
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance" &
    sleep 1
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=withdraw&amount=2147483647" &
    sleep 1
    curl -w "time_total: %{time_total}s\n" -o /dev/null -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=balance" &
    sleep 1
    N=$((REQUESTS*4))
    REQUESTS=$((REQUESTS+1))
    echo "Sent $N requests to the remote server"
    echo "-------------------------------------"
done