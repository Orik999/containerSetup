#! /bin/bash

echo -e '\033[5mWARNING\033[0m'
echo 'WARNING: run this script only once a user has been created as this will disable root login'

read -p "Proceed with system changes? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
        #   Restrict Root login and to IPv4 only
    sed 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config | sed 's/#AddressFamily any/AddressFamily inet/g'
        #   Make ssh folder and set permissions
    mkdir ~/.ssh && chmod 700 ~/.ssh
        #   Install Start Fail2Ban
    apt install fail2ban && systemctl start fail2ban
        #   Create Copy fail2ban jail.local config
    cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
        #   Whitelist yourself from ever getting jailed
    sed 's/#ignoreip = 127.0.0.1/8 ::1/ignoreip = 127.0.0.1/8 ::1 192.168.1.100 192.168.1.101/g' /etc/sddm.conf
        #   Clean downloaded packages and remove orphans
    apt clean && sudo apt autoremove
        #   Set system for clean first boot setup
    cloud-init clean
    ehco 'Finished, Shutdown and create template'
then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
