#!/bin/bash
################################################################################
# Magna Presstec - Docker Container Startup File - Example - Not for production
# Author: Richard Leopold
# Date: 15.02.2022
################################################################################

########################################################################
######################### Begin Startup File  ########################## 
########################################################################

#Change default shell to zsh
sudo chsh -s "$(which zsh)" "$(whoami)"

#Start the web server service
sudo service nginx start

###### DO NOT USE IN PRODUCTION! Start ######
#Start the service
sudo service ssh start 
###### DO NOT USE IN PRODUCTION! End  ######

#ToDo: Download sources via git
#git clone java_application.git

#This is where the Java application shall be started
echo "Start Java Application"
java --version

#ToDo: Download sources via git
#git clone c_sharp_application.git

#This is where the C# application shell be started
echo "Start C# Application"
dotnet --info

# ToDo: Remove this when JAVA or C# application is running | Or leave it when using services
exec tail -f /dev/null

########################################################################
######################### END Startup File  ############################
########################################################################