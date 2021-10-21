#!/bin/bash

# Set web server (apache)
# export LOCALSITENAME="devtest.local"
# export LOCALSITEFOLDER="devtest"


if [[ ! -v LOCALSITENAME ]]; then
    echo "LOCALSITENAME is not set"
        exit 1
elif [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is set to the empty string"
        exit 1
else
    echo "LOCALSITENAME has the value: $LOCALSITENAME"
fi

if [[ ! -v LOCALSITEFOLDER ]]; then
    echo "LOCALSITEFOLDER is not set"
        exit 1
elif [[ -z "$LOCALSITEFOLDER" ]]; then
    echo "LOCALSITEFOLDER is set to the empty string"
        exit 1
else
    echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"
fi


# systemctl status apache2.service --no-pager --lines=2

# Enable site
sudo a2dissite ${LOCALSITENAME}-ssl.conf
sudo systemctl reload apache2

# remove apache files
rm /etc/apache2/sites-available/${LOCALSITENAME}-ssl.conf /etc/ssl/certs/${LOCALSITENAME}-selfsigned.crt /etc/ssl/private/${LOCALSITENAME}-selfsigned.key

# Remove folder
rm -rf /var/www/html/${LOCALSITEFOLDER}


systemctl status apache2.service --no-pager --lines=2

IP4STR=$(ip -4 addr show enp0s3 | grep -oP "(?<=inet ).*(?=/)")
echo ""
echo "Remove $IP4STR $LOCALSITENAME from %WINDIR%\System32\drivers\etc\hosts "
