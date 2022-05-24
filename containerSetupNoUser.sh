#! /bin/bash

while true; do
read -p "Setup Container [Y/n]: " yn
    case $yn in 
        ""|"y"|"Y" ) echo Setting up Container;
        #   Check if user not root then run all commands as sudo
        if  [[ "$(whoami)" != "root" ]]; then
            SUDO_CMD="sudo "
        fi
        #   If ssh auth key file doesn't exist ask user to enter ssh public key
            [ -f ~/.ssh/authorized_keys ] || read -p "Must enter ssh public key, otherwise you won't be able to login!: " pubsshkey
        #   Ask user to enter ssh public key
            read -p "Must enter ssh public key, otherwise you won't be able to login!: " pubsshkey
        #   Delete old ssh keys and gen new keys
            $SUDO_CMD rm /etc/ssh/ssh_host_* && $SUDO_CMD dpkg-reconfigure openssh-server
        #   Restrict Root login and to IPv4 only
            $SUDO_CMD sed -i 's/#AddressFamily any/AddressFamily inet/g;s/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
        #   Update packeges
            $SUDO_CMD apt update && $SUDO_CMD apt -y dist-upgrade
        #   Clean downloaded packages and remove orphans
            $SUDO_CMD apt clean && $SUDO_CMD apt autoremove
        #   If var pubsshkey not empty create ssh auth file and add ssh public key
            [[ ! -z "$pubsshkey" ]] && cat > ~/.ssh/authorized_keys << EOF
# --- BEGIN PVE ---
$pubsshkey
# --- END PVE ---
EOF
            read -n 1 -s -r -p "Press enter to REBOOT NOW. "
            break;;
        [nN] ) echo -e "\nExiting...";
            exit;;		
        * ) echo -e "\nInvalid response";;
    esac
done

#   Reboot
echo -e "\nRebooting..."
$SUDO_CMD reboot
