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
BFR="\\r\\033[K"
HOLD="-"
CM="${GN}✓${CL}"
CROSS="${RD}✗${CL}"

echo -e "\e[1;33m This script will Install/Setup Docker. \e[0m"
while true; do
    read -p "Start the Docker Install/Setup Script (Y/n)?" yn
    case $yn in
        ""|"y"|"Y" ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
function header_info {
echo -e "${BL}
  _____             _             
 |  __ \           | |            
 | |  | | ___   ___| | _____ _ __ 
 | |v3| |/ _ \ / __| |/ / _ \  __|
 | |__| | (_) | (__|   <  __/ |   
 |_____/ \___/ \___|_|\_\___|_|   
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

msg_info "Disabling swap"
sleep 2
#sudo swapoff -a &>/dev/null
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo apt-get update &>/dev/null
msg_ok "Swap disabled"

msg_info "Updating repositories"
sleep 2
sudo apt-get update &>/dev/null
msg_ok "repositories updated"

msg_info "Installing dependencies"
sleep 2
sudo apt-get -y install &>/dev/null \
  apt-transport-https &>/dev/null \
  ca-certificates &>/dev/null \
  acl &>/dev/null \
  curl &>/dev/null \
  software-properties-common &>/dev/null \
  gnupg &>/dev/null \
  lsb-release &>/dev/null
msg_ok "Dependencies installed"

msg_info "Getting Docker GPG key, checking hash and adding Docker repo"
sleep 2
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list &>/dev/null
msg_ok "Docker GPG key downloaded and Docker repo added"

msg_info "Installing Docker-ce, docker-ce-cli, Containerd and enabling Docker"
sleep 2
sudo apt-get update &>/dev/null
sudo apt-get -y install docker-ce docker-ce-cli containerd.io &>/dev/null
sudo systemctl enable docker &>/dev/null
msg_ok "Docker-ce, docker-ce-cli, Containerd installed and Docker enabled"

msg_info "Adding user $USER to Docker group"
sleep 2
sudo usermod -aG docker $USER
msg_ok "User $USER added to Docker group"

msg_info "Setting DOCKER_OPTS to Respect IP Table Firewall"
sleep 2
sudo sed -i '/#DOCKER_OPTS=.*/a DOCKER_OPTS="--iptables=false"' /etc/default/docker
msg_ok "DOCKER_OPTS to Respect IP Table Firewall set"

msg_info "Disabling ubuntu dns service (systemd-resolved.service)"
sleep 2
sudo systemctl stop systemd-resolved.service &>/dev/null
sudo systemctl disable systemd-resolved.service &>/dev/null
msg_ok "Ubuntu DNS service DISABLED (systemd-resolved.service)"

# msg_info "Adding DNS Resolvers"
# sleep 2
# sudo sed -i '/^nameserver 9.9.9.9/anameserver 127.0.0.1' /etc/resolv.conf
# msg_ok "DNS Resolvers ADDED (9.9.9.9, 127.0.0.1)"

msg_info "Downloading Docker Compose and making it executable"
sleep 2
sudo curl -L "https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>/dev/null
sudo chmod +x /usr/local/bin/docker-compose
msg_ok "Docker Compose downloaded and executable settings applied"
echo ""
function msg_ok() {
    local msg="$1"
    echo -e "${BFR} ${CM} ${DGN}${msg}${CL}"
}
msg_ok "Docker, Docker Compose installed, configuration finished"
docker -v
docker-compose -v
echo ""
read -n 1 -s -r -p "Press enter to REBOOT NOW. "
sudo reboot
exit;;