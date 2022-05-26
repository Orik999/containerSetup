#! /bin/bash

username=orik

while true; do
read -p "Setup Container/VM [Y/n]: " yn
#   Check if user not root then run all commands as sudo
    if  [[ "$(whoami)" != "root" ]]; then
        SUDO_CMD="sudo "
    fi
    case $yn in 
        ""|"y"|"Y" ) echo Setting up Container/VM;
        #   Check if system is a container
            SUDO_CMD grep -qa container=lxc /proc/1/environ && ynresponse=1 || ynresponse=2
            break;;
        [nN] ) echo -e "\nExiting...";
            exit;;		
        * ) echo -e "\nInvalid response";;
    esac
done

case $ynresponse in 
    [1] ) echo Setting up Container;
    #   If ssh auth key file doesn't exist ask user to enter ssh public key
        [ -f ~/.ssh/authorized_keys ] || read -p "Must enter ssh public key, otherwise you won't be able to login!: " pubsshkey
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
        $SUDO_CMD apt clean && $SUDO_CMD apt autoremove
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
    sleep 2 && $SUDO_CMD reboot
    exit;;
    [2] ) echo -e "\nPowering off...";
    sleep 2 && $SUDO_CMD poweroff
    exit;;
esac
