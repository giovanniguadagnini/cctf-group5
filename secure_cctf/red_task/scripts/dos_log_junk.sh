#!/bin/bash

SEED=$( cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 40000 | head -n 1 )
changeValues=0

while true
do
    if [[ $changeValues -eq 0 ]]
    then 
        START=$((1 + $RANDOM % 39000))
        END=$((7 + $RANDOM % 12 + START))
        USER=$( echo $SEED | cut -c$START-$END )
        
        START=$((1 + $RANDOM % 39000))
        END=$((7 + $RANDOM % 20 + START))
        PASS=$( echo $SEED | cut -c$START-$END )

        AMOUNT=$((10 + $RANDOM % 90))

        START=$((1 + $RANDOM % 39000))
        END=$((4 + START))
        JUNK_FIELD_NAME=$( echo $SEED | cut -c$START-$END )

        JUNK_LEN=$(( 2048 - ${#USER} - ${#PASS} - (26+6+21+10) ))
        START=$((1 + $RANDOM % 38000))
        END=$((JUNK_LEN + START))
        JUNK=$( echo $SEED | cut -c$START-$END )
    fi

    curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=deposit&amount=$AMOUNT&$JUNK_FIELD_NAME=$JUNK" >/dev/null &

    changeValues=$(( (changeValues + 1) % 100 ))
done