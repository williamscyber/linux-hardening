#!/bin/bash
#This script is designed to help automate basic hardenign on Linux systems

#stop if command fails
set -e

#check for root
if [[ $EUID -ne 0 ]]; then
	echo "Run as root user"
	exit 1
fi

#update system packages
update_system() { 
	echo "Updating package lists..."
	apt update -y

	echo "Upgrading packages..."
	apt upgrade -y

	echo "Cleaning unneeded packages..."
	apt autoremove -y
	}

#firewall setup
firewall_config() {
	echo "Setting up firwall..."
	if ! command -v ufw >/dev/null 2>&1; then
		echo "Installing UFW..."
		apt install ufw -y
	else
		echo "UFW already installed"
	fi

	echo "Configuring firewall defaults..."
	ufw default deny incoming
	ufw default allow outgoing
	ufw allow ssh

	echo "Enabling firewall..."
	ufw --force enable

	echo "Checking firewall status..."
	ufw status verbose
	}

#ssh setup
ssh_config() {
	echo "Securing SSH configurations..."
    
	if ! command -v sshd >/dev/null 2>&1; then
        	echo "Installing OpenSSH server..."
        	apt install openssh-server -y
    	else
        	echo "OpenSSH already installed"
    	fi

	SSH_CONFIG="/etc/ssh/sshd_config"

    	echo "Disabling root login..."
    	sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' $SSH_CONFIG

    	echo "Disabling password authentication..."
    	sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' $SSH_CONFIG

    	echo "Enforcing SSH Protocol 2..."
    	sed -i 's/^#*Protocol.*/Protocol 2/' $SSH_CONFIG

	echo "Restarting SSH service..."
    	systemctl restart ssh
	
	echo "SSH hardening applied."
	}

#Fail2Ban setup
fail2ban_setup() {
	echo "Installing Fail2Ban..."
	if ! command -v fail2ban-server >/dev/null 2>&1; then
		apt install fail2ban -y
	else
		echo "Fail2Ban is already installed"
	fi

	echo "Enabling and starting Fail2Ban service..."
	systemctl enable fail2ban
	systemctl start fail2ban

	cat <<EOL > /etc/fail2ban/jail.local
	[sshd]
	enabled = true
	port = ssh
	filter = sshd
	logpath = /var/log/auth.log
	maxretry = 5
	bantime = 3600
EOL
	
	systemctl restart fail2ban

	echo "Fail2Ban Status: "
	systemctl status fail2ban --no-pager | head -n 20
	}


#functions
update_system
firewall_config
ssh_config
fail2ban_setup
echo " "

echo "Baseline hardening has been applied, stay safe."

