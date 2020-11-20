#!/bin/bash

### Machines names
PROJECT=".securecctf-g5.OffTech"
SERVER="server$PROJECT"
GATEWAY="gateway$PROJECT"

#Create errors folder if it's not already present
if [ ! -f "errors" ]; then
   mkdir errors
fi
echo "You'll find eventual errors in errors/startup_servet.txt file."