#!/bin/bash

# nano /root/.my.cnf
# [client] 
# user="dbadmuser"
# password="dbadmpass"

# Load .env
if [ -f .env ]; then
	# Load Environment Variables
	export $(grep -v '^#' .env | xargs)
fi

# Verify for LOCALSITENAME
if [[ ! -v LOCALSITENAME ]] || [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is not set or is set to the empty string!"
	PGDBNAME=$(pwgen 10 -s1vA0) # Generates ramdon db name
else
	PGDBNAME=$LOCALSITENAME
fi

datastr=$(date) # Generates datastr
ENVFILE='.'${PGDBNAME}'.env'
echo "" >> $ENVFILE
echo "# ----- $datastr -----" >> $ENVFILE


echo ""
echo "##---------------------- GENERATES NEW DB -------------------------##"
echo ""

#PGDBUSER=$(pwgen -s 10 -1 -v -A -0) # Generates ramdon user name
PGDBUSER=$PGDBNAME # Use same generated ramdon user name
PGDBPASS=$(pwgen -s 14 1) # Generates ramdon password for db user
# PGDBPASS="$(openssl rand -base64 12)"
echo "DB Name: $PGDBNAME"
echo "DB User: $PGDBUSER"
echo "DB Pass: $PGDBPASS"
echo ""

# Save Environment Variables
echo "" >> $ENVFILE
echo "# DataBase credentials" >> $ENVFILE
echo "PGDBNAME=\"$PGDBNAME\"" >> $ENVFILE
echo "PGDBUSER=\"$PGDBUSER\"" >> $ENVFILE
echo "PGDBPASS=\"$PGDBPASS\"" >> $ENVFILE

touch /tmp/createPGDBUSER.sql
echo $'CREATE DATABASE '${PGDBNAME}$';' >> /tmp/createPGDBUSER.sql
echo $'CREATE USER '${PGDBUSER}$' WITH PASSWORD \''${PGDBPASS}$'\';' >> /tmp/createPGDBUSER.sql
echo $'GRANT ALL PRIVILEGES ON DATABASE '${PGDBNAME}$' TO '${PGDBUSER}$';' >> /tmp/createPGDBUSER.sql
cat /tmp/createPGDBUSER.sql

sudo -i -u postgres psql -f /tmp/createPGDBUSER.sql
rm /tmp/createPGDBUSER.sql


echo ""
echo "##------------ $ENVFILE -----------------##"
cat $ENVFILE
echo "##------------ $ENVFILE -----------------##"
echo ""

