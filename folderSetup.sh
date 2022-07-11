#!/usr/bin/env bash -ex
set -euo pipefail
shopt -s inherit_errexit nullglob
YW=`echo "\033[33m"`
BL=`echo "\033[36m"`
RD=`echo "\033[01;31m"`
BGN=`echo "\033[4;92m"`
GN=`echo "\033[1;92m"`
DGN=`echo "\033[32m"`
CL=`echo "\033[m"`
CLF=`echo "\033[5m"`
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

echo -e "\e[1;33m This script will Setup Docker container folders. \e[0m"
while true; do
    read -p "Start the Docker Container Folder Setup Script (Y/n)?" yn
    case $yn in
        ""|"y"|"Y" ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
function header_info {
echo -e "${BL}
╔═╗┌─┐┬  ┌┬┐┌─┐┬─┐  ┌─┐┌┐┌┬  ┬  ╔═╗┌─┐┌┬┐┬ ┬┌─┐
╠╣ │ ││   ││├┤ ├┬┘  ├┤ │││└┐┌┘  ╚═╗├┤  │ │ │├─┘
╚  └─┘┴─┘─┴┘└─┘┴└─  └─┘┘└┘ └┘   ╚═╝└─┘ ┴ └─┘┴  
${CL}"
}

function msg_info() {
    local msg="$1"
    echo -ne " ${HOLD} ${YW}${msg}..."
}

function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${GN}${msg}${CL}"
}

clear
header_info

#################   Content folders  #################
cd $HOME
mkdir downloads
mkdir music
msg_ok "downloads"
msg_ok "music"
msg_ok "/\      folders created in $HOME"
#################   Create All Folders  #################
echo ""
cd $HOME/docker
mkdir portainer portainer/data traefik mariadb redis authelia vscode vscode/data vscode/config pihole pihole/etc-pihole pihole/etc-dnsmasq.d organizr docker-gc gbserk gunbot jdown lidarr prowlarr nzbget socket-proxy qbit
msg_ok "portainer"
msg_ok "portainer/data"
msg_ok "traefik"
msg_ok "mariadb"
msg_ok "redis"
msg_ok "authelia"
msg_ok "vscode"
msg_ok "vscode/data"
msg_ok "vscode/config"
msg_ok "pihole"
msg_ok "pihole/etc-pihole"
msg_ok "pihole/etc-dnsmasq.d"
msg_ok "organizr"
msg_ok "docker-gc"
msg_ok "gbserk"
msg_ok "gunbot"
msg_ok "jdown"
msg_ok "lidarr"
msg_ok "prowlarr"
msg_ok "nzbget"
msg_ok "socket-proxy"
msg_ok "qbit"
msg_ok "/\      folders created in $HOME/docker"
#################   Socket-Proxy   #################
echo ""
touch socket-proxy/socket-proxy-compose.yml
msg_ok "socket-proxy-compose.yml created in $HOME/docker/socket-proxy"
#################   Portainer   #################
echo ""
touch portainer/portainer-compose.yml
msg_ok "portainer-compose.yml created in $HOME/docker/portainer"
#################   Traefik  #################
echo ""
touch traefik/acme.json traefik/traefik.yml traefik/config.yml
chmod 600 traefik/acme.json
msg_ok "acme.json"
msg_ok "traefik.yml"
msg_ok "config.yml"
msg_ok "/\      files created in $HOME/docker/traefik"
#################   Authelia  #################
echo ""
touch authelia/configuration.yml authelia/users_database.yml
msg_ok "configuration.yml"
msg_ok "users_database.yml"
msg_ok "/\      files created in $HOME/docker/authelia"

echo ""
function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${DGN} ${CLF}${DGN}${msg}${CL}"
}
msg_ok "FINISHED"