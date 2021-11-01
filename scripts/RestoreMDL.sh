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
	echo "export LOCALSITENAME="
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

# Verify for DBBKPFILE,  DATABKPFILE and HTMLBKPFILE
if [[ ! -v DBBKPFILE ]] || [[ -z "$DBBKPFILE" ]] || [[ ! -v DATABKPFILE ]] || [[ -z "$DATABKPFILE" ]] || [[ ! -v HTMLBKPFILE ]] || [[ -z "$HTMLBKPFILE" ]]; then
    echo "DBBKPFILE or DATABKPFILE or HTMLBKPFILE is not set or is set to the empty string!"
    exit 1
else
	echo "DBBKPFILE has the value: $DBBKPFILE"
	echo "DATABKPFILE has the value: $DATABKPFILE"	
    echo "HTMLBKPFILE has the value: $HTMLBKPFILE"	
fi

# Verify if files exists
if [[ -f "$DBBKPFILE" ]] && [[ -f "$DATABKPFILE" ]] && [[ -f "$HTMLBKPFILE" ]]; then
	echo "DBBKPFILE and DATABKPFILE and HTMLBKPFILE exists on your filesystem."
else
    echo "DBBKPFILE or DATABKPFILE or HTMLBKPFILE NOT exists on your filesystem."
	exit 1
fi

TMPFOLDER=/tmp/$LOCALSITENAME
if [[ -d "$TMPFOLDER" ]]; then
	rm -rf $TMPFOLDER
fi

mkdir $TMPFOLDER

# Verify file integrity 
md5sum -c $DATABKPFILE.md5
if [[ $? -ne 0 ]]; then
    echo "Error: md5sum -c $DATABKPFILE.md5"
    exit 1
else
	tar xvzf $DATABKPFILE -C $TMPFOLDER
fi

md5sum -c $HTMLBKPFILE.md5
if [[ $? -ne 0 ]]; then
    echo "Error: md5sum -c $HTMLBKPFILE.md5"
    exit 1
else
	tar xvzf $HTMLBKPFILE -C $TMPFOLDER
fi

md5sum -c $DBBKPFILE.md5
if [[ $? -ne 0 ]]; then
    echo "Error: md5sum -c $DBBKPFILE.md5"
    exit 1
else
	cd $TMPFOLDER
	gunzip -c $DBBKPFILE
fi

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



echo "Kill all user sessions..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/kill_all_sessions.php

echo "Activating Moodle Maintenance Mode in..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/maintenance.php --enable


echo "disable the maintenance mode..."
sudo -u www-data /usr/bin/php $MDLHOME/admin/cli/maintenance.php --disable


