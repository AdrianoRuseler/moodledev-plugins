#!/bin/bash

service apache2 status --no-pager


# Set web server (apache)
LOCALSITENAME="devtest.local"
LOCALSITEFOLDER="devtest"

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

service apache2 status --no-pager

IP4STR=$(ip -4 addr show enp0s3 | grep -oP "(?<=inet ).*(?=/)")
echo ""
echo "Add $IP4STR $LOCALSITENAME to %WINDIR%\System32\drivers\etc\hosts or run as admin:"
echo "echo $IP4STR $LOCALSITENAME >> %WINDIR%\System32\drivers\etc\hosts"


