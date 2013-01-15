#!/bin/bash

function ECHO
{
	print=$1
	echo -e $print
}

# URL to the Download Directory, NOT the file
URL="https://github.com/downloads/SpaceDev/SpaceBukkitPanel/"
# Filename derp
FILENAME="spacebukkit.1.2.00.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/mac_install.sh"

if [ "$(id -u)" != "0" ]
then
	ECHO "This script must be run as root!" 1>&2
	exit 1
fi

if [ "$(pwd)" = '/' ] || [ "$(pwd)" = '/home' ] || [ "$(pwd)" = '/opt' ] || pwd | grep '^/Applications' > /dev/null \
	|| pwd | grep '^/Developer' > /dev/null || pwd | grep '^/Library' > /dev/null \
	|| pwd | grep '^/Network' > /dev/null || pwd | grep '^/System' > /dev/null \
	|| pwd | grep '^/Volumes' > /dev/null || pwd | grep '^/bin' > /dev/null || pwd | grep '^/cores' > /dev/null \
	|| pwd | grep '^/dev' > /dev/null || pwd | grep '^/efi' > /dev/null || pwd | grep '^/lost+found' > /dev/null \
	|| pwd | grep '^/net' > /dev/null || pwd | grep '^/opt' > /dev/null || pwd | grep '^/private' > /dev/null \
	|| pwd | grep '^/sbin' > /dev/null || pwd | grep '^/usr' > /dev/null || pwd | grep '^/home/[^/]*$' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Desktop$' > /dev/null || pwd | grep '^/home/[^/]*/Videos' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Pictures' > /dev/null || pwd | grep '^/home/[^/]*/Documents$' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Music' > /dev/null || pwd | grep '^/home/[^/]*/Templates' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Downloads$' > /dev/null
then
	ECHO "Anti bumblebee security system engaged."
	ECHO "Please execute the script in another directory, you were about to delete important files, and we don't want that :("
	exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
	ECHO "Are you SURE you want to upgrade Spacebukkit in this directory? Everything (except your settings) in it will be deleted! [Y/n] \c"
	read inputline
	if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
	then
		ECHO "Exiting..."
		exit 0
	fi
	ECHO "Deleting old files...\c"
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
	ECHO "\t\tOK"

	ECHO "Downloading Spacebukkit...\c"
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
		ECHO "\t\tOK"
	else
		ECHO "\t\tERROR"
		ECHO "Could not download the panel! Maybe try again or ask us for support!\n"
		exit 1
	fi

	ECHO "Unzipping...\c"
	if unzip -nqq $FILENAME > /dev/null
	then
		chmod -R 777 app/tmp app/webroot app/Config/database* app/configuration*
		chown -R www:www *
		rm $FILENAME
		rm app/tmp/inst.txt
		curl --silent $INSTURL -o mac_install.sh > /dev/null
		ECHO "\t\t\tOK"
		ECHO "\nEverything has been updated correctly! Enjoy Spacebukkit!\n"
		exit 0
	else
		ECHO "\t\t\tERROR"
		ECHO "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
		exit 1
	fi
fi

ECHO "Are you SURE the current directory you are in (`pwd`) is the directoy the script is in and also the directory where you want to install Spacebukkit? [y/N]"
read inputline
if [ "$inputline" = "N" ] || [ "$inputline" = "n" ] || [ "$inputline" = "no" ] || [ "$inputline" = "NO" ] || [ "$inputline" = "No" ] || [ "$inputline" = "nO" ] || [ "$inputline" = "" ]
then
	ECHO "Exiting."
	exit 0
fi

ECHO "Downloading Spacebukkit now...\c"
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
	ECHO "\tOK"
else
	ECHO "\tERROR"
	ECHO "Could not download the panel! Maybe try again or ask us for support!\n"
	exit 1
fi

ECHO "Unzipping...\c"
if unzip -oqq $FILENAME > /dev/null
then
	chmod -R 777 SpaceDev-SpaceBukkitPanel-*/app/tmp SpaceDev-SpaceBukkitPanel-*/app/webroot SpaceDev-SpaceBukkitPanel-*/app/Config/database*
	chown -R www:www ./SpaceDev-SpaceBukkitPanel-*/*
	cp -r SpaceDev-SpaceBukkitPanel-*/* ./
	cp SpaceDev-SpaceBukkitPanel-*/.htaccess ./
	rm -r SpaceDev-SpaceBukkitPanel-*
	rm $FILENAME
	ECHO "\t\t\tOK"
	ECHO "\nEverything has been unzipped, modded and owned correctly!\nYou now have a perfect copy of the awesome Spacebukkit Panel! \o/ *!party!* \o/\n"
	exit 0
else
	ECHO "\t\t\tERROR"
	ECHO "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	exit 1
fi
