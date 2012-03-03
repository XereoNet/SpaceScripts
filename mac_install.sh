#!/bin/bash

# URL to the Download Directory, NOT the file
URL="http://dl.xereo.net/open/"
# Filename derp
FILENAME="1.1.00-full.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/mac_install.sh"
# URL to the unzip binaries
URLUZ="http://dl.xereo.net/zip/bin/unzip"

if [ "$(id -u)" != "0" ]
then
	echo "This script must be run as root!" 1>&2
	exit 1
#elif [ -z $BASH ]
#then
#	echo "You need to execute this script in bash!" 1>&2
#	exit 1
fi

if [ "$(pwd)" = '/' ] || [ "$(pwd)" = '/home' ] || [ "$(pwd)" = '/var' ] || [ "$(pwd)" = '/var' ] \
	|| pwd | grep '^/etc' > /dev/null || pwd | grep '^/bin' > /dev/null || pwd | grep '^/boot' > /dev/null \
	|| pwd | grep '^/lib' > /dev/null || pwd | grep '^/root' > /dev/null || pwd | grep '^/sbin' > /dev/null \
	|| pwd | grep '^/bin' > /dev/null || pwd | grep '^/selinux' > /dev/null || pwd | grep '^/srv' > /dev/null \
	|| pwd | grep '^/usr' > /dev/null || pwd | grep '^/mnt' > /dev/null || pwd | grep '^/mount' > /dev/null \
	|| pwd | grep '^/media' > /dev/null || pwd | grep '^/dev' > /dev/null || pwd | grep '^/bin' > /dev/null \
	|| pwd | grep '^/sys' > /dev/null || pwd | grep '^/lib64' > /dev/null || pwd | grep '^/proc' > /dev/null \
	|| pwd | grep '^/home/[^/]*$' > /dev/null || pwd | grep '^/home/[^/]*/Desktop' > /dev/null \ 
	|| pwd | grep '^/home/[^/]*/Videos' > /dev/null || pwd | grep '^/home/[^/]*/Pictures' > /dev/null \ 
	|| pwd | grep '^/home/[^/]*/Documents' > /dev/null || pwd | grep '^/home/[^/]*/Music' > /dev/null \
	|| pwd | grep '^/home/[^/]*/Templates' > /dev/null || pwd | grep '^/home/[^/]*/Downloads' > /dev/null
then
	echo "Anti bumblebee security system engaged."
	echo "Please execute the script in another directory, you were about to delete important files, and we don't want that :("
	exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
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

	echo "Downloading SpaceCP...\c"
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
		echo "\nEverything has been updated correctly! Enjoy SpaceCP!\n"
		exit 0
	else
		echo "\t\t\tERROR"
		echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
		exit 1
	fi
fi

#dep4=0
#for i in $(find /etc/ -name php.ini -exec grep -c ^\;extension=php_gd2 {} \;)
#do
#        [ $i -eq 1 ] && dep4=1 && break
#done
#if [ $dep4 -eq 1 ]
#then
#        inputline="Y"
#        echo "You don't have PHP-gd2 enabled. SpaceCP will need it. Do you want to enable PHP-gd2 now? [Y]/n \"
#        read inputline
#        if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
#        then
#                echo "Enabling PHP-gd2...\c"
#                for i in $(find /etc/ -name php.ini -exec grep -c ^\;extension=php_gd2 {} \;)
#                do
#                        sed -i 's/\;extension=php_gd2/extension=php_gd2/' $i
#                done
#                echo "\t\tOK"
#                dep4=1
#        else
#                echo "Not enabling PHP-gd2... (You will need to do it manually)\n"
#        fi
#fi

echo "Downloading SpaceCP now...\c"
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
	echo "\nEverything has been unzipped, modded and owned correctly!\nYou now have a perfect copy of the awesome SpaceCP Panel! \o/ *!party!* \o/\n"
	exit 0
else
	echo "\t\t\tERROR"
	echo "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	exit 1
fi
