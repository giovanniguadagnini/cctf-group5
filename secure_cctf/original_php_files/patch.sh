#!/bin/bash

if [ "$#" -ne 2 ];then
    echo "Usage: ./patch.sh <original> <patch>";
    exit
fi

cp $1 $1.old

patch $1 -i $2
