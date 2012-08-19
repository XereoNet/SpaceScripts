#!/bin/bash

# URL to the Download Directory, NOT the file
URL="http://dl.xereo.net/open/"
# Filename derp
FILENAME="1.2.rc-full.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/mac_install.sh"
# URL to the unzip binaries
URLUZ="http://dl.nope.bz/sb/.bin/unzip"

if [ "$(id -u)" != "0" ]
then
	echo "This script must be run as root!" 1>&2
	exit 1
fi

if [ "$(pwd)" = '/' ] || [ "$(pwd)" = '/home' ] || [ "$(pwd)" = '/opt' ] || pwd | grep '^/Applications' > /dev/null \
	|| pwd | grep '^/Developer' > /dev/null || pwd | grep '^/Library' > /dev/null \
	|| pwd | grep '^/Network' > /dev/null || pwd | grep '^/System' > /dev/null \
	|| pwd | grep '^/Volumes' > /dev/null || pwd | grep '^/bin' > /dev/null || pwd | grep '^/cores' > /dev/null \
	|| pwd | grep '^/dev' > /dev/null || pwd | grep '^/efi' > /dev/null || pwd | grep '^/lost+found' > /dev/null \
	|| pwd | grep '^/net' > /dev/null || pwd | grep '^/opt' > /dev/null || pwd | grep '^/private' > /dev/null \
	|| pwd | grep '^/sbin' > /dev/null || pwd | grep '^/usr' > /dev/null || pwd | grep '^/home/[^/]*$' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Desktop' > /dev/null || pwd | grep '^/home/[^/]*/Videos' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Pictures' > /dev/null || pwd | grep '^/home/[^/]*/Documents' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Music' > /dev/null || pwd | grep '^/home/[^/]*/Templates' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Downloads' > /dev/null
then
	echo "Anti bumblebee security system engaged."
	echo "Please execute the script in another directory, you were about to delete important files, and we don't want that :("
	exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
	echo "Are you SURE you want to upgrade Spacebukkit in this directory? Everything (except your settings) in it will be deleted! [Y/n] \c"
	read inputline
	if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
	then
		echo "Exiting..."
		exit 0
	fi
	echo "Deleting old files...\c"
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
	echo "\t\tOK"

	echo "Downloading Spacebukkit...\c"
	i=0
	success=0
	while [ $i -lt 5 ] && [ $success -eq 0 ]
	do
		if curl --silent "$URL$FILENAME" -o $FILENAME > /dev/null
		then
			success=1
		else
			(( $i += 1 ))
		fi
	done
	if [ $success -eq 1 ]
	then
		echo "\t\tOK"
	else
		echo "\t\tERROR"
		echo "Could not download the panel! Maybe try again or ask us for support!\n"
		exit 1
	fi

	echo "Unzipping...\c"
	if unzip -nqq $FILENAME > /dev/null
	then
		chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
		chown -R www:www *
		rm $FILENAME
		rm app/tmp/inst.txt
		curl --silent $INSTURL -o mac_install.sh > /dev/null
		echo "\t\t\tOK"
		echo "\nEverything has been updated correctly! Enjoy Spacebukkit!\n"
		exit 0
	else
		echo "\t\t\tERROR"
		echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
		exit 1
	fi
fi

echo "Are you SURE the current directory you are in (`pwd`) is the directoy the script is in and also the directory where you want to install Spacebukkit? [y/N]"
read inputline
if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
then
	echo "Exiting."
	exit 0
fi

echo "Downloading Spacebukkit now...\c"
i=0
success=0
while [ $i -lt 5 ] && [ $success -eq 0 ]
do
	if curl --silent "$URL$FILENAME" -o $FILENAME > /dev/null
	then
		success=1
	else
		(( $i += 1 ))
	fi
done
if [ $success -eq 1 ]
then
	echo "\tOK"
else
	echo "\tERROR"
	echo "Could not download the panel! Maybe try again or ask us for support!\n"
	exit 1
fi

echo "Unzipping...\c"
if unzip -oqq $FILENAME > /dev/null
then
	chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
	chown -R www:www *
	rm $FILENAME
	echo "\t\t\tOK"
	echo "\nEverything has been unzipped, modded and owned correctly!\nYou now have a perfect copy of the awesome Spacebukkit Panel! \o/ *!party!* \o/\n"
	exit 0
else
	echo "\t\t\tERROR"
	echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	exit 1
fi
