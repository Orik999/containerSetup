#!/bin/bash
################################################################################
### Info from 
################################################################################
#################   Traefik  #################
#   Prepare environment for traefik install
mkdir traefik && \
cd traefik && \
touch docker-compose.yml && \
mkdir data && \
cd data && \
touch acme.json && \
chmod 600 acme.json && \
touch traefik.yml && \
touch config.yml

#   Disable ubuntu dns service
sudo systemctl stop systemd-resolved.service
sudo systemctl disable systemd-resolved.service
#   Edit resolver file and add nameservers nameserver 127.0.0.1 and nameserver 1.1.1.1
sudo sed -i '/^nameserver 1.1.1.1/anameserver 127.0.0.1' /etc/resolv.conf

#   update data in traefik.yml
#   update data in docker-compose.yml

#   create docker network
docker network create proxy

#   start docker compose
docker-compose up -d