#!/bin/bash

# Set web server (apache)
LOCALSITENAME="devtest.local"
LOCALSITEFOLDER="devtest"

# Enable site
sudo a2dissite ${LOCALSITENAME}-ssl.conf
sudo systemctl reload apache2

# remove apache files
rm /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf /etc/ssl/certs/${LOCALSITENAME}-selfsigned.crt /etc/ssl/private/${LOCALSITENAME}-selfsigned.key

# Remove folder
rm -rf /var/www/html/${LOCALSITEFOLDER}


