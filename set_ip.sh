#!/bin/bash
################################################################################
# Magna Presstec - Set IP Library - Example - Not for production
# Author: Richard Leopold
# Date: 15.02.2022
################################################################################

#Define colors for output
LightBlue='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

#Save execution name for error messages
execution_name=$0;

#Set print usage information
function print_usage()
{
	echo "Usage 1: $execution_name";
	echo "Usage 2: $execution_name [X2:IP] [X2:Gateway] [X2:Netmask] [X3:IP] [X3:Gateway] [X3:Netmask]";
}

#Check the IP address for correctness
function check_ip()
{
	ip=$1;
	if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
		# Success
		return 1;
	else
		# Fail
		return 0;
	fi
}

#Set IP address for EPC
function set_IP_address()
{
	ipX2=$1;
	gatewayX2=$2;
	netmaskX2=$3;
	ipX3=$4;
	gatewayX3=$5;
	netmaskX3=$6;
	
	tempNetworkFileName="/etc/network/interfaces.temp";
	networkFileName="/etc/network/interfaces";
	backupInterfaceName="/etc/network/interfaces_backup";
	
	echo -e "$LightBlue""Creating temporary network file: $tempNetworkFileName ...""$NC";

	if check_ip "$ipX2" -eq 0 || check_ip "$netmaskX2" -eq 0 || check_ip "$ipX3" -eq 0 \
		|| check_ip "$gatewayX3" -eq 0|| check_ip "$netmaskX3" -eq 0; then
		
		echo -e "$RED""Error validating IP address!""$NC";
		print_usage;
		return 1;
	fi
	
	rm -f $tempNetworkFileName &> /dev/null;
	
	#Write new interface file
	{
		echo "# /etc/network/interfaces -- configuration file for ifup(8), ifdown(8)"
		echo "# The loopback interface"
		echo "auto lo"
		echo "iface lo inet loopback"
		echo "# Wired or wireless interfaces"
		echo "auto X3"
		echo "iface X3 inet static"
		echo "    address $ipX3"
		echo "    netmask $netmaskX3"
		echo "    gateway $gatewayX3"
		echo "    dns-nameservers 8.8.8.8 8.8.4.4"
		echo "auto X2"
		echo "iface X2 inet static"
		echo "    address $ipX2"
		echo "    netmask $netmaskX2"
		echo "    gateway $gatewayX2"
		echo "    dns-nameservers 8.8.8.8 8.8.4.4"
	} >> $tempNetworkFileName
	
	echo -e "$LightBlue""Override network file: $networkFileName ...""$NC";
	
	#Backup old file and create the new one
	mv -f $networkFileName $backupInterfaceName;
	mv -f $tempNetworkFileName $networkFileName;
}