#! /bin/bash

echo -e '\033[5m\nWARNING WARNING WARNING\033[0m'
echo '\nWARNING: run this script only once a user has been created as this will disable root login'

while true; do
read -p "Do you want to proceed? (y/n) " yn
case $yn in 
	[yY] ) echo ok, we will proceed;
		break;;
	[nN] ) echo exiting...;
		exit;;
	* ) echo invalid response;;
esac

done
    #   Restrict Root login and to IPv4 only
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g;s/#AddressFamily any/AddressFamily inet/g' /etc/ssh/sshd_config
    #   Make ssh folder and set permissions
mkdir ~/.ssh && chmod 700 ~/.ssh
    #   Install Start Fail2Ban
apt install fail2ban && systemctl start fail2ban
    #   Create Copy fail2ban jail.local config
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
    #   Whitelist yourself from ever getting jailed
sed -i 's/#ignoreip = 127.0.0.1/8 ::1/ignoreip = 127.0.0.1/8 ::1 192.168.1.100 192.168.1.101/g' jail.local
    #   Clean downloaded packages and remove orphans
apt clean && sudo apt autoremove
    #   Set system for clean first boot setup
cloud-init clean
ehco 'Finished, Shutdown and create template'
