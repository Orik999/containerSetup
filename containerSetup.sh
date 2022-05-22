#! /bin/bash

username=orik

while true; do
read -p "[1] Setup Container(Root) - [2] Setup Container Template(User) - [c] Cancel (1/2/[c])" response12c
    case $response12c in 
        [1] ) echo Setting up Container;
        #   Check if user exists
            egrep "$username" /etc/passwd >/dev/null || echo "Error- Container is not a template" && exit 1
        #   Delete old ssh keys and gen new keys
            rm /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server
        #   Disable Password login
            sed -i 's!#PasswordAuthentication yes!PasswordAuthentication no!g' /etc/ssh/sshd_config
        #   Update packeges
            sudo apt update && sudo apt -y dist-upgrade
        #   Clean downloaded packages and remove orphans
            apt clean && sudo apt autoremove
            read -p "Reboot now. "
            rp=1
            break;;
        [2] ) echo Setting up Container Template;
            #read -p "Enter Username" username
            #read -p "Enter Password" password
            password=sa.EukkiViW5.
        #   Check if user exists > exit
            egrep "$username" /etc/passwd >/dev/null && echo "User exists! Script cancelled" && exit 1
        #   Create user
            useradd -m -p "$password" "$username"
        #   Add user to sudo group
            usermod -aG sudo $username
        #   Update packeges
            sudo apt update && sudo apt -y dist-upgrade
        #   Restrict Root login and to IPv4 only
            sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g;s/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
        #   Set ssh permissions
            chmod 700 ~/.ssh
        #   Create ssh folder for USER and Set permissions
            mkdir /home/$username/.ssh && chmod 700 /home/$username/.ssh
            chown /home/$username/.ssh $username
        #   Clean downloaded packages and remove orphans
            apt clean && sudo apt autoremove
        #   Set system for clean first boot setup
            truncate -s 0 /etc/machine-id
            read -p "Power off now. Dont forget to create Template before next boot! "
            rp=2
            break;;
        ""|"c"|"C" ) echo exiting...;
            exit;;		
        * ) echo invalid response;;
    esac
done

#   Reboot or Poweroff
case $rp in 
    [1] ) echo Rebooting...;
    sleep 2 && reboot
    exit;;
    [2] ) echo Powering off...;
    sleep 2 && poweroff
    exit;;
esac
