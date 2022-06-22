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

echo -e "\e[1;33m This script will Configure Proxmox Container/VM. \e[0m"
while true; do
    read -p "Start the Proxmox Container/VM Config Script (Y/n)?" yn
    case $yn in
        ""|"y"|"Y" )
        #   Check if system is a container
        grep -qa container=lxc /proc/1/environ && ynresponse=1 || ynresponse=2
        break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
function header_info {
echo -e "${BL}
 ██████╗ ██████╗ ███╗   ██╗████████╗ █████╗ ██╗███╗   ██╗███████╗██████╗         ██╗    ██╗   ██╗███╗   ███╗    ███████╗███████╗████████╗██╗   ██╗██████╗ 
██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██║████╗  ██║██╔════╝██╔══██╗       ██╔╝    ██║   ██║████╗ ████║    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗
██║     ██║   ██║██╔██╗ ██║   ██║   ███████║██║██╔██╗ ██║█████╗  ██████╔╝      ██╔╝     ██║   ██║██╔████╔██║    ███████╗█████╗     ██║   ██║   ██║██████╔╝
██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗     ██╔╝      ╚██╗ ██╔╝██║╚██╔╝██║    ╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝ 
╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║██║ ╚████║███████╗██║  ██║    ██╔╝        ╚████╔╝ ██║ ╚═╝ ██║    ███████║███████╗   ██║   ╚██████╔╝██║     
 ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝    ╚═╝          ╚═══╝  ╚═╝     ╚═╝    ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝     
                                                                                                                                                          
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

username=orik
case $ynresponse in 
    [1] ) echo Setting up Container;
    #   Check if user exists > exit
        if  id "$username" >/dev/null 2>&1; then
            echo "Not a fresh system! Script cancelled"
            exit 1
        fi
        msg_info "Creating User $username"
        sleep 2
    #   Set hashed pass
        password=sa.EukkiViW5.
        useradd -m -p "$password" "$username" &>/dev/null
        msg_ok "$username user created"

        msg_info "Adding User $username to sudo group"
        sleep 2
        usermod -aG sudo $username &>/dev/null
    #   Fix default bash for user
        chsh -s /bin/bash $username &>/dev/null
    #   Set ssh permissions
        chmod 700 $HOME/.ssh &>/dev/null
        msg_ok "$username user added to sudo group"

        msg_info "Creating ssh folder for user $username and setting permissions"
        sleep 2
        mkdir /home/$username/.ssh && chmod 700 /home/$username/.ssh &>/dev/null
        chown $username /home/$username/.ssh &>/dev/null
        msg_ok "SSH folder for user $username created and permissions set"

        msg_info "Copying ssh key from user root to $username"
        sleep 2
        touch /home/$username/.ssh/authorized_keys
        cat .ssh/authorized_keys >> /home/$username/.ssh/authorized_keys
        msg_ok "SSH keys copied from user root to $username"

        msg_info "Disabling Root and password login, setting IPv4 only"
        sleep 2
        sed -i 's/#AddressFamily any/AddressFamily inet/g;s/#PasswordAuthentication yes/PasswordAuthentication no/g;s/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
        msg_ok "Root and password login disabled, only IPv4 set"

        msg_info "Updating system"
        sleep 2
        apt update &>/dev/null
        apt -y dist-upgrade &>/dev/null
        msg_ok "System updated"

        msg_info "Cleaning up downloaded packages and removing orphans"
        sleep 2
        apt clean &>/dev/null
        apt autoremove &>/dev/null
        msg_ok "Downloaded packages cleared and orphans removed"
        echo ""
        echo "System config Finished..."
        echo ""
        read -n 1 -s -r -p "Press enter to REBOOT NOW. "
        rp=1
        break;;
    [2] ) echo Setting up VM;
#    #   Check if user exists > exit
#        if  id "$username" >/dev/null 2>&1; then
#            echo "Not a fresh system! Script cancelled"
#            exit 1
#        fi
#    #   If ssh auth key file doesn't exist ask user to enter ssh public key
#        [ -f ~/.ssh/authorized_keys ] || read -p "Must enter ssh public key, otherwise you won't be able to login!: " pubsshkey
#    #   Set hashed pass
#        password=sa.EukkiViW5.
#    #   Create user
#        useradd -m -p "$password" "$username"
#    #   Add user to sudo group
#        usermod -aG sudo $username
#    #   Fix default bash for user
#        chsh -s /bin/bash $username
#    #   Set ssh permissions
#        chmod 700 ~/.ssh
#    #   Create ssh folder for USER and Set permissions
#        mkdir /home/$username/.ssh && chmod 700 /home/$username/.ssh
#        chown $username /home/$username/.ssh
    #   Disable root and pass login and to IPv4 only
        $SUDO_CMD sed -i 's/#AddressFamily any/AddressFamily inet/g;s/#PasswordAuthentication yes/PasswordAuthentication no/g;s/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
    #   Update packeges
        $SUDO_CMD apt update && $SUDO_CMD apt -y dist-upgrade
    #   Install qemu agent
        $SUDO_CMD apt -y install qemu-guest-agent
    #   Clean downloaded packages and remove orphans
        $SUDO_CMD apt clean && $SUDO_CMD apt -y autoremove
#    #   If var pubsshkey not empty create ssh auth file and add ssh public key
#        [[ ! -z "$pubsshkey" ]] && cat > /home/$username/.ssh/authorized_keys << EOF
## --- BEGIN PVE ---
#$pubsshkey
## --- END PVE ---
#EOF

# import keys from github
#ssh-import-id-gh <username>

        echo ""
        read -n 1 -s -r -p "Press enter to POWER OFF now. "
        rp=2
        break;;
esac

#   Reboot or Poweroff
case $rp in 
    [1] ) echo -e "\nRebooting...";
    sleep 2 && reboot
    exit;;
    [2] ) echo -e "\nPowering off...";
    sleep 2 && $SUDO_CMD poweroff
    exit;;
esac