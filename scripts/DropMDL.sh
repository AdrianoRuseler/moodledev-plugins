#!/bin/bash

# Load Environment Variables
if [ -f .env ]; then	
	export $(grep -v '^#' .env | xargs)
fi

datastr=$(date) # Generates datastr
echo "" >> .env
echo "# ----- $datastr -----" >> .env


# Verify for LOCALSITENAME
if [[ ! -v LOCALSITENAME ]]; then
    echo "LOCALSITENAME is not set"
        exit 1
elif [[ -z "$LOCALSITENAME" ]]; then
    echo "LOCALSITENAME is set to the empty string"
        exit 1
else
    echo "LOCALSITENAME has the value: $LOCALSITENAME"	
fi


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
	echo "$MDLDATA exists on your filesystem and will be cleared."
	rm -rf $MDLDATA
	mkdir $MDLDATA
else
    echo "$MDLDATA NOT exists on your filesystem."
	exit 1
fi


# Verify for DBNAME
if [[ ! -v DBNAME ]]; then
    echo "DBNAME is not set"
        exit 1
elif [[ -z "$DBNAME" ]]; then
    echo "DBNAME is set to the empty string"
        exit 1
else
    echo "DBNAME has the value: $DBNAME"	
fi

# Verify for DBUSER
if [[ ! -v DBUSER ]]; then
    echo "DBUSER is not set"
        exit 1
elif [[ -z "$DBUSER" ]]; then
    echo "DBUSER is set to the empty string"
        exit 1
else
    echo "DBUSER has the value: $DBUSER"	
fi

# Verify for DBPASS
if [[ ! -v DBPASS ]]; then
    echo "DBPASS is not set"
        exit 1
elif [[ -z "$DBPASS" ]]; then
    echo "DBPASS is set to the empty string"
        exit 1
else
    echo "DBPASS has the value: $DBPASS"	
fi

# Verify for config.php file
if [[ -f "$MDLHOME/config.php" ]]; then
    echo "$MDLHOME/config.php exists and will be removed."
	rm $MDLHOME/config.php
else
	echo "$MDLHOME/config.php NOT exists."
fi

# Verify for local/defaults.php file
if [[ -f "$MDLHOME/local/defaults.php" ]]; then
    echo "$MDLHOME/local/defaults.php exists and will be removed."
	rm $MDLHOME/local/defaults.php
else
	echo "$MDLHOME/local/defaults.php NOT exists."
fi


# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
   echo "/root/.my.cnf exists"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
	if [[ ! -v ADMDBUSER ]]; then
		echo "ADMDBUSER is not set"
			exit 1
	elif [[ -z "$ADMDBUSER" ]]; then
		echo "ADMDBUSER is set to the empty string"
			exit 1
	else
		echo "ADMDBUSER was set"
	fi

	if [[ ! -v ADMDBPASS ]]; then
		echo "ADMDBPASS is not set"
			exit 1
	elif [[ -z "$ADMDBPASS" ]]; then
		echo "ADMDBPASS is set to the empty string"
			exit 1
	else
		echo "ADMDBPASS was set"
	fi
fi


# If /root/.my.cnf exists then it won't ask for root password
if [ -f /root/.my.cnf ]; then
	mysql -e "DROP DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
# If /root/.my.cnf doesn't exist then it'll ask for password   
else
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "DROP DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
    mysql -u${ADMDBUSER} -p${ADMDBPASS} -e "CREATE DATABASE ${DBNAME} /*\!40100 DEFAULT CHARACTER SET utf8 */;"
fi

