#!/bin/bash

echo "Update and Upgrade System..."
sudo apt-get update 
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef

echo "Autoremove and Autoclean System..."
sudo apt-get autoremove -y && sudo apt-get autoclean -y

echo "Add locales pt_BR, en_US, en_AU..."
sudo sed -i '/^#.* pt_BR.* /s/^#//' /etc/locale.gen
sudo sed -i '/^#.* en_US.* /s/^#//' /etc/locale.gen
sudo sed -i '/^#.* en_AU.* /s/^#//' /etc/locale.gen
sudo locale-gen

echo "Set timezone and locale..." 
timedatectl set-timezone America/Sao_Paulo
update-locale LANG=pt_BR.UTF-8 # Requires reboot

echo "Install apache2..."
sudo add-apt-repository ppa:ondrej/apache2 -y && sudo apt-get update
sudo apt-get install -y apache2
sudo a2enmod ssl rewrite headers deflate

echo "Redirect http to https..."
sed -i '/<\/VirtualHost>/i \
RewriteEngine On \
RewriteCond %{HTTPS} off \
RewriteRule (.*) https:\/\/%{HTTP_HOST}%{REQUEST_URI}' /etc/apache2/sites-available/000-default.conf

echo "Create selfsigned certificate..."
LOCALSITEURL=$(hostname)
openssl req -x509 -out /etc/ssl/certs/${LOCALSITEURL}-selfsigned.crt -keyout /etc/ssl/private/${LOCALSITEURL}-selfsigned.key \
 -newkey rsa:2048 -nodes -sha256 \
 -subj '/CN='${LOCALSITEURL}$'' -extensions EXT -config <( \
  printf "[dn]\nCN='${LOCALSITEURL}$'\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:'${LOCALSITEURL}$'\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
  
echo "Change default site certificate..."
sed -i 's/ssl-cert-snakeoil.pem/'${LOCALSITEURL}$'-selfsigned.crt/' /etc/apache2/sites-available/default-ssl.conf
sed -i 's/ssl-cert-snakeoil.key/'${LOCALSITEURL}$'-selfsigned.key/' /etc/apache2/sites-available/default-ssl.conf

echo "Enable site certificate..."
sudo a2ensite default-ssl.conf
sudo systemctl reload apache2

echo "Install some sys utils..."
sudo apt-get install -y git p7zip-full

echo "Install python..."
sudo apt-get install -y python3

# Select php version
# sudo update-alternatives --config php

echo "To be able to generate graphics from DOT files, you must have installed the dot executable..."
sudo apt-get install -y graphviz

echo "Install pdftoppm poppler-utils - Poppler is a PDF rendering library based on the xpdf-3.0 code base."
sudo apt-get install -y poppler-utils

echo "To use spell-checking within the editor, you MUST have aspell 0.50 or later installed on your server..."
sudo apt-get install -y aspell dictionaries-common libaspell15 aspell-en aspell-pt-br aspell-doc spellutils

echo "Add the following PHP PPA repository"
sudo add-apt-repository ppa:ondrej/php -y && sudo apt-get update

echo "Install php7.4 for apache..."
sudo apt-get install -y php7.4 libapache2-mod-php7.4

echo "Install php7.4 extensions..."
sudo apt-get install -y php7.4-curl php7.4-zip php7.4-intl php7.4-xmlrpc php7.4-soap php7.4-xml php7.4-gd php7.4-ldap php7.4-common php7.4-cli php7.4-mbstring php7.4-mysql php7.4-imagick php7.4-json php7.4-readline php7.4-tidy

# Cache related
sudo apt-get install -y php7.4-redis php7.4-memcached php7.4-apcu php7.4-opcache php7.4-mongodb

echo "Restart apache server..."
sudo service apache2 restart

# Set PHP ini
sed -i 's/memory_limit =.*/memory_limit = 512M/' /etc/php/7.4/apache2/php.ini
sed -i 's/post_max_size =.*/post_max_size = 128M/' /etc/php/7.4/apache2/php.ini
sed -i 's/upload_max_filesize =.*/upload_max_filesize = 128M/' /etc/php/7.4/apache2/php.ini
sed -i 's/;max_input_vars =.*/max_input_vars = 5000/' /etc/php/7.4/apache2/php.ini

# populate site folder with index.php and phpinfo
touch /var/www/html/index.php
echo '<?php  phpinfo(); ?>' >> /var/www/html/index.php

systemctl reload apache2
cd /var/www/html
ls -l
sudo mv index.html index.html.bkp

echo "Install pwgen..."
# https://www.2daygeek.com/5-ways-to-generate-a-random-strong-password-in-linux-terminal/
sudo apt-get install -y pwgen # Install pwgen

echo "Install MariaDB..."
sudo apt-get install -y software-properties-common dirmngr apt-transport-https
sudo apt-key adv --fetch-keys 'https://mariadb.org/mariadb_release_signing_key.asc'
sudo add-apt-repository 'deb [arch=amd64,arm64,ppc64el,s390x] https://espejito.fder.edu.uy/mariadb/repo/10.6/ubuntu focal main'

sudo apt-get update
sudo apt-get install -y mariadb-server

DBROOTPASS=$(pwgen -s 14 1) # Generates ramdon password for db user
echo "mysql root pass is: "$DBROOTPASS
# Make sure that NOBODY can access the server without a password
mysql -e "UPDATE mysql.user SET Password = PASSWORD('"$DBROOTPASS"') WHERE User = 'root'"
# Kill the anonymous users
mysql -e "DROP USER ''@'localhost'"
# Because our hostname varies we'll use some Bash magic here.
mysql -e "DROP USER ''@'$(hostname)'"
# Kill off the demo database
mysql -e "DROP DATABASE test"
# Make our changes take effect
mysql -e "FLUSH PRIVILEGES"

sudo echo "\
[client]
default-character-set = utf8mb4

[mysqld]
innodb_file_format = Barracuda
innodb_file_per_table = 1
innodb_large_prefix

character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
skip-character-set-client-handshake

[mysql]
default-character-set = utf8mb4" >> /etc/mysql/my.cnf


#echo "Install TeX..."
#sudo apt-get install -y texlive imagemagick

#echo "Install Universal Office Converter..."
#sudo apt-get install -y unoconv
#sudo chown www-data /var/www

# echo "Install maxima, gcc and gnuplot (Stack question type for Moodle) ..."
# sudo apt-get install -y maxima gcc gnuplot

#sudo apt install memcached libmemcached-tools

# https://redis.io/download
# sudo apt-get install redis-server
# sudo systemctl enable redis-server.service
# sudo nano /etc/redis/redis.conf
# sudo systemctl restart redis-server.service


# https://docs.mongodb.com/manual/tutorial/install-mongodb-on-ubuntu/
#wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -
#echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/5.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list
#sudo apt-get update
#sudo apt-get install -y mongodb-org
#sudo systemctl enable mongod
#sudo systemctl start mongod

echo "Update and Upgrade System..."
sudo apt-get update 
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::=--force-confold -o Dpkg::Options::=--force-confdef

echo "Autoremove and Autoclean System..."
sudo apt-get autoremove -y && sudo apt-get autoclean -y

