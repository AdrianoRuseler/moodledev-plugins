#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then	
	export $(grep -v '^#' .env | xargs)
fi

datastr=$(date) # Generates datastr
echo "" >> .env
echo "# ----- $datastr -----" >> .env


# Verify for LOCALSITENAME
if [[ ! -v LOCALSITENAME ]]; then
    echo "LOCALSITENAME is not set"
        exit 1
elif [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is set to the empty string"
        exit 1
else
    echo "LOCALSITENAME has the value: $LOCALSITENAME"	
fi


# Verify for MDLHOME
if [[ ! -v MDLHOME ]]; then
    echo "MDLHOME is not set"
        exit 1
elif [[ -z "$MDLHOME" ]]; then
    echo "MDLHOME is set to the empty string"
        exit 1
else
    echo "MDLHOME has the value: $MDLHOME"	
fi

# Verify for MDLDATA
if [[ ! -v MDLDATA ]]; then
    echo "MDLDATA is not set"
        exit 1
elif [[ -z "$MDLDATA" ]]; then
    echo "MDLDATA is set to the empty string"
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
if [[ ! -v DBNAME ]]; then
    echo "DBNAME is not set"
        exit 1
elif [[ -z "$DBNAME" ]]; then
    echo "DBNAME is set to the empty string"
        exit 1
else
    echo "DBNAME has the value: $DBNAME"	
fi

# Verify for DBUSER
if [[ ! -v DBUSER ]]; then
    echo "DBUSER is not set"
        exit 1
elif [[ -z "$DBUSER" ]]; then
    echo "DBUSER is set to the empty string"
        exit 1
else
    echo "DBUSER has the value: $DBUSER"	
fi

# Verify for DBPASS
if [[ ! -v DBPASS ]]; then
    echo "DBPASS is not set"
        exit 1
elif [[ -z "$DBPASS" ]]; then
    echo "DBPASS is set to the empty string"
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
if [[ ! -v MDLADMPASS ]]; then
    echo "MDLADMPASS is not set"
        MDLADMPASS=$(pwgen -Bcny 8 1)
		echo "MDLADMPASS=\"$MDLADMPASS\"" >> .env	
elif [[ -z "$MDLADMPASS" ]]; then
    echo "MDLADMPASS is set to the empty string"
        MDLADMPASS=$(pwgen -Bcny 8 1)
		echo "MDLADMPASS=\"$MDLADMPASS\"" >> .env	
else
    echo "MDLADMPASS has the value: $MDLADMPASS"	
fi


# cat $MDLHOME/config.php
 
 # Verify for MDLCONFIGDISTFILE
if [[ ! -v MDLCONFIGDISTFILE ]]; then
    echo "MDLCONFIGDISTFILE is not set"
	MDLCONFIGDISTFILE="https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/config-dist.php"
    #    exit 1
elif [[ -z "$MDLCONFIGDISTFILE" ]]; then
    echo "MDLCONFIGDISTFILE is set to the empty string"
	MDLCONFIGDISTFILE="https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/config-dist.php"
     #   exit 1
else
    echo "MDLCONFIGDISTFILE has the value: $MDLCONFIGDISTFILE"	
fi
 
MDLCONFIGFILE="$MDLHOME/config.php"
 
# Copy moodle config file
wget $MDLCONFIGDISTFILE -O $MDLCONFIGFILE

sed -i 's/mydbname/'"$DBNAME"'/' $MDLCONFIGFILE # Configure DB Name
sed -i 's/mydbuser/'"$DBUSER"'/' $MDLCONFIGFILE # Configure DB user
sed -i 's/mydbpass/'"$DBPASS"'/' $MDLCONFIGFILE # Configure DB password
sed -i 's/mysiteurl/https:\/\/'"$LOCALSITENAME"'/' $MDLCONFIGFILE # Configure url
sed -i 's/mydatafolder/'"${MDLDATA##*/}"'/' $MDLCONFIGFILE # Configure Moodle Data directory


MDLDEFAULTSDISTFILE="https://raw.githubusercontent.com/AdrianoRuseler/moodledev-plugins/main/config/defaults-dist.php"
MDLDEFAULTSFILE="$MDLHOME/local/defaults.php"
 # Copy moodle defaults file
wget $MDLDEFAULTSDISTFILE -O $MDLDEFAULTSFILE
sed -i 's/myadmpass/'"$MDLADMPASS"'/' $MDLDEFAULTSFILE # Set password in file

MDLADMEMAIL="admin@mail.local"
mdlver=$(cat $MDLHOME/version.php | grep '$release' | cut -d\' -f 2) # Gets Moodle Version
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/install_database.php --lang=pt_br --adminpass=$MDLADMPASS --agree-license --adminemail=$MDLADMEMAIL --fullname="Moodle $mdlver" --shortname="Moodle $mdlver"

# Add cron for moodle - Shows: no crontab for root
(crontab -l | grep . ; echo -e "*/1 * * * * /usr/bin/php  $MDLHOME/admin/cli/cron.php >/dev/null\n") | crontab -

# rm $MDLCONFIGFILE
# rm $MDLDEFAULTSFILE

echo ""
echo "##----------- NEW MOODLE SITE URL ----------------##"
echo ""

echo "https://$LOCALSITENAME"

echo ""
echo "##------------------------------------------------##"
echo ""

