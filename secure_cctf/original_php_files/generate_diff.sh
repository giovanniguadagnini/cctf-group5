#!/bin/bash

if [ "$#" -ne 2 ];then
    echo "Usage: ./generate_diff.sh <original> <patched_file>";
    exit
fi

FILENAME_WITHOUT_EXTENSION=${1%.*}
rm -rf $FILENAME_WITHOUT_EXTENSION.patch
diff -Naur $1 $2 > $FILENAME_WITHOUT_EXTENSION.patch