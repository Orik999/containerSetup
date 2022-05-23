#! /bin/bash

username=orik

while true; do
read -p "[1] Setup Container(User) - [2] Setup Container Template(Root) - [[c]] Cancel: " response12c
    case $response12c in 
        [1] ) echo Setting up Container;
        #   Check if user exists > continue
        if !  id "$username" >/dev/null 2>&1; then
            echo "Error- Container is not a template"
            exit 1
        fi
        #   Ask user to enter ssh public key
            read -p "Must enter ssh public key, otherwise you won't be able to login!: " pubsshkey
        #   Delete old ssh keys and gen new keys
            sudo rm /etc/ssh/ssh_host_* && sudo dpkg-reconfigure openssh-server
        #   Disable Password login
            sudo sed -i 's!#PasswordAuthentication yes!PasswordAuthentication no!g' /etc/ssh/sshd_config
        #   Restrict Root login and to IPv4 only
            sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g;s/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
        #   Update packeges
            sudo apt update && sudo apt -y dist-upgrade
        #   Clean downloaded packages and remove orphans
            sudo apt clean && sudo apt autoremove
        #   Create ssh auth file and add ssh public key
            cat > /home/$username/.ssh/authorized_keys << EOF
# --- BEGIN PVE ---
$pubsshkey
# --- END PVE ---
EOF
            read -n 1 -s -r -p "Press enter to REBOOT NOW. "
            rp=1
            break;;
        [2] ) echo Setting up Container Template;
            #read -p "Enter Username" username
            #read -p "Enter Password" password
        #   Check if user exists > exit
        if  id "$username" >/dev/null 2>&1; then
            echo "Not a fresh system! Script cancelled"
            exit 1
        fi
        #   Ask user if they would like to add  ssh public key
            read -p "Please enter ssh public key or press enter: " pubsshkey
        #   Set hashed pass
            password=sa.EukkiViW5.
        #   Create user
            useradd -m -p "$password" "$username"
        #   Add user to sudo group
            usermod -aG sudo $username
        #   Fix default bash for user
            chsh -s /bin/bash $username
        #   Set ssh permissions
            chmod 700 ~/.ssh
        #   Create ssh folder for USER and Set permissions
            mkdir /home/$username/.ssh && chmod 700 /home/$username/.ssh
            chown $username /home/$username/.ssh
        #   Update packeges
            sudo apt update && sudo apt -y dist-upgrade
        #   Clean downloaded packages and remove orphans
            apt clean && sudo apt autoremove
        #   Set system for clean first boot setup
            truncate -s 0 /etc/machine-id
        #   Create ssh auth file and add ssh public key
            cat > /home/$username/.ssh/authorized_keys << EOF
# --- BEGIN PVE ---
$pubsshkey
# --- END PVE ---
EOF
            read -n 1 -s -r -p "Press enter to POWER OFF now. Dont forget to create Template before next boot! "
            rp=2
            break;;
        ""|"c"|"C" ) echo exiting...;
            exit;;		
        * ) echo invalid response;;
    esac
done

#   Reboot or Poweroff
case $rp in 
    [1] ) echo \nRebooting...;
    sleep 2 && sudo reboot
    exit;;
    [2] ) echo \nPowering off...;
    sleep 2 && poweroff
    exit;;
esac
