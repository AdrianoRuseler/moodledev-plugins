#!/bin/bash

# Set web server (apache)
# export LOCALSITENAME="lpftnf"
# export LOCALSITEURL="lpftnf.local"
# export LOCALSITEFOLDER="lpftnf"
# export LOCALSITEDIR="/var/www/html/lpftnf"

# Load .env
if [ -f .env ]; then
	# Load Environment Variables
	export $(grep -v '^#' .env | xargs)
fi

if [[ ! -v LOCALSITENAME ]] || [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is not set or is set to the empty string!"
	echo "Choose site to disable:"
	ls /etc/apache2/sites-enabled/
	echo "export LOCALSITENAME="
	exit 1
else
    echo "LOCALSITENAME has the value: $LOCALSITENAME"
fi

ENVFILE='.'${LOCALSITENAME}'.env'
if [ -f $ENVFILE ]; then
	# Load Environment Variables
	export $(grep -v '^#' $ENVFILE | xargs)
	echo ""
	echo "##------------ $ENVFILE -----------------##"
	cat $ENVFILE
	echo "##------------ $ENVFILE -----------------##"
	echo ""
#	rm $ENVFILE
fi

if [[ ! -v LOCALSITEURL ]] || [[ -z "$LOCALSITEURL" ]]; then
    echo "LOCALSITEURL is not set or is set to the empty string!"
    LOCALSITEURL=${LOCALSITENAME}'.local'
else
    echo "LOCALSITEURL has the value: $LOCALSITEURL"
fi

if [ -f /etc/apache2/sites-available/${LOCALSITEURL}-ssl.conf ]; then
	echo "Site Found!"
else
	echo "Site not found!"
	echo "rm $ENVFILE # Remove env file"
	echo "Choose site to disable:"
	ls /etc/apache2/sites-enabled/
	echo "export LOCALSITENAME="
	exit 1
fi

if [[ ! -v LOCALSITEFOLDER ]] || [[ -z "$LOCALSITEFOLDER" ]]; then
    echo "LOCALSITEFOLDER is not set or is set to the empty string!"
     LOCALSITEFOLDER=${LOCALSITENAME}
else
    echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"
fi

# Enable site
sudo a2dissite ${LOCALSITEURL}-ssl.conf
sudo systemctl reload apache2

# remove apache files
rm /etc/apache2/sites-available/${LOCALSITEURL}-ssl.conf /etc/ssl/certs/${LOCALSITEURL}-selfsigned.crt /etc/ssl/private/${LOCALSITEURL}-selfsigned.key

# Remove folder
rm -rf /var/www/html/${LOCALSITEFOLDER}
# rm -rf /var/www/data/${LOCALSITEFOLDER}

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
   echo "/root/.my.cnf exists"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
	if [[ ! -v ADMDBUSER ]] || [[ -z "$ADMDBUSER" ]] || [[ ! -v ADMDBPASS ]] || [[ -z "$ADMDBPASS" ]]; then
		echo "ADMDBUSER or ADMDBPASS is not set or is set to the empty string!"
	fi
fi

# Verify for DB Credentials
if [[ ! -v DBNAME ]] || [[ -z "$DBNAME" ]] || [[ ! -v DBUSER ]] || [[ -z "$DBUSER" ]]; then
    echo "DB credentials are not set or some are set to the empty string!"
else
    echo "DBNAME has the value: $DBNAME"	
	echo "DBUSER has the value: $DBUSER"
fi

# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
    mysql -e "DROP DATABASE ${DBNAME};"
    mysql -e "DROP USER ${DBUSER};"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "DROP DATABASE ${DBNAME};"
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "DROP USER ${DBUSER};"
fi

# Verify for MDLHOME and MDLDATA
if [[ ! -v MDLHOME ]] || [[ -z "$MDLHOME" ]] || [[ ! -v MDLDATA ]] || [[ -z "$MDLDATA" ]]; then
    echo "MDLHOME or MDLDATA is not set or is set to the empty string!"
else
    echo "MDLHOME has the value: $MDLHOME"	
	echo "MDLDATA has the value: $MDLDATA"

fi

# Verify if folder exists
if [[ -d "$MDLHOME" ]] || [[ -d "$MDLDATA" ]]; then
	echo "$MDLHOME and $MDLDATA exists on your filesystem."
	# Remove folder
	rm -rf $MDLHOME
	rm -rf $MDLDATA
else
    echo "$MDLHOME or $MDLDATA NOT exists on your filesystem."
fi


echo ""
echo "##------------ SITES ENABLED -----------------##"
echo ""
ls /etc/apache2/sites-enabled/

echo ""
echo "##------ LOCAL DNS SERVICE CONFIGURATION -----##"
echo ""

IP4STR=$(ip -4 addr show enp0s3 | grep -oP "(?<=inet ).*(?=/)")
echo "Remove $IP4STR $LOCALSITEURL from %WINDIR%\System32\drivers\etc\hosts "
echo ""
echo "rm $ENVFILE # Remove env file"
echo ""
