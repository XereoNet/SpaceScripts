#!/bin/sh

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
INSTURL="http://dl.nope.bz/sb/install.sh"

if [ "$(id -u)" != "0" ]
then
	ECHO "This script must be run as root!" 1>&2
	exit 1
fi

if [ "$(pwd)" = '/' ] \
        || [ "$(pwd)" = '/home' ] \
        || [ "$(pwd)" = '/var' ] \
        || [ "$(pwd)" = '/var' ] \
        || [ "$(pwd)" = '/root' ] \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/boot' > /dev/null \
        || pwd | grep '^/lib' > /dev/null \
        || pwd | grep '^/etc' > /dev/null \
        || pwd | grep '^/sbin' > /dev/null \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/selinux' > /dev/null \
        || pwd | grep '^/srv' > /dev/null \
        || pwd | grep '^/usr' > /dev/null \
        || pwd | grep '^/mnt' > /dev/null \
        || pwd | grep '^/mount' > /dev/null \
        || pwd | grep '^/media' > /dev/null \
        || pwd | grep '^/dev' > /dev/null \
        || pwd | grep '^/bin' > /dev/null \
        || pwd | grep '^/sys' > /dev/null \
        || pwd | grep '^/lib64' > /dev/null \
        || pwd | grep '^/proc' > /dev/null \
        || pwd | grep '^/home/[^/]*$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Desktop$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Videos' > /dev/null \
        || pwd | grep '^/home/[^/]*/Pictures' > /dev/null \
        || pwd | grep '^/home/[^/]*/Documents$' > /dev/null \
        || pwd | grep '^/home/[^/]*/Music' > /dev/null \
        || pwd | grep '^/home/[^/]*/Templates' > /dev/null \
        || pwd | grep '^/home/[^/]*/Downloads$' > /dev/null
then
	ECHO "Anti bumblebee security system engaged."
	ECHO "Please execute the script in another directory, you were about to delete important files, and we don't want that :("
	exit 1
fi

if [ "$1" = "-u" ] || [ "$1" = "--update" ]
then
	ECHO "Are you SURE you want to upgrade Spacebukkit in this directory? Everything (except your settings) in it will be deleted! [y/N] \c"
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
		if wget -q "$URL$FILENAME" > /dev/null
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
		if [ -f /etc/centos-release ]
		then
			chown -R apache:apache *
		else
			chown -R www-data:www-data *
		fi
		rm $FILENAME
		rm app/tmp/inst.txt
		wget -q $INSTURL > /dev/null
		ECHO "\t\t\tOK"
		ECHO "\nEverything has been updated correctly! Enjoy Spacebukkit!\n"
		exit 0
	else
		ECHO "\t\t\tERROR"
		ECHO "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
		exit 1
	fi
fi



ECHO "Checking dependencies...\n"

ECHO "unzip...\c"
if [ -f /usr/bin/unzip ]
then
	ECHO "\t\t\tOK"
else
	ECHO "\t\t\tERROR"
	ECHO "\nYou need unzip to execute this script! Please install it and rerun the script!"
	exit 1
fi

ECHO "webserver...\c"
resw=0
if [ -d /etc/apache2 ]
then
	ECHO "\t\t\tApache2"
	dep1=1
	resw=1
elif [ -d /etc/apache ]
then
	ECHO "\t\t\tApache"
	dep1=1
elif [ -d /etc/lighttpd ]
then
	ECHO "\t\t\tlighttpd"
	dep1=1
elif [ -d /etc/nginx ]
then
	ECHO "\t\t\tnginx"
	dep1=1
	resw=2
elif [ -d /etc/httpd ]
then
	ECHO "\t\t\thttpd"
	dep1=1
	resw=1
else
	ECHO "\t\t\tERROR"
	dep1=0
fi

ECHO "sql...\c"
if [ -d /etc/mysql ] || [ -f /usr/bin/mysql ]
then
	ECHO "\t\t\t\tMySQL"
	sqld=1
elif [ -d /etc/postgresql ]
then
	ECHO "\t\t\t\tPostgreSQL"
	sqld=2
elif [ -f /usr/bin/sqlite ]
then
	ECHO "\t\t\t\tSQLite"
	sqld=3
else
	ECHO "\t\t\t\tERROR"
	sqld=0
fi

ECHO "php...\c"
if [ -f /usr/bin/php5 -o -f /usr/bin/php ]
then
	ECHO "\t\t\t\tOK"
	dep2=1
else
	ECHO "\t\t\t\tERROR"
	dep2=0
fi

ECHO "php-curl...\c"
if ls /usr/lib*/*curl* > /dev/null
then
	ECHO "\t\t\tOK"
	dep3=1
else
	ECHO "\t\t\tERROR"
	dep3=0
fi

if [ $sqld -eq 2 ] || [ $sqld -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		[ $sqld -eq 2 ] && ECHO "You have PostgreSQL installed. This is not optimal and is not directly supported by Spacebukkit. Would you like to install MySQL now? [Y]/n \c"
		[ $sqld -eq 0 ] && ECHO "You don't have any SQL Server installed. Spacebukkit will need one. Do you want to install MySQL Server now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing MySQL...\c"
			if apt-get install -y mysql > /dev/null
			then
				ECHO "\t\tOK"
				slqd=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install MySQL manually! :(\n"
			fi
		else
			ECHO "Not installing MySQL...\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		[ $sqld -eq 2 ] && ECHO "You have PostgreSQL installed. This is not optimal and is not directly supported by Spacebukkit. Would you like to install MySQL now? [Y]/n \c"
		[ $sqld -eq 0 ] && ECHO "You don't have any SQL Server installed. Spacebukkit will need one. Do you want to install MySQL Server now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing MySQL...\c"
			if yum install -y mysql-server > /dev/null
			then
				ECHO "\t\tOK"
				sqld=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install MySQL manually! :(\n"
			fi
		else
			ECHO "Not installing MySQL...\n"
		fi
	else
		[ $sqld -eq 3 ] && ECHO "You have SQLite installed. This is not optimal and is not directly supported by Spacebukkit. We recommend you install MySQL."
		[ $sqld -eq 0 ] && ECHO "You don't have any SQL Server installed. You will need to install one for Spacebukkit. We recommend you install MySQL."
	fi
fi

if [ $dep1 -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		ECHO "You don't have any Webserver installed. Spacebukkit will need one. Do you want to install the Apache2 webserver now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing Apache2..."
			if apt-get install -y apache2 > /dev/null
			then
				ECHO "\t\tOK"
				dep1=1
				resw=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install Apache2 manually! :(\n"
			fi
		else
			ECHO "Not installing Apache2...\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		ECHO "You don't have any Webserver installed. Spacebukkit will need one. Do you want to install the httpd webserver now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing httpd...\c"
			if yum install -y httpd > /dev/null
			then
				ECHO "\t\tOK"
				dep1=1
				resw=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install httpd manually! :(\n"
			fi
		else
			ECHO "Not installing httpd...\n"
		fi
	else
		[ $sqld -eq 0 ] && ECHO "You don't have any Webserver installed. You will need to install one for Spacebukkit. We recommend you install the Apache2 webserver."
	fi
fi

if [ $dep2 -eq 0 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		ECHO "You don't have PHP5 and Curl installed. Spacebukkit will need them. Do you want to install PHP5 and Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing PHP5 and Curl...\c"
			if apt-get install -y php5 php5-curl
			then
				ECHO "\tOK"
				dep3=1
				dep2=1
			else
				ECHO "\tERROR"
				ECHO "You will need to install PHP5 and Curl manually! :(\n"
			fi
		else
			ECHO "Not installing PHP5 or Curl... (You will need to do it manually)\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		ECHO "You don't have PHP and Curl installed. Spacebukkit will need them. Do you want to install PHP and Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing PHP and Curl...\c"
			if yum install -y php libcurl > /dev/null
			then
				ECHO "\tOK"
				dep3=1
				dep2=1
			else
				ECHO "\tERROR"
				ECHO "You will need to install PHP and Curl manually! :(\n"
			fi
		else
			ECHO "Not installing PHP or Curl... (You will need to do it manually)\n"
		fi
	else
		[ $sqld -eq 0 ] && ECHO "You don't have PHP and Curl installed. You will need them for Spacebukkit."
	fi
fi

if [ $dep3 -eq 0 -a $dep2 -eq 1 ]
then
	inputline="Y"
	if [ -f /etc/debian_version ]
	then
		ECHO "You don't have Curl installed. Spacebukkit will need it. Do you want to install Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing Curl...\c"
			if apt-get install -y php5-curl > /dev/null
			then
				ECHO "\t\tOK"
				dep3=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install Curl manually! :(\n"
			fi
		else
			ECHO "Not installing Curl... (You will need to do it manually)\n"
		fi
	elif [ -f /etc/centos-release ]
	then
		ECHO "You don't have Curl installed. Spacebukkit will need it. Do you want to install Curl now? [Y]/n \c"
		read inputline
		if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
		then
			ECHO "Installing Curl...\c"
			if yum install -y libcurl > /dev/null
			then
				ECHO "\t\tOK"
				dep3=1
			else
				ECHO "\t\tERROR"
				ECHO "You will need to install Curl manually! :(\n"
			fi
		else
			ECHO "Not installing Curl... (You will need to do it manually)\n"
		fi
	else
		[ $sqld -eq 0 ] && ECHO "You don't have Curl installed. You will need it for Spacebukkit."
	fi
fi

ECHO "\nDependencies are OK!\n"

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
	if wget -q "$URL$FILENAME" > /dev/null
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
	if [ -f /etc/centos-release ]
	then
		chown -R apache:apache SpaceDev-SpaceBukkitPanel-*/*
	else
		chown -R www-data:www-data SpaceDev-SpaceBukkitPanel-*/*
	fi
	cp -r SpaceDev-SpaceBukkitPanel-*/* ./
	cp SpaceDev-SpaceBukkitPanel-*/.htaccess ./
	rm $FILENAME
	rm -r SpaceDev-SpaceBukkitPanel-*
	if [ -f /etc/debian_verion ]
	then
		[ $resw -eq 1 ] && /etc/init.d/apache2 restart > /dev/null
		[ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
	elif [ -f /etc/centos-release ]
	then
		[ $resw -eq 1 ] && /etc/init.d/httpd restart > /dev/null
		[ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
	fi
	ECHO "\t\t\tOK"
	ECHO "\nEverything has been unzipped, modded and owned correctly!\nYou now have a perfect copy of the awesome Spacebukkit Panel! \o/ *!party!* \o/\n"
	exit 0
else
	ECHO "\t\t\tERROR"
	ECHO "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	exit 1
fi
