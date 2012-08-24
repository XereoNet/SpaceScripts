#!/bin/sh
RTKDL='http://drdanick.com/downloads/dl.php?id=remotetoolkit&ver=r10_a13.1'
SBDL='http://dev.drdanick.com/jenkins/job/SpaceModule/79/artifact/target/spacemodule-1.2-SNAPSHOT.jar'
REPLACEURL='http://jamy.be/dl/replace'

clear
echo "###############################################"
echo "#       Welcome to the SpaceBukkit and        #"
echo "#           RemoteToolkit installer!          #"
echo "#                                             #"
echo "#       Created by the SpaceDev team          #"
echo "#              Copyright 2012                 #"
echo "#                                             #"
echo "###############################################"
echo ""
echo ""
echo "Hello I'd like you to answer some questions for me!"
echo ""

# The actual script
# Directory
echo "What directory do you want Minecraft to be installed in?"
echo -n "["$(pwd)"]: "
read PWDS
if ["$PWDS" = ""]
then
	PWDS=$(pwd)
fi
echo -n "Installing in $PWDS, are you sure[Y/n]? "
read inputline
if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
then
	echo "Ok!"
	echo "---------------------------------------------------------------------"
else
	echo "Aborting..."
	exit
fi
cd $PWDS
wget -q -O replace $REPLACEURL
chmod +x replace
# Memory
var=true
mem=$( echo `free -m | grep Mem` | cut -d " " -f2)
memc=$(expr $mem - 200)
echo "How much memory would you like to have assigned to you Minecraft server?"
echo "This amount is in MegaBytes (1GB = 1024MB)"
echo -n "Memory[Max.: $memc]: "
read MEMORY
while $var;do
	if [ $MEMORY -ne 0 -o $MEMORY -eq 0 2>/dev/null ]
	then
		var=false
	else
		echo "Please enter a numeric value without any text!"
		echo ""
		echo -n "Memory: "
		read MEMORY
	fi
done
echo "---------------------------------------------------------------------"

# RTK
echo 'Downloading and installing RTK...'
cd "$PWDS"
wget -q -O "rtk.zip" $RTKDL
unzip -q rtk.zip
rm -rf rtk.zip
mv serverdir/* ./
rm -rf serverdir
rm -rf UDP*
password=$( < /dev/urandom tr -dc A-Za-z0-9 | head -c8)
cat rtoolkit.sh | ./replace "USER=user" "USER=admin" > rtoolkit.sh.tmp
cat rtoolkit.sh.tmp | ./replace "PASS=pass" "PASS=$password" > rtoolkit.sh
rm rtoolkit.sh.tmp
chmod +x rtoolkit.sh
rm rtoolkit.bat
echo "Done!"
echo "---------------------------------------------------------------------"

# Assigning memory
echo 'Assigning a maximum of '$MEMORY'MB to Minecraft...'
memi=$(printf %.0f $(expr $MEMORY / 3))
cd "$PWDS/toolkit"
cat wrapper.properties | ../replace "maximum-heap-size=1024M" "maximum-heap-size="$MEMORY"M" > wrapper.properties.tmp
cat wrapper.properties.tmp | ../replace 'initial-heap-size=1024M' 'initial-heap-size='$memi'M' > wrapper.properties
rm wrapper.properties.tmp
cd "$PWDS"
echo "Done!"
echo "---------------------------------------------------------------------"

# SpaceBukkit
SB=false
echo -n "Do you want to install SpaceBukkit[Y/n]? "
read inputline
if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
then
	echo "Downloading..."
	SB=true
	cd "$PWDS/toolkit/modules"
	wget -q $SBDL
	cd "$PWDS"
	mkdir SpaceModule
	cd SpaceModule
	echo "What port would you like SpaceBukkit to be assigned to?"
	echo "If you don't know what this means, leave it at the default!"
	echo -n "SpaceBukkit port [2011]: "
	read sbp
	if [ "$sbp" = "" ]
	then
		sbp='2011'
	fi
	echo ""
	echo "And SpaceRTK?"
	echo "You may leave this at default too!"
	echo -n "SpaceRTK port [2012]: "
	read rtkp
	if [ "$rtkp" = "" ]
	then
		rtkp='2012'
	fi
	salt=$( < /dev/urandom tr -dc A-Za-z0-9 | head -c25)
	echo -e 'General:\n  salt: '$salt'\n  bindIp: \nSpaceBukkit:\n  port: '$sbp'\nSpaceRTK:\n  port: '$rtkp > configuration.yml
	cat configuration.yml | ../replace "\-e " '' > configuration.yml.tmp
	mv configuration.yml.tmp configuration.yml
	echo "SpaceBukkit has been installed!"
	cd "$PWDS"
fi
echo "---------------------------------------------------------------------"

# craftbukkit
echo -n "Do you want to install the latest version of craftbukkit[Y/n]? "
read inputline
if [ "$inputline" = "Y" ] || [ "$inputline" = "y" ] || [ "$inputline" = "yes" ] || [ "$inputline" = "YES" ] || [ "$inputline" = "Yes" ] || [ "$inputline" = "" ]
then
	echo 'Downloading...'
	wget -q http://dl.bukkit.org/latest-rb/craftbukkit.jar -O craftbukkit.jar
	echo "What port would you like Minecraft to be assigned to?"
	echo "If you don't know what this means, leave it at the default!"
	echo -n "Minecraft port [25565]: "
	read mcp
	if [ "$mcp" = "" ]
	then
		mcp='25565'
	fi
	echo ""
	echo "What IP do you want Minecraft to be bound to?"
	echo "In most cases you can leave this empty ;)"
	echo -n "Minecraft IP: "
	read mcip
	if $SB
		then
		cat SpaceModule/configuration.yml | ./replace "bindIp:" "bindIp: $mcip" > configuration.yml.tmp
		mv configuration.yml.tmp SpaceModule/configuration.yml
	fi

	echo -e 'server-ip='$mcip'\nserver-port='$mcp > server.properties
	cat server.properties | ./replace "\-e " '' > server.properties.tmp
	mv server.properties.tmp server.properties
	echo "Craftbukkit has been installed!"
	echo "---------------------------------------------------------------------"
fi
clear
echo ""
echo ""
echo ""
echo "###############################################" > serverinfo.txt
echo "#                 That's it!                  #" >> serverinfo.txt
echo "#        Your server has been installed!      #" >> serverinfo.txt
echo "#                                             #" >> serverinfo.txt
echo "#      You can start your server by doing:    #" >> serverinfo.txt
echo "#               ./rtoolkit.sh                 #" >> serverinfo.txt
echo "#                                             #" >> serverinfo.txt
echo "# You will be able to access your server on:  #" >> serverinfo.txt
echo "#              <server-ip>:$mcp              #" >> serverinfo.txt
echo "#                                             #" >> serverinfo.txt
if $SB
then
echo "# To set up your SpaceBukkit panel you need:  #" >> serverinfo.txt
echo "#         address: localhost or <server-ip>   #" >> serverinfo.txt
echo "#SpaceBukkit port: $sbp                       #" >> serverinfo.txt
echo "#   SpaceRTK port: $rtkp                       #" >> serverinfo.txt
echo "#            salt: $salt  #" >> serverinfo.txt
fi
echo "#                                             #" >> serverinfo.txt
echo "#       Created by the SpaceDev team          #" >> serverinfo.txt
echo "#              Copyright 2012                 #" >> serverinfo.txt
echo "#                                             #" >> serverinfo.txt
echo "###############################################" >> serverinfo.txt
cat serverinfo.txt
echo "These important variables are saved in the file: serverinfo.txt"
