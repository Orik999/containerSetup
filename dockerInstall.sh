#!/bin/bash
################################################################################
### Info from https://www.smarthomebeginner.com/install-docker-on-ubuntu-22-04/
################################################################################
#################   Docker  #################
#   Prepare environment for docker insaall
sudo swapoff -a && \
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab && \
sudo apt update

#   Install dependencies
sudo apt -y install \
  apt-transport-https \
  ca-certificates \
  acl \
  curl \
  software-properties-common \
  gnupg \
  lsb-release

#   Install Docker GPG key and compare and add repo
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

#   Install docker      #   To check install run $docker -v -or- sudo systemctl status docker
sudo apt update && \
sudo apt -y install docker-ce && \
sudo systemctl enable docker

#   Use Docker without sudo
sudo usermod -aG docker $USER
#   If you need to uninstall Docker, run the following
#   $sudo apt-get remove docker docker-engine docker.io containerd runc

#   Create Docker root folder and secrets folder
mkdir ~/docker && \
mkdir ~/docker/secrets
#   Create secret files
sudo echo "orik:$$apr1$$fUdDqskz$$zSgIUhrs4tpuMmXzjzqJx." > ~/docker/secrets/htpasswd
sudo echo "oriknj999@gmail.com" > ~/docker/secrets/cf_email
sudo echo "eUOluKNZJ4rJi5BmqgY-M2pMXhBqWfVcdzbEDqt0" > ~/docker/secrets/cf_api_key
sudo echo "COEvgLN30ZhAX81-5cOfiKey7zcHMLH12QCPQxT_" > ~/docker/secrets/cf_api_key_ddns
#   generate strong password for db root and create db root password file
sudo echo "973cfRW5RZQ7**WRxz?M" > ~/docker/secrets/db_root_password
#   create db user password file
sudo echo "uWfpQAt4VgKWn?=Y5zV=" > ~/docker/secrets/db_password

#   set permissions to folders
sudo setfacl -Rdm g:docker:rwx ~/docker && \
sudo chmod -R 775 ~/docker

#   set stricter permissions for secret folder
sudo chown root:root ~/docker/secrets && \
sudo chmod 600 ~/docker/secrets

#   create environment for docker
touch ~/docker/.env && \
cat > ~/docker/.env << EOF
DOCKER_DIR=/home/orik/docker
DOCKER_SECRETS_DIR=/home/orik/docker/secrets
PUID=1000
PGID=999
TZ="Asia/Bangkok"
USERDIR="home/orik"
MYSQL_ROOT_PASSWORD="passsword"
HTTP_USERNAME=orik
HTTP_PASSWORD=mystrongpassword
DOMAINNAME=najafov.co.uk
EOF
#   check id and for PGID get docker id
#id

#################   Docker Compose  #################
#   Download Docker compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
#   Make is Executable  #   to check install run $docker-compose -v
sudo chmod +x /usr/local/bin/docker-compose
#   to check if installed: $docker-compose -v
