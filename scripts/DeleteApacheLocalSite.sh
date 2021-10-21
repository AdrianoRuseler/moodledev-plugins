#!/bin/bash

# Set web server (apache)
LOCALSITENAME="devtest.local"
LOCALSITEFOLDER="devtest"

service apache2 status --no-pager

# Enable site
sudo a2dissite ${LOCALSITENAME}-ssl.conf
sudo systemctl reload apache2

# remove apache files
rm /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf /etc/ssl/certs/${LOCALSITENAME}-selfsigned.crt /etc/ssl/private/${LOCALSITENAME}-selfsigned.key

# Remove folder
rm -rf /var/www/html/${LOCALSITEFOLDER}


service apache2 status --no-pager


IP4STR=$(ip -4 addr show enp0s3 | grep -oP "(?<=inet ).*(?=/)")
echo ""
echo "Remove $IP4STR $LOCALSITENAME from %WINDIR%\System32\drivers\etc\hosts "

