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

echo -e "\e[1;33m This script will Perform Post Install Routines. PVE7 ONLY \e[0m"
while true; do
    read -p "Start the PVE7 Post Install Script (Y/n)?" yn
    case $yn in
        ""|"y"|"Y" ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
if [ `pveversion | grep "pve-manager/7" | wc -l` -ne 1 ]; then
        echo -e "This script requires Proxmox Virtual Environment 7.0 or greater"
        echo -e "Exiting..."
        sleep 2
        exit
fi
function header_info {
echo -e "${RD}
  _______      ________ ______   _____          _     _____           _        _ _ 
 |  __ \ \    / /  ____|____  | |  __ \        | |   |_   _|         | |      | | |
 | |__) \ \  / /| |__      / /  | |__) |__  ___| |_    | |  _ __  ___| |_ __ _| | |
 |  ___/ \ \/ / |  __| v3 / /   |  ___/ _ \/ __| __|   | | |  _ \/ __| __/ _  | | |
 | |      \  /  | |____  / /    | |  | (_) \__ \ |_   _| |_| | | \__ \ || (_| | | |
 |_|       \/   |______|/_/     |_|   \___/|___/\__| |_____|_| |_|___/\__\__,_|_|_|
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

msg_info "Removing local-lvm and adding regained space to local"
sleep 2
#umount /dev/pve/data
lvremove -y /dev/pve/data &>/dev/null
lvresize -l +100%FREE /dev/pve/root &>/dev/null
resize2fs /dev/mapper/pve-root &>/dev/null
msg_ok "local-lvm Removed and free space added to local"

msg_info "Restricting Root login and disabling password login and IPv4 only"
sleep 2
#   Restrict Root login and to IPv4 only
sed -i 's/#AddressFamily any/AddressFamily inet/g;s/#PasswordAuthentication yes/PasswordAuthentication no/g;s/PermitRootLogin.*/PermitRootLogin prohibit-password/g' /etc/ssh/sshd_config
msg_ok "Root login restricted, pass login disabled, only IPv4 set"

msg_info "Disabling Enterprise Repository"
sleep 2
sed -i "s/^deb/#deb/g" /etc/apt/sources.list.d/pve-enterprise.list
msg_ok "Disabled Enterprise Repository"

msg_info "Adding or Correcting PVE7 Sources"
cat <<EOF > /etc/apt/sources.list
deb http://ftp.debian.org/debian bullseye main contrib
deb http://ftp.debian.org/debian bullseye-updates main contrib
# security updates
deb http://security.debian.org bullseye-security main contrib
# NOT recommended for production use (Updates)
deb http://download.proxmox.com/debian/pve bullseye pve-no-subscription
# deb http://download.proxmox.com/debian/pve bullseye pvetest
EOF
sleep 2
msg_ok "Added or Corrected PVE7 Sources"
#   update and clean
msg_info "Updating system"
sleep 2
apt update &>/dev/null
apt -y dist-upgrade &>/dev/null
apt -y autoremove &>/dev/null
msg_ok "System updated"

msg_info "Disabling Subscription Nag"
echo "DPkg::Post-Invoke { \"dpkg -V proxmox-widget-toolkit | grep -q '/proxmoxlib\.js$'; if [ \$? -eq 1 ]; then { echo 'Removing subscription nag from UI...'; sed -i '/data.status/{s/\!//;s/Active/NoMoreNagging/}' /usr/share/javascript/proxmox-widget-toolkit/proxmoxlib.js; }; fi\"; };" > /etc/apt/apt.conf.d/no-nag-script
apt --reinstall install proxmox-widget-toolkit &>/dev/null
msg_ok "Disabled Subscription Nag"

msg_info "Laptop setup - ignoring lid close"
sed -i 's/#HandleLidSwitch.*/HandleLidSwitch=ignore/g;s/#HangleLidSwitchDocked.*/HangleLidSwitchDocked=ignore/g' /etc/systemd/logind.conf
msg_ok "Laptop setup - lid close ignored"

msg_info "Setting turn off screen after 5mins of inactivity"
sed -i 's/GRUB_CMDLINE_LINUX=.*/GRUB_CMDLINE_LINUX="consolebland=300"/g' /etc/default/grub
update-grub &>/dev/null
msg_ok "Screen will turn of after 5mins of inactivity"

msg_info "Stopping/Removing spiceproxy - spiceproxy is only needed if in cluster"
systemctl stop spiceproxy
rm /etc/systemd/system/multi-user.target.wants/spiceproxy.service
msg_ok "Spiceproxy stopped and removed"

msg_info "Installing Dark Theme"
bash <(curl -s https://raw.githubusercontent.com/Weilbyte/PVEDiscordDark/master/PVEDiscordDark.sh ) install &>/dev/null
msg_ok "Dark Theme installed"

msg_ok "Finished post install config...."

echo ""
read -n 1 -s -r -p "Press enter to REBOOT NOW. "
sleep 2 && reboot
exit;;