#!/bin/sh

sudo mysql -e "use ctf2; UPDATE users SET pass='RANDOMdaZilWk8WMdi' WHERE pass='abcdef'; "
