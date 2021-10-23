#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then	
	export $(grep -v '^#' .env | xargs)
fi

datastr=$(date) # Generates datastr
echo "" >> .env
echo "# ----- $datastr -----" >> .env

# Verify for LOCALSITEFOLDER
if [[ ! -v LOCALSITEFOLDER ]]; then
    echo "LOCALSITEFOLDER is not set"
        exit 1
elif [[ -z "$LOCALSITEFOLDER" ]]; then
    echo "LOCALSITEFOLDER is set to the empty string"
        exit 1
else
    echo "LOCALSITEFOLDER has the value: $LOCALSITEFOLDER"	
	MDLDATA="/var/www/data/$LOCALSITEFOLDER"
	echo "MDLDATA=\"$MDLDATA\"" >> .env
    MDLHOME="/var/www/html/$LOCALSITEFOLDER"
	echo "MDLHOME=\"$MDLHOME\"" >> .env
fi

# Verify if folder exists
if [[ -d "$MDLHOME" ]]; then
	echo "$MDLHOME exists on your filesystem."
else
    echo "$MDLHOME NOT exists on your filesystem."
	exit 1
fi

# Verify if folder exists
if [[ -d "$MDLDATA" ]]; then
	echo "$MDLDATA exists on your filesystem."
else
    echo "$MDLDATA NOT exists on your filesystem."
	mkdir $MDLDATA
fi

# Empty MDLHOME
if [ -z "$(ls -A $MDLHOME)" ]; then
   echo "$MDLHOME is Empty"
else
   echo "$MDLHOME is Not Empty"
   rm -rf $MDLHOME/*
fi

# Empty MDLDATA
if [ -z "$(ls -A $MDLDATA)" ]; then
   echo "$MDLDATA is Empty"
else
   echo "$MDLDATA is Not Empty"
   rm -rf $MDLDATA/*
fi

# export MDLBRANCH="MOODLE_311_STABLE"
# Verify for Moodle Branch
if [[ ! -v MDLBRANCH ]]; then
    echo "MDLBRANCH is not set"
	MDLBRANCH='master' # Set to master
	echo "MDLBRANCH=\"$MDLBRANCH\"" >> .env
elif [[ -z "$MDLBRANCH" ]]; then
    echo "MDLBRANCH is set to the empty string"
	MDLBRANCH='master' # Set to master
	echo "MDLBRANCH=\"$MDLBRANCH\"" >> .env
else
    echo "MDLBRANCH has the value: $MDLBRANCH"
fi

# Verify for Moodle Repository
if [[ ! -v MDLREPO ]]; then
    echo "MDLREPO is not set"
	MDLREPO='https://github.com/moodle/moodle.git' # Set to master
	echo "MDLREPO=\"$MDLREPO\"" >> .env
elif [[ -z "$MDLREPO" ]]; then
    echo "MDLREPO is set to the empty string"
	MDLBRANCH='https://github.com/moodle/moodle.git' # Set to master
	echo "MDLREPO=\"$MDLREPO\"" >> .env
else
    echo "MDLREPO has the value: $MDLREPO"
fi

# Clone git repository
cd /tmp
git clone --depth=1 --branch=$MDLBRANCH https://github.com/moodle/moodle.git mdlcore

mv /tmp/mdlcore/* $MDLHOME
rm -rf /tmp/mdlcore

# Fix permissions
chmod 740 $MDLHOME/admin/cli/cron.php
chown www-data:www-data -R $MDLHOME
chown www-data:www-data -R $MDLDATA


