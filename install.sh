#!/bin/bash

# URL to the Download Directory, NOT the file
URL="http://dl.xereo.net/open/"
# Filename derp
FILENAME="1.1.00-full.zip"
# URL to installation script
INSTURL="http://dl.nope.bz/sb/install.sh"
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
	    if wget -q "$URL$FILENAME" > /dev/null
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
	    chmod -R 664 app/webroot/3d_skin
	    if [ -f /etc/centos-release ]
	    then
	        chown -R apache:apache *
	    else
	        chown -R www-data:www-data *
	    fi
	    rm $FILENAME
	    rm app/tmp/inst.txt
	    wget -q $INSTURL > /dev/null
	    echo -e "\t\t\tOK"
	    echo -e "\nEverything has been updated correctly! Enjoy SpaceCP!\n"
	    exit 0
	else
	    echo -e "\t\t\tERROR"
	    echo -e "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
	    exit 1
	fi
fi



echo -e "Checking dependencies...\n"

echo -e "unzip...\c"
if [ -f /usr/bin/unzip ]
then
    echo -e "\t\t\tOK"
else
    echo -e "\t\t\tERROR"
    echo -e "\nYou need unzip to execute this script! Please install it and rerun the script!"
    exit 1
fi

echo -e "webserver...\c"
resw=0
if [ -d /etc/apache2 ]
then
	echo -e "\t\t\tApache2"
    dep1=1
    resw=1
elif [ -d /etc/apache ]
then
    echo -e "\t\t\tApache"
    dep1=1
elif [ -d /etc/lighttpd ]
then
    echo -e "\t\t\tlighttpd"
    dep1=1
elif [ -d /etc/nginx ]
then
    echo -e "\t\t\tnginx"
    dep1=1
    resw=2
elif [ -d /etc/httpd ]
then
    echo -e "\t\t\thttpd"
    dep1=1
    resw=1
else
	echo -e "\t\t\tERROR"
    dep1=0
fi

echo -e "sql...\c"
if [ -d /etc/mysql ] || [ -f /usr/bin/mysql ]
then
	echo -e "\t\t\t\tMySQL"
	sqld=1
elif [ -d /etc/postgresql ]
then
    echo -e "\t\t\t\tPostgreSQL"
    sqld=2
elif [ -f /usr/bin/sqlite ]
then
    echo -e "\t\t\t\tSQLite"
    sqld=3
else
    echo -e "\t\t\t\tERROR"
    sqld=0
fi

echo -e "php...\c"
if [ -f /usr/bin/php5 -o -f /usr/bin/php ]
then
	echo -e "\t\t\t\tOK"
    dep2=1
else
	echo -e "\t\t\t\tERROR"
	dep2=0
fi

echo -e "php-curl...\c"
if ls /usr/lib*/*curl* > /dev/null
then
	echo -e "\t\t\tOK"
    dep3=1
else
	echo -e "\t\t\tERROR"
	dep3=0
fi

if [ $sqld -eq 3 ] || [ $sqld -eq 0 ]
then
    inputline="Y"
    if [ -f /etc/debian_version ]
    then
        [ $sqld -eq 3 ] && echo -e "You have SQLite installed. This is not optimal and is not directly supported by SpaceCP. Would you like to install MySQL now? [Y]/n \c"
        [ $sqld -eq 0 ] && echo -e "You don't have any SQL Server installed. SpaceCP will need one. Do you want to install MySQL Server now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing MySQL...\c"
            if apt-get install -y mysql > /dev/null
            then
                echo -e "\t\tOK"
                slqd=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install MySQL manually! :(\n"
            fi
        else
            echo -e "Not installing MySQL...\n"
        fi
    elif [ -f /etc/centos-release ]
    then
        [ $sqld -eq 3 ] && echo -e "You have SQLite installed. This is not optimal and is not directly supported by SpaceCP. Would you like to install MySQL now? [Y]/n \c"
        [ $sqld -eq 0 ] && echo -e "You don't have any SQL Server installed. SpaceCP will need one. Do you want to install MySQL Server now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing MySQL...\c"
            if yum install -y mysql-server > /dev/null
            then
                echo -e "\t\tOK"
                sqld=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install MySQL manually! :(\n"
            fi
        else
            echo -e "Not installing MySQL...\n"
        fi
    else
        [ $sqld -eq 3 ] && echo "You have SQLite installed. This is not optimal and is not directly supported by SpaceCP. We recommend you install MySQL."
        [ $sqld -eq 0 ] && echo "You don't have any SQL Server installed. You will need to install one for SpaceCP. We recommend you install MySQL."
    fi
fi

if [ $dep1 -eq 0 ]
then
    inputline="Y"
    if [ -f /etc/debian_version ]
    then
        echo -e "You don't have any Webserver installed. SpaceCP will need one. Do you want to install the Apache2 webserver now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing Apache2..."
            if apt-get install -y apache2 > /dev/null
            then
                echo -e "\t\tOK"
                dep1=1
                resw=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install Apache2 manually! :(\n"
            fi
        else
            echo -e "Not installing Apache2...\n"
        fi
    elif [ -f /etc/centos-release ]
    then
        echo -e "You don't have any Webserver installed. SpaceCP will need one. Do you want to install the httpd webserver now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing httpd...\c"
            if yum install -y httpd > /dev/null
            then
                echo -e "\t\tOK"
                dep1=1
                resw=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install httpd manually! :(\n"
            fi
        else
            echo -e "Not installing httpd...\n"
        fi
    else
        [ $sqld -eq 0 ] && echo "You don't have any Webserver installed. You will need to install one for SpaceCP. We recommend you install the Apache2 webserver."
    fi
fi

if [ $dep2 -eq 0 ]
then
    inputline="Y"
    if [ -f /etc/debian_version ]
    then
        echo -e "You don't have PHP5 and Curl installed. SpaceCP will need them. Do you want to install PHP5 and Curl now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo "Installing PHP5 and Curl...\c"
            if apt-get install -y php5 php5-curl
            then
                echo -e "\tOK"
                dep3=1
                dep2=1
            else
                echo -e "\tERROR"
                echo -e "You will need to install PHP5 and Curl manually! :(\n"
            fi
        else
            echo -e "Not installing PHP5 or Curl... (You will need to do it manually)\n"
        fi
    elif [ -f /etc/centos-release ]
    then
        echo -e "You don't have PHP and Curl installed. SpaceCP will need them. Do you want to install PHP and Curl now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo "Installing PHP and Curl...\c"
            if yum install -y php libcurl > /dev/null
            then
                echo -e "\tOK"
                dep3=1
                dep2=1
            else
                echo -e "\tERROR"
                echo -e "You will need to install PHP and Curl manually! :(\n"
            fi
        else
            echo -e "Not installing PHP or Curl... (You will need to do it manually)\n"
        fi
    else
        [ $sqld -eq 0 ] && echo "You don't have PHP and Curl installed. You will need them for SpaceCP."
    fi
fi

if [ $dep3 -eq 0 -a $dep2 -eq 1 ]
then
    inputline="Y"
    if [ -f /etc/debian_version ]
    then
        echo -e "You don't have Curl installed. SpaceCP will need it. Do you want to install Curl now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing Curl...\c"
            if apt-get install -y php5-curl > /dev/null
            then
                echo -e "\t\tOK"
                dep3=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install Curl manually! :(\n"
            fi
        else
            echo -e "Not installing Curl... (You will need to do it manually)\n"
        fi
    elif [ -f /etc/centos-release ]
    then
        echo -e "You don't have Curl installed. SpaceCP will need it. Do you want to install Curl now? [Y]/n \c"
        read inputline
        if [[ $inputline == "Y" ]] || [[ $inputline == "y" ]] || [[ $inputline == "yes" ]] || [[ $inputline == "YES" ]] || [[ $inputline == "Yes" ]] || [[ $inputline == "" ]]
        then
            echo -e "Installing Curl...\c"
            if yum install -y libcurl > /dev/null
            then
                echo -e "\t\tOK"
                dep3=1
            else
                echo -e "\t\tERROR"
                echo -e "You will need to install Curl manually! :(\n"
            fi
        else
            echo -e "Not installing Curl... (You will need to do it manually)\n"
        fi
    else
        [ $sqld -eq 0 ] && echo "You don't have Curl installed. You will need it for SpaceCP."
    fi
fi

echo -e "\nDependencies are OK!\n"
echo -e "Downloading SpaceCP now...\c"
i=0
success=0
while [ $i -lt 5 ] && [ $success -eq 0 ]
do
    if wget -q "$URL$FILENAME" > /dev/null
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
    chmod -R 664 app/webroot/3d_skin
    if [ -f /etc/centos-release ]
    then
        chown -R apache:apache *
    else
        chown -R www-data:www-data *
    fi
    rm $FILENAME
#    rm unzip
    if [ -f /etc/debian_verion ]
    then
        [ $resw -eq 1 ] && /etc/init.d/apache2 restart > /dev/null
        [ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
    elif [ -f /etc/centos-release ]
    then
        [ $resw -eq 1 ] && /etc/init.d/httpd restart > /dev/null
        [ $resw -eq 2 ] && /etc/init.d/nginx restart > /dev/null
    fi
    echo -e "\t\t\tOK"
    echo -e "\nEverything has been unzipped, modded and owned correctly! You now have a perfect copy of the awesome SpaceCP Panel! \o/ *!party!* \o/\n"
    exit 0
else
    echo -e "\t\t\tERROR"
    echo -e "Problems unzipping the panel! Something went wrong, maybe try again or ask us for support!\n"
    exit 1
fi
