#!/bin/bash

# Set web server (apache)
# export ADMDBUSER="dbadmuser"
# export ADMDBPASS="dbadmpass"

# nano /root/.my.cnf
# [client] 
# user="dbadmuser"
# password="dbadmpass"

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
   echo "/root/.my.cnf exists"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
	if [[ ! -v ADMDBUSER ]]; then
		echo "ADMDBUSER is not set"
			exit 1
	elif [[ -z "$ADMDBUSER" ]]; then
		echo "ADMDBUSER is set to the empty string"
			exit 1
	else
		echo "ADMDBUSER was set"
	fi

	if [[ ! -v ADMDBPASS ]]; then
		echo "ADMDBPASS is not set"
			exit 1
	elif [[ -z "$ADMDBPASS" ]]; then
		echo "ADMDBPASS is set to the empty string"
			exit 1
	else
		echo "ADMDBPASS was set"
	fi
fi

echo ""
echo "##---------------------- GENERATES NEW DB -------------------------##"
echo ""
DBNAME=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon db name
#DBUSER=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon user name
DBUSER=$DBNAME # Use same generated ramdon user name
DBPASS=$(pwgen -s 14 1) # Generates ramdon password for db user
# DBPASS="$(openssl rand -base64 12)"
echo "DB Name: $DBNAME"
echo "DB User: $DBUSER"
echo "DB Pass: $DBPASS"
echo ""


# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
    mysql -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASS}';"
    mysql -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost';"
    mysql -e "FLUSH PRIVILEGES;"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "CREATE USER ${DBUSER}@localhost IDENTIFIED BY '${DBPASS}';"
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBUSER}'@'localhost';"
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "FLUSH PRIVILEGES;"
fi

