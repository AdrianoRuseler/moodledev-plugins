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
	echo "export LOCALSITENAME=teste"
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

# Verify for MDLHOME and MDLDATA
if [[ ! -v MDLHOME ]] || [[ -z "$MDLHOME" ]] || [[ ! -v MDLDATA ]] || [[ -z "$MDLDATA" ]]; then
    echo "MDLHOME or MDLDATA is not set or is set to the empty string!"
    exit 1
else
    echo "MDLHOME has the value: $MDLHOME"	
	echo "MDLDATA has the value: $MDLDATA"
fi

# Verify if folder exists
if [[ -d "$MDLHOME" ]] && [[ -d "$MDLDATA" ]]; then
	echo "$MDLHOME and $MDLDATA exists on your filesystem."
else
    echo "$MDLHOME or $MDLDATA NOT exists on your filesystem."
	exit 1
fi

# Verify for DB Credentials
if [[ ! -v DBNAME ]] || [[ -z "$DBNAME" ]]; then
    echo "DBNAME is not set or is set to the empty string!"
    exit 1
else
    echo "DBNAME has the value: $DBNAME"	
fi

BKPDIR="/home/ubuntu/backups/"$LOCALSITENAME  # moodle backup folder
# Verify if folder NOT exists
if [[ ! -d "$BKPDIR" ]]; then
	echo "$BKPDIR NOT exists on your filesystem."
	mkdir $BKPDIR
fi

DBBKP=$BKPDIR"/db/" # moodle database backup folder
# Verify if folder NOT exists
if [[ ! -d "$DBBKP" ]]; then
	echo "$DBBKP NOT exists on your filesystem."
	mkdir $DBBKP
fi

DATABKP=$BKPDIR"/data/"  # moodle data backup folder
# Verify if folder NOT exists
if [[ ! -d "$DATABKP" ]]; then
	echo "$DATABKP NOT exists on your filesystem."
	mkdir $DATABKP
fi

HTMLBKP=$BKPDIR"/html/"  # moodle html backup folder
# Verify if folder NOT exists
if [[ ! -d "$HTMLBKP" ]]; then
	echo "$HTMLBKP NOT exists on your filesystem."
	mkdir $HTMLBKP
fi


echo "BKPDIR=\"$BKPDIR\"" >> $ENVFILE
echo "DBBKP=\"$DBBKP\"" >> $ENVFILE
echo "DATABKP=\"$DATABKP\"" >> $ENVFILE
echo "HTMLBKP=\"$HTMLBKP\"" >> $ENVFILE


filename=$(date +\%Y-\%m-\%d-\%H.\%M)

DBBKPFILE=$DBBKP$filename.sql.gz
DATABKPFILE=$DATABKP$filename.tar.gz
HTMLBKPFILE=$HTMLBKP$filename.tar.gz

echo "DBBKPFILE=\"$DBBKPFILE\"" >> $ENVFILE
echo "DATABKPFILE=\"$DATABKPFILE\"" >> $ENVFILE
echo "HTMLBKPFILE=\"$HTMLBKPFILE\"" >> $ENVFILE

echo "Kill all user sessions..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/kill_all_sessions.php

echo "Activating Moodle Maintenance Mode in..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/maintenance.php --enable


# make database backup
# mysqldump integration | gzip > integration.sql.gz

mysqldump $DBNAME | gzip > $DBBKPFILE
md5sum $DBBKPFILE > $DBBKPFILE.md5
md5sum -c $DBBKPFILE.md5

ls -lh $DBBKP

# Backup the files using tar.
tar -czf $DATABKPFILE $MDLDATA
md5sum $DATABKPFILE > $DATABKPFILE.md5
md5sum -c $DATABKPFILE.md5

ls -lh $DATABKP

tar -czf $HTMLBKPFILE $MDLHOME
md5sum $HTMLBKPFILE > $HTMLBKPFILE.md5
md5sum -c $HTMLBKPFILE.md5

ls -lh $HTMLBKP

echo "disable the maintenance mode..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/maintenance.php --disable

cd ~
echo ""
echo "##------------ $ENVFILE -----------------##"
cat $ENVFILE
echo "##------------ $ENVFILE -----------------##"

