#!/bin/bash
################################################################################
### Folder env setup
################################################################################
#################   Content folders  #################
cd $HOME
mkdir downloads
mkdir music
#################   Create All Folders  #################
cd $HOME/docker
mkdir portainer traefik mariadb redis authelia vscode pihole organizr docker-gc gbserk gunbot jdown lidarr prowlarr nzbget qbit
#################   Portainer   #################
touch portainer-compose.yml
#################   Traefik  #################
touch traefik/acme.json traefik/traefik.yml traefik/config.yml
chmod 600 traefik/acme.json
#################   Authelia  #################
touch authelia/configuration.yml authelia/users_database.yml
#################   VSCode  #################
mkdir vscode/data vscode/config
#################   Pihole  #################
mkdir pihole/etc-pihole pihole/etc-dnsmasq.d
