#!/bin/bash

#Try to register empty user and password, 
#then try to register user with empty password

USER=""
PASS=""

curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register" &
sleep 1

USER="NotEmpty"

curl -sS "10.1.5.2/process.php?user=$USER&pass=$PASS&drop=register"
