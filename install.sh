#!/bin/bash
################################################################################
# Magna Presstec - Installation File - Example - Not for production
# Author: Richard Leopold
# Date: 15.02.2022
################################################################################

#Function to check if a command exists or not
function command_exists()
{
	command -v "$@" >/dev/null 2>&1
}

#Exit installer when an error occurred
function error_occurred()
{
	echo -e "$RED""An Error with: $1 has occurred!""$NC";
	exit 1;
}

##### Main Program #####
container_software='docker'
compose_software='docker-compose'

#define colors for output
LightBlue='\033[1;34m'
Green='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#Save current execution path and name
executionDir=$(pwd);

#Variable to check if IP shall be set
setIp=0;

#Check if not more than 6 arguments are given
if [[ $# -gt 0 && ! $# -eq 6 ]]; then
	echo "error: wrong number of arguments" >&2;
	source set_ip.sh
	print_usage;
	exit 1;
fi

#If arguments are given set ip address
if [ $# -eq 6 ]; then
	source set_ip.sh
	set_IP_address "$1" "$2" "$3" "$4" "$5" "$6" || error_occurred "set ip address"
	setIp=1;
fi

#Check if the necessary software is installed, otherwise try to install it
if ! command_exists $container_software || ! command_exists $compose_software ; then
	echo -e "$RED""Containerization software could not be found ...""$NC";
	echo -e "$LightBlue""Starting installation of: $container_software and $compose_software ...""$NC";

	#Remove download if already existing
	rm -f Docker_GettingStarted >/dev/null 2>&1
	#Download the project
	git clone https://github.com/Richy1989/Docker_GettingStarted;
	#Execute setup.sh
	cd Docker_GettingStarted || exit;
	chmod +x setup.sh;
	./setup.sh 2 "yes";
fi

#If we reach this the docker applications have been found and / or installed correctly, let's carry on
echo -e "$Green""$container_software and $compose_software found ...""$NC";
echo -e "$LightBlue""Starting installation of the containers ...""$NC";

#Set variables
magna_local_folder="magna_local";
homeFolder="/opt/plcnext/";
dockerfileName="Dockerfile";
dockerComposeFileName="docker-compose.yml";
startupFile="start.sh";
keyFile="authorized_keys";

#Change location to home directory
cd $homeFolder || cd ~/ || exit

#print current folder
actualFolder=$(pwd);
echo -e "$LightBlue""Moved to directory: $actualFolder""$NC";

#Create local installation folder
echo -e "$LightBlue""Create installation folder: $magna_local_folder""$NC";
mkdir -p $magna_local_folder;
#Change permission of local folder
chmod 777 $magna_local_folder;
#Move into local installation folder
cd $magna_local_folder || echo 'installation folder not found';

actualFolder=$(pwd);
echo -e "$LightBlue""Moved to directory: $actualFolder""$NC";

#Copy files to installation location
echo -e "$LightBlue""Copy needed files to installation folder ...""$NC";
cp -f "$executionDir""/"$dockerfileName $dockerfileName
cp -f "$executionDir""/"$dockerComposeFileName $dockerComposeFileName
cp -f "$executionDir""/"$startupFile $startupFile
cp -f "$executionDir""/"$keyFile $keyFile #<---------- DO NOT USE IN PRODUCTION

#Execute docker-compose once to be sure it is up do date - docker will auto update it
#echo -e ${LightBlue}$compose_software" is executed once before start ..."${NC};
#$compose_software &> /dev/null;

#Stop containers and remove images
echo -e "$LightBlue""Stopping running instances ...$actualFolder""$NC";
$compose_software down;

#Remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes. #!Delete if not necessary 
$container_software system prune --all --force

#Sleep 3 seconds to let docker settle down
echo -e "$LightBlue""Wait 3 seconds for docker to settle down after prune ...""$NC";
sleep 3;

#Start docker-compose process - note: This always rebuilds the magnadebian image (remove --build otherwise)
echo -e "$LightBlue""$compose_software is starting ...""$NC";
$compose_software up -d --build || error_occurred $compose_software
echo -e "$LightBlue""$compose_software finished ...""$NC";

echo -e "$Green""Everything went fine!""$NC";
echo -e "$Green""Magna local installation complete. Installation Path: $homeFolder$magna_local_folder""$NC";

#If IP is set --> reboot
if [ $setIp -eq 1 ]; then
	#reboot time
	t=10;
	echo -e "$Green""Rebooting in $t seconds to enable network settings ...""$NC";
	while [ $t -gt 0 ]
	do
		echo -e "$Green""Reboot in $t ...""$NC";
		t=$(( t - 1 ));
		sleep 1;
	done
	#Restart the system
	shutdown -r now
fi