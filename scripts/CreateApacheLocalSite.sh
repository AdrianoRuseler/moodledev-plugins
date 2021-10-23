#!/bin/bash

# systemctl status apache2.service --no-pager --lines=2

# Set web server (apache)
# export LOCALSITENAME="devtest.local"
# export LOCALSITEFOLDER="devtest"

# Load .env
if [ -f .env ]; then
	# Load Environment Variables
	export $(grep -v '^#' .env | xargs)
	cat .env
fi

RAMDONNAME=$(pwgen -s 6 -1 -v -A -0) # Generates ramdon name

if [[ ! -v LOCALSITENAME ]]; then
    echo "LOCALSITENAME is not set"
	LOCALSITENAME=${RAMDONNAME}'.local' # Generates ramdon site name
	echo "LOCALSITENAME=\"$LOCALSITENAME\"" >> .env
elif [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is set to the empty string"
	LOCALSITENAME=${RAMDONNAME}'.local' # Generates ramdon site name
	echo "LOCALSITENAME=\"$LOCALSITENAME\"" >> .env
else
    echo "LOCALSITENAME has the value: $LOCALSITENAME"
fi

if [[ ! -v LOCALSITEFOLDER ]]; then
    echo "LOCALSITEFOLDER is not set"
	LOCALSITEFOLDER=${RAMDONNAME}
	echo "LOCALSITEFOLDER=\"$LOCALSITEFOLDER\"" >> .env
elif [[ -z "$LOCALSITEFOLDER" ]]; then
    echo "LOCALSITEFOLDER is set to the empty string"
	LOCALSITEFOLDER=${RAMDONNAME}
	echo "LOCALSITEFOLDER=\"$LOCALSITEFOLDER\"" >> .env
else
    echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"
fi

echo ""
echo "LOCALSITENAME has the value: $LOCALSITENAME"
echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"


# Create new conf files
cp /etc/apache2/sites-available/default-ssl.conf.bak /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf

# Create certificate
openssl req -x509 -out /etc/ssl/certs/${LOCALSITENAME}-selfsigned.crt -keyout /etc/ssl/private/${LOCALSITENAME}-selfsigned.key \
 -newkey rsa:2048 -nodes -sha256 \
 -subj '/CN='${LOCALSITENAME}$'' -extensions EXT -config <( \
  printf "[dn]\nCN='${LOCALSITENAME}$'\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:'${LOCALSITENAME}$'\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
  
# create site folder
mkdir /var/www/html/${LOCALSITEFOLDER}

# populate site folder with index.php and phpinfo
touch /var/www/html/${LOCALSITEFOLDER}/index.php
echo '<?php  phpinfo(); ?>' >> /var/www/html/${LOCALSITEFOLDER}/index.php

# Change site folder and name
sed -i 's/\/var\/www\/html/\/var\/www\/html\/'${LOCALSITEFOLDER}$'/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf
sed -i 's/changetoservername/'${LOCALSITENAME}$'/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf

# Change site log files
sed -i 's/error.log/'${LOCALSITENAME}$'-error.log/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf
sed -i 's/access.log/'${LOCALSITENAME}$'-access.log/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf

# Change site certificate
sed -i 's/ssl-cert-snakeoil.pem/'${LOCALSITENAME}$'-selfsigned.crt/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf
sed -i 's/ssl-cert-snakeoil.key/'${LOCALSITENAME}$'-selfsigned.key/' /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf

# Enable site
sudo a2ensite ${LOCALSITENAME}-ssl.conf
sudo systemctl reload apache2

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
echo ""
echo "Add $IP4STR $LOCALSITENAME to %WINDIR%\System32\drivers\etc\hosts or run as admin:"
echo "echo $IP4STR $LOCALSITENAME >> %WINDIR%\System32\drivers\etc\hosts"


