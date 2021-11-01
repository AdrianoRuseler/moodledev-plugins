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

BKPDIR="/home/ubuntu/backups/"$LOCALSITENAME  # moodle backup folder
DBBKP=$BKPDIR"/db/" # moodle database backup folder
DATABKP=$BKPDIR"/data/"  # moodle data backup folder
HTMLBKP=$BKPDIR"/html/"  # moodle html backup folder

cd $DBBKP

ls -lh $DBBKP
rm -rf *.gz
rm -rf *.gz.md5

cd $DATABKP

ls -lh $DATABKP
rm -rf *.gz
rm -rf *.gz.md5

cd $HTMLBKP

ls -lh $HTMLBKP
rm -rf *.gz
rm -rf *.gz.md5

