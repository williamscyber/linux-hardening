# Linux Baseline Hardening Script
# Waterbears (or tardigrades) are microscopic invertibrates known for being one of Earth's toughest creatues.

# WARNING
-Run **locally** on your host.
-SSH password authentication will be disabled. Make sure you can  still log in with SSH keys before using this script remotley.
-This is still a work in progress.

# Features
-Updates system packages
-Upgrades system packages
-Removes unnecessary/unused packages to save disk space
-Configures UFW firewall (allow outgoing, deny incoming)
-Hardens SSH (root login disabled, password auth disabled, protocol 2)
-Installs and configures Fail2Ban for SSH

# Usage
```bash
chmod +x waterbear.sh
sudo ./waterbear.sh


