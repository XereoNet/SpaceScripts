#!/bin/bash

# URL to the Download Directory, NOT the file
URL="http://dl.xereo.net/open/"
# Filename derp
FILENAME="1.1.00-full.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/macinstall.sh"
# URL to the unzip binaries
URLUZ="http://dl.xereo.net/zip/bin/unzip"

if [ "$(id -u)" != "0" ]
then
    echo "This script must be run as root!" 1>&2
    exit 1
elif [ -z $BASH ]
then
    echo "You need to execute this script in bash!" 1>&2
    exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
	echo -e "Deleting old files...\c"
	for i in $(ls -A ./ | grep -v "app")
	do
		rm -r $i
	done
	cd app/
	for i in $(ls -A ./ | grep -v "Config" | grep -v "webroot")
	do
		rm -r $i
	done
	cd webroot/
	for i in $(ls -A ./ | grep -v "servers")
	do
		rm -r $i
	done
	cd ../Config/
	for i in $(ls -A ./ | grep -v "database.php")
	do
		rm -r $i
	done
	cd ../../
	echo -e "\t\tOK"

	echo -e "Downloading SpaceCP...\c"
	i=0
	success=0
	while [ $i -lt 5 ] && [ $success -eq 0 ]
	do
	    if curl --silent "$URL$FILENAME" -o $FILENAME > /dev/null
	    then
	        success=1
	    else
	        (( i += 1 ))
	    fi
	done
	if [ $success -eq 1 ]
	then
	    echo -e "\t\tOK"
	else
	    echo -e "\t\tERROR"
	    echo -e "Could not download the panel! Maybe try again or ask us for support!\n"
	    exit 1
	fi

	echo -e "Unzipping...\c"
	if unzip -nqq $FILENAME > /dev/null
	then
	    chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
	    chown -R www:www *
	    rm $FILENAME
	    rm app/tmp/inst.txt
	    curl --silent $INSTURL -o macinstall.sh > /dev/null
	    echo -e "\t\t\tOK"
	    echo -e "\nEverything has been updated correctly! Enjoy SpaceCP!\n"
	    exit 0
	else
	    echo -e "\t\t\tERROR"
	    echo -e "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	    exit 1
	fi
fi

echo -e "Downloading SpaceCP now...\c"
i=0
success=0
while [ $i -lt 5 ] && [ $success -eq 0 ]
do
    if curl --silent "$URL$FILENAME" -o $FILENAME > /dev/null
    then
        success=1
    else
        (( i += 1 ))
    fi
done
if [ $success -eq 1 ]
then
    echo -e "\tOK"
else
    echo -e "\tERROR"
    echo -e "Could not download the panel! Maybe try again or ask us for support!\n"
    exit 1
fi

echo -e "Unzipping...\c"
if unzip -oqq $FILENAME > /dev/null
then
    chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
    chown -R www:www *
    rm $FILENAME
    echo -e "\t\t\tOK"
    echo -e "\nEverything has been unzipped, modded and owned correctly! You now have a perfect copy of the awesome SpaceCP Panel! \o/ *!party!* \o/\n"
    exit 0
else
    echo -e "\t\t\tERROR"
    echo -e "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
    exit 1
fi
