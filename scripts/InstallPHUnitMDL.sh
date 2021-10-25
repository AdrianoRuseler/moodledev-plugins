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
    echo "LOCALSITEURL is not set or is set to the empty string"
	LOCALSITEURL=${LOCALSITENAME}'.local' # Generates ramdon site name
else
    echo "LOCALSITEURL has the value: $LOCALSITEURL"
fi

# Verify for MDLHOME
if [[ ! -v MDLHOME ]] || [[ -z "$MDLHOME" ]]; then
    echo "MDLHOME is not set or is set to the empty string!"
    exit 1
else
    echo "MDLHOME has the value: $MDLHOME"	
fi

# Verify if folder exists
if [[ -d "$MDLHOME" ]]; then
	echo "$MDLHOME exists on your filesystem."
else
    echo "$MDLHOME NOT exists on your filesystem."
	exit 1
fi

# Verify for config.php file
if [[ -f "$MDLHOME/config.php" ]]; then
    echo "$MDLHOME/config.php exists."
	MDLCONFIGFILE="$MDLHOME/config.php"
else
	echo "$MDLHOME/config.php NOT exists."
	exit 1
fi

datastr=$(date) # Generates datastr
echo "" >> $ENVFILE
echo "# ----- $datastr -----" >> $ENVFILE

# Verify for PHPUNITDATA
if [[ ! -v PHPUNITDATA ]] || [[ -z "$PHPUNITDATA" ]]; then
    echo "PHPUNITDATA is not set or is set to the empty string!"
	PHPUNITDATA=/var/www/data/phpunit/${LOCALSITENAME}
	mkdir $PHPUNITDATA
	echo "PHPUNITDATA=\"$PHPUNITDATA\"" >> $ENVFILE
else
    echo "PHPUNITDATA has the value: $PHPUNITDATA"	
fi

chown www-data:www-data -R $PHPUNITDATA
 
# add $CFG->phpunit_prefix = 'phpu_'; to your config.php file
# and $CFG->phpunit_dataroot = '/path/to/phpunitdataroot'; to your config.php file

# Verify for PHPUNITPREFIX
if [[ ! -v PHPUNITPREFIX ]] || [[ -z "$PHPUNITPREFIX" ]]; then
    echo "PHPUNITPREFIX is not set or is set to the empty string!"
	PHPUNITPREFIX=phpu_
	mkdir $PHPUNITPREFIX
	echo "PHPUNITPREFIX=\"$PHPUNITPREFIX\"" >> $ENVFILE
else
    echo "PHPUNITPREFIX has the value: $PHPUNITPREFIX"	
fi


sudo -u www-data composer -V
#php composer.phar install

# chown www-data:www-data -R /var/www

cd $MDLHOME
sudo -u www-data composer install

sed -i '/require_once*/i $CFG->phpunit_dataroot = \x27'$PHPUNITDATA'\x27;' config-dist.php # Single quote \x27
sed -i '/require_once*/i $CFG->phpunit_prefix = \x27'$PHPUNITPREFIX'\x27;\n' config-dist.php # Single quote \x27

cd ~
echo ""
echo "##------------ $ENVFILE -----------------##"
cat $ENVFILE
echo "##------------ $ENVFILE -----------------##"