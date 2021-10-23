#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then	
	export $(grep -v '^#' .env | xargs)
fi

datastr=$(date) # Generates datastr
echo "" >> .env
echo "# ----- $datastr -----" >> .env

# Verify for MDLHOME
if [[ ! -v MDLHOME ]]; then
    echo "MDLHOME is not set"
        exit 1
elif [[ -z "$MDLHOME" ]]; then
    echo "MDLHOME is set to the empty string"
        exit 1
else
    echo "MDLHOME has the value: $MDLHOME"	
fi

# Verify for MDLDATA
if [[ ! -v MDLDATA ]]; then
    echo "MDLDATA is not set"
        exit 1
elif [[ -z "$MDLDATA" ]]; then
    echo "MDLDATA is set to the empty string"
        exit 1
else
    echo "MDLDATA has the value: $MDLDATA"	
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
	exit 1
fi

# Fix permissions
chmod 740 $MDLHOME/admin/cli/cron.php
chown www-data:www-data -R $MDLHOME
chown www-data:www-data -R $MDLDATA


