# Docker NodeRed - MQTT - Debian Architecture for PLCnext EPC 1502 or 1522
## Install on Target

For installation you need to be root user:

To change to root:

```sh
su
```

To set the password from root

```sh
sudo passwd root
```

For installation:

```sh
# Download the Project
git clone https://github.com/Richy1989/PLCnext_DFnow_Example.git

# Execute Setup.sh in archive
cd Docker_DebianBaseImage
chmod +x install.sh
#If you only want to install the containers execute:
./install.sh
#If you also want to set the IP Address of the interfaces execute: 
./install.sh "IP X2:ETH" "Gateway X2:ETH" "Subnet Mask X2:ETH" "IP X3:ETH" "Gateway X3:ETH" "Subnet Mask X3:ETH"
```


Useful Commands: 

```sh
# Stop running containers
docker-compose down
# Delete all unused resources from Docker: 
docker system prune --all --force
# Reset PLCnext / Delete all user data (Make sure all Docker container and images are removed first)
recover-plcnext 1
```