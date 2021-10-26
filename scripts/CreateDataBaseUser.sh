#!/bin/bash

# Set web server (apache)
# export ADMDBUSER="dbadmuser"
# export ADMDBPASS="dbadmpass"

# nano /root/.my.cnf
# [client] 
# user="dbadmuser"
# password="dbadmpass"

# Load .env
if [ -f .env ]; then
	# Load Environment Variables
	export $(grep -v '^#' .env | xargs)
fi

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
   echo "/root/.my.cnf exists"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
	if [[ ! -v ADMDBUSER ]] || [[ -z "$ADMDBUSER" ]] || [[ ! -v ADMDBPASS ]] || [[ -z "$ADMDBPASS" ]]; then
		echo "ADMDBUSER or ADMDBPASS is not set or is set to the empty string!"
		exit 1
	fi
fi


# Verify for LOCALSITENAME
if [[ ! -v LOCALSITENAME ]] || [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is not set or is set to the empty string!"
	DBNAME=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon db name
fi

datastr=$(date) # Generates datastr
ENVFILE='.'${DBNAME}'.env'
echo "" >> $ENVFILE
echo "# ----- $datastr -----" >> $ENVFILE


echo ""
echo "##---------------------- GENERATES NEW DB -------------------------##"
echo ""

#DBUSER=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon user name
DBUSER=$DBNAME # Use same generated ramdon user name
DBPASS=$(pwgen -s 14 1) # Generates ramdon password for db user
# DBPASS="$(openssl rand -base64 12)"
echo "DB Name: $DBNAME"
echo "DB User: $DBUSER"
echo "DB Pass: $DBPASS"
echo ""

# Save Environment Variables
echo "" >> $ENVFILE
echo "# DataBase credentials" >> $ENVFILE
echo "DBNAME=\"$DBNAME\"" >> $ENVFILE
echo "DBUSER=\"$DBUSER\"" >> $ENVFILE
echo "DBPASS=\"$DBPASS\"" >> $ENVFILE

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


echo ""
echo "##------------ $ENVFILE -----------------##"
cat $ENVFILE
echo "##------------ $ENVFILE -----------------##"
echo ""

