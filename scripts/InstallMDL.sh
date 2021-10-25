#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then	
	export $(grep -v '^#' .env | xargs)
fi

# Verify for LOCALSITENAME
if [[ ! -v LOCALSITENAME ]] || [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is not set or is set to the empty string!"
	echo "Choose site to use:"
	ls /etc/apache2/sites-enabled/
	echo "export LOCALSITEFOLDER="
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
	LOCALSITEURL=${LOCALSITENAME}'.local' # Generates ramdon site name
else
    echo "LOCALSITEURL has the value: $LOCALSITEURL"
fi

datastr=$(date) # Generates datastr
echo "" >> $ENVFILE
echo "# ----- $datastr -----" >> $ENVFILE

# Verify for MDLHOME
if [[ ! -v MDLHOME ]] || [[ -z "$MDLHOME" ]]; then
    echo "MDLHOME is not set or is set to the empty string!"
    exit 1
else
    echo "MDLHOME has the value: $MDLHOME"	
fi

# Verify for MDLDATA
if [[ ! -v MDLDATA ]] || [[ -z "$MDLDATA" ]]; then
    echo "MDLDATA is not set or is set to the empty string!"
        exit 1
else
    echo "MDLDATA has the value: $MDLDATA"	
fi

# Verify if folder exists
if [[ -d "$MDLHOME" ]]; then
	echo "$MDLHOME exists on your filesystem."
else
    echo "$MDLHOME NOT exists on your filesystem."
	exit 1
fi

# Verify if folder exists
if [[ -d "$MDLDATA" ]]; then
	echo "$MDLDATA exists on your filesystem."
else
    echo "$MDLDATA NOT exists on your filesystem."
	exit 1
fi


# Verify for DBNAME
if [[ ! -v DBNAME ]] || [[ -z "$DBNAME" ]] then
    echo "DBNAMEis not set or is set to the empty string!"
    exit 1
else
    echo "DBNAME has the value: $DBNAME"	
fi

# Verify for DBUSER
if [[ ! -v DBUSER ]] || [[ -z "$DBUSER" ]]; then
    echo "DBUSER is not set or is set to the empty string!"
    exit 1
else
    echo "DBUSER has the value: $DBUSER"	
fi

# Verify for DBPASS
if [[ ! -v DBPASS ]] || [[ -z "$DBPASS" ]]; then
    echo "DBPASS is not set or is set to the empty string!"
    exit 1
else
    echo "DBPASS has the value: $DBPASS"	
fi

# Fix permissions
chmod 740 $MDLHOME/admin/cli/cron.php
chown www-data:www-data -R $MDLHOME
chown www-data:www-data -R $MDLDATA


# Create config.php file
if [[ -f "$MDLHOME/config.php" ]]; then
    echo "$MDLHOME/config.php exists."
else
	echo "$MDLHOME/config.php NOT exists."
fi

# https://docs.moodle.org/311/en/Environment_-_max_input_vars

# The password must have at least 8 characters, at least 1 digit(s), at least 1 lower case letter(s), at least 1 upper case letter(s), at least 1 non-alphanumeric character(s) such as as *, -, or # 

# Verify for MDLADMPASS
if [[ ! -v MDLADMPASS ]] || [[ -z "$MDLADMPASS" ]]; then
    echo "MDLADMPASS is not set or is set to the empty string!"
    MDLADMPASS=$(pwgen -Bcny 8 1)
	echo "MDLADMPASS=\"$MDLADMPASS\"" >> $ENVFILE
else
    echo "MDLADMPASS has the value: $MDLADMPASS"	
fi

# cat $MDLHOME/config.php
 
 # Verify for MDLCONFIGDISTFILE
if [[ ! -v MDLCONFIGDISTFILE ]] || [[ -z "$MDLCONFIGDISTFILE" ]]; then
    echo "MDLCONFIGDISTFILE is not set or is set to the empty string!"
	MDLCONFIGDISTFILE="https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/config-dist.php"
	echo "MDLCONFIGDISTFILE=\"$MDLCONFIGDISTFILE\"" >> $ENVFILE
else
    echo "MDLCONFIGDISTFILE has the value: $MDLCONFIGDISTFILE"	
fi
 
MDLCONFIGFILE="$MDLHOME/config.php"
echo "MDLCONFIGFILE=\"$MDLCONFIGFILE\"" >> $ENVFILE
 
# Copy moodle config file
wget $MDLCONFIGDISTFILE -O $MDLCONFIGFILE

sed -i 's/mydbname/'"$DBNAME"'/' $MDLCONFIGFILE # Configure DB Name
sed -i 's/mydbuser/'"$DBUSER"'/' $MDLCONFIGFILE # Configure DB user
sed -i 's/mydbpass/'"$DBPASS"'/' $MDLCONFIGFILE # Configure DB password
sed -i 's/mysiteurl/https:\/\/'"$LOCALSITEURL"'/' $MDLCONFIGFILE # Configure url
sed -i 's/mydatafolder/'"${MDLDATA##*/}"'/' $MDLCONFIGFILE # Configure Moodle Data directory

 # Verify for MDLCONFIGDISTFILE
if [[ ! -v MDLDEFAULTSDISTFILE ]] || [[ -z "$MDLDEFAULTSDISTFILE" ]]; then
    echo "MDLDEFAULTSDISTFILE is not set or is set to the empty string!"
	MDLDEFAULTSDISTFILE="https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/defaults-dist.php"
	echo "MDLDEFAULTSDISTFILE=\"$MDLDEFAULTSDISTFILE\"" >> $ENVFILE
else
    echo "MDLDEFAULTSDISTFILE has the value: $MDLDEFAULTSDISTFILE"	
fi

MDLDEFAULTSFILE="$MDLHOME/local/defaults.php"
echo "MDLDEFAULTSFILE=\"$MDLDEFAULTSFILE\"" >> $ENVFILE

 # Copy moodle defaults file
wget $MDLDEFAULTSDISTFILE -O $MDLDEFAULTSFILE
sed -i 's/myadmpass/'"$MDLADMPASS"'/' $MDLDEFAULTSFILE # Set password in file

MDLADMEMAIL='admin@'$LOCALSITEURL
mdlver=$(cat $MDLHOME/version.php | grep '$release' | cut -d\' -f 2) # Gets Moodle Version
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/install_database.php --lang=pt_br --adminpass=$MDLADMPASS --agree-license --adminemail=$MDLADMEMAIL --fullname="Moodle $mdlver" --shortname="Moodle $mdlver"

# Add cron for moodle - Shows: no crontab for root
(crontab -l | grep . ; echo -e "*/1 * * * * /usr/bin/php  $MDLHOME/admin/cli/cron.php >/dev/null\n") | crontab -

# rm $MDLCONFIGFILE
# rm $MDLDEFAULTSFILE

echo ""
echo "##----------- NEW MOODLE SITE URL ----------------##"
echo ""

echo "https://$LOCALSITEURL"

echo ""
echo "##------------------------------------------------##"
echo ""

cd ~
echo ""
echo "##------------ $ENVFILE -----------------##"
cat $ENVFILE
echo "##------------ $ENVFILE -----------------##"