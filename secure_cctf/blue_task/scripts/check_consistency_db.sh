#!/bin/bash
FILENAME1=test_consitency1.txt
FILENAME2=test_consitency2.txt

echo "Check db consistency is running ..."
COUNT=1
while true
do
    echo "SELECT user, SUM(amount) AS balance FROM ctf2.transfers GROUP BY (user) HAVING balance < 0;" | mysql -u"root" -p"@ThisIsASecurePassword|" 1>$FILENAME1 2> /dev/null
    echo "SELECT user FROM ctf2.transfers WHERE user NOT IN (SELECT user FROM ctf2.users) GROUP BY user;" | mysql -u"root" -p"@ThisIsASecurePassword|" 1>$FILENAME2 2> /dev/null
    if [ -s $FILENAME1 ]
    then
        echo "ATTENTION! Detected user/s with negative balance! ($COUNT)"
        cat $FILENAME1
    fi
    if [ -s $FILENAME2 ]
    then
        echo "ATTENTION! Detected transaction of a user/s not inserted in the user table! ($COUNT)"
        cat $FILENAME2
    fi

    if [ ! -s $FILENAME1 ] && [ ! -s $FILENAME2 ]
    then
        echo "No consistency problem detected! ($COUNT)"
    fi

    sleep 5;
    rm -rf $FILENAME1
    rm -rf $FILENAME2
    echo "-------------------------------"
    COUNT=$((COUNT+1))
done
