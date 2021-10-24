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

if [[ ! -v LOCALSITENAME ]]; then
    echo "LOCALSITENAME is not set!"
	echo "Choose site to disable:"
	ls /etc/apache2/sites-enabled/
	echo "export LOCALSITENAME="
	exit 1
elif [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is set to the empty string!"
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


if [[ ! -v LOCALSITEURL ]]; then
    echo "LOCALSITEURL is not set"
    LOCALSITEURL=${LOCALSITENAME}'.local'
elif [[ -z "$LOCALSITEURL" ]]; then
    echo "LOCALSITEURL is set to the empty string"
     LOCALSITEURL=${LOCALSITENAME}'.local'
else
    echo "LOCALSITEURL has the value: $LOCALSITEURL"
fi

if [[ ! -v LOCALSITEFOLDER ]]; then
    echo "LOCALSITEFOLDER is not set"
     LOCALSITEFOLDER=${LOCALSITENAME}
elif [[ -z "$LOCALSITEFOLDER" ]]; then
    echo "LOCALSITEFOLDER is set to the empty string"
     LOCALSITEFOLDER=${LOCALSITENAME}
else
    echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"
fi

# systemctl status apache2.service --no-pager --lines=2

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

# Enable site
sudo a2dissite ${LOCALSITEURL}-ssl.conf
sudo systemctl reload apache2

# remove apache files
rm /etc/apache2/sites-available/${LOCALSITEURL}-ssl.conf /etc/ssl/certs/${LOCALSITEURL}-selfsigned.crt /etc/ssl/private/${LOCALSITEURL}-selfsigned.key

# Remove folder
rm -rf /var/www/html/${LOCALSITEFOLDER}
# rm -rf /var/www/data/${LOCALSITEFOLDER}

echo ""
echo "##------------ status apache2.service -----------------##"
echo ""
systemctl status apache2.service --no-pager --lines=2

# List Apache Virtual Host Configurations
echo ""
echo "##-------- List Apache Virtual Host Configurations -------------##"
echo ""
apache2ctl -S

echo ""
echo "##------------ LOCAL DNS SERVICE CONFIGURATION -----------------##"
echo ""

IP4STR=$(ip -4 addr show enp0s3 | grep -oP "(?<=inet ).*(?=/)")
echo "Remove $IP4STR $LOCALSITEURL from %WINDIR%\System32\drivers\etc\hosts "
